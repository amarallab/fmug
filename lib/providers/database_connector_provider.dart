import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/utils/utils.dart' as utils;

enum DatabaseConnectorStatus { unknown, loading, loaded, rebuilding, error }

const _currentDbVersion = "1.4";

class DatabaseConnectorProvider with ChangeNotifier {
  DatabaseConnectorStatus _status = DatabaseConnectorStatus.unknown;
  Database? _db;

  DatabaseConnectorStatus get status => _status;
  Database? get db => _db;

  DatabaseConnectorProvider() {
    developer.log("Creating a database provider");
    _checkAndOpenDatabase();
  }

  Future rebuild() async {
    var prevdb = _db;
    _status = DatabaseConnectorStatus.rebuilding;
    _db = null;
    notifyListeners();
    prevdb?.close();

    final documentsDirectory = await getApplicationSupportDirectory();
    String path = join(documentsDirectory.path, "db.sqlite");
    final file = File(path);

    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        _status = DatabaseConnectorStatus.error;
        notifyListeners();
        return;
      }
    }

    await _checkAndOpenDatabase();
  }

  Future _copyFromAssets(File toFile) async {
    final data = await rootBundle.load("assets/db.sqlite");
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    await toFile.writeAsBytes(bytes, flush: true);
  }

  Future<bool> _versionIsCorrect(String path) async {
    try {
      final file = File(path);
      bool fileExists = await file.exists();
      if (!fileExists) {
        developer.log("File does not exist");
        return false;
      }

      final db = await databaseFactoryFfi.openDatabase(path);
      final query = await db.query("version_table", columns: ["value"]);
      if (query.isEmpty) {
        db.close();
        return false;
      }
      final row = query.first;
      db.close();

      developer.log("Checking the $row");
      return row["value"].toString() == _currentDbVersion;
    } catch (e) {
      developer.log("There is an error: $e");
      return false;
    }
  }

  Future _checkAndOpenDatabase() async {
    _status = DatabaseConnectorStatus.loading;
    _db = null;
    notifyListeners();

    final documentsDirectory = await getApplicationSupportDirectory();
    String path = join(documentsDirectory.path, "db.sqlite");

    developer.log("The path is $path");

    try {
      bool isCorrect = await _versionIsCorrect(path);
      if (!isCorrect) {
        final file = File(path);
        await _copyFromAssets(file);
        bool isCorrect = await _versionIsCorrect(path);
        if (!isCorrect) {
          developer.log("Copied, but it still has errors...");
          _status = DatabaseConnectorStatus.error;
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      _status = DatabaseConnectorStatus.error;
      notifyListeners();
      return;
    }

    try {
      final newDb = await databaseFactoryFfi.openDatabase(path);
      developer.log("Open Database");
      final query =
          await newDb.query("genes", columns: ["COUNT(*)"]); // Check it works!
      final count = utils.firstIntValue(query);

      if (count == 0) {
        _status = DatabaseConnectorStatus.error;
      } else {
        _status = DatabaseConnectorStatus.loaded;
        _db = newDb;
      }
    } catch (e) {
      _status = DatabaseConnectorStatus.error;
    }
    await Future.delayed(const Duration(seconds: 3));

    notifyListeners();
  }
}
