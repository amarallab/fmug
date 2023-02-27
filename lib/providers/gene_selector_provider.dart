import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'database_connector_provider.dart';

class GeneSelectorProvider with ChangeNotifier {
  DatabaseConnectorProvider? _databaseConnectorProvider;
  Set<int> _selectedGenes = {};
  Set<int> get selectedGenes => _selectedGenes;

  GeneSelectorProvider();

  Future update(DatabaseConnectorProvider databaseConnectorProvider) async {
    _databaseConnectorProvider = databaseConnectorProvider;
    _performLoadSelectedGenes();
  }

  bool isSelected(int geneNcbi) {
    return selectedGenes.contains(geneNcbi);
  }

  Future unselectAll() async {
    final db = _databaseConnectorProvider?.db;
    if (db == null) return;
    try {
      await db.delete("selected_genes");
      _selectedGenes = {};
    } on DatabaseException {
      developer.log("Cannot un select all");
    }
    _selectedGenes = {};
    notifyListeners();
  }

  Future selectBulk(List<int> geneNcbis) async {
    final db = _databaseConnectorProvider?.db;
    if (db == null) return;
    try {
      var batch = db.batch();
      batch.delete("selected_genes");
      for (var value in geneNcbis) {
        batch.insert("selected_genes", {"geneNcbi": value});
      }
      await batch.commit(noResult: true);
      _selectedGenes = {...geneNcbis};
    } on DatabaseException {
      developer.log("Cannot select bulk");
    }
    notifyListeners();
  }

  Future _performLoadSelectedGenes() async {
    final db = _databaseConnectorProvider?.db;
    _selectedGenes = {};
    if (db == null) {
      notifyListeners();
      return;
    }
    try {
      final dataList = (await db.query("selected_genes"))
          .map((value) => value["geneNcbi"] as int)
          .toList();
      _selectedGenes = {...dataList};
    } on DatabaseException {
      developer.log("Cannot read selected genes");
    }
    notifyListeners();
  }
}
