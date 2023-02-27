import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '/model/filter_column.dart';
import '/utils/operation.dart';
import 'database_connector_provider.dart';

class FilterColumnsProvider with ChangeNotifier {
  DatabaseConnectorProvider? _databaseConnectorProvider;
  List<FilterColumn> _filterColumns = [];
  final _updateOperation = Operation.singleton(mustCancelCurrent: true);
  List<FilterColumn> get filterColumns => _filterColumns;

  FilterColumnsProvider();

  Future update(DatabaseConnectorProvider databaseConnectorProvider) async {
    await _updateOperation.cancelAll();
    _databaseConnectorProvider = databaseConnectorProvider;
    _updateOperation.schedule(_filterColumnsQuery);
  }

  Future _filterColumnsQuery(OperationStatus status) async {
    _filterColumns = [];
    notifyListeners();

    final db = _databaseConnectorProvider?.db;
    if (db == null) {
      return;
    }

    try {
      _filterColumns = (await db.query("filter_columns"))
          .map((value) => FilterColumn.fromDatabase(value))
          .toList();
      notifyListeners();
    } on DatabaseException {
      developer.log("catched DatabaseException");
    }
  }
}
