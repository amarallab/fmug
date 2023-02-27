import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '/model/gene_filter.dart';
import '/model/source.dart';
import '/utils/operation.dart';
import 'database_connector_provider.dart';

class GeneSelectionReviewProvider with ChangeNotifier {
  DatabaseConnectorProvider? _databaseConnectorProvider;
  List<GeneFilter> _filteredData = [];
  String _searchText = "";
  Source _source = defaultSourceList;
  String _sortColumnName = "geneNcbi";
  bool _sortAscending = true;

  List<GeneFilter> get filteredData => _filteredData;
  String get searchText => _searchText;
  Source get source => _source;
  String get sortColumnName => _sortColumnName;
  bool get sortAscending => _sortAscending;

  final _updateSelectedGenesOperation =
      Operation.singleton(mustCancelCurrent: true);
  final _updateGeneNamesOperation =
      Operation.singleton(mustCancelCurrent: true);

  GeneSelectionReviewProvider();

  Future update(DatabaseConnectorProvider databaseConnectorProvider) async {
    await _updateSelectedGenesOperation.cancelAll();
    await _updateGeneNamesOperation.cancelAll();

    _databaseConnectorProvider = databaseConnectorProvider;

    _performGeneNamesQuery();
  }

  void updateData(
      {String? searchText,
      Source? source,
      String? sortColumnName,
      bool? sortAscending}) {
    if (searchText != null) {
      _searchText = searchText;
    }
    if (source != null) {
      _source = source;
    }
    if (sortColumnName != null) {
      _sortColumnName = sortColumnName;
    }
    if (sortAscending != null) {
      _sortAscending = sortAscending;
    }
    _performGeneNamesQuery();
  }

  void _performGeneNamesQuery() {
    _updateGeneNamesOperation.schedule((status) async {
      await _geneNamesQuery();
    });
  }

  Future _geneNamesQuery() async {
    final currentSearchText = "%$_searchText%";
    final currentSource = _source;
    final currentSortColumnName = _sortColumnName;
    final currentSortAscending = _sortAscending ? "ASC" : "DESC";
    _filteredData = [];

    final db = _databaseConnectorProvider?.db;
    if (db == null) {
      notifyListeners();
      return;
    }

    try {
      _filteredData = (await db.query(
              "(genes_filtering_table gft INNER JOIN selected_genes sg ON gft.geneNcbi == sg.geneNcbi)",
              where:
                  "(geneEnsembl LIKE ? OR value LIKE ? OR description LIKE ?) AND source = ?",
              whereArgs: [
                currentSearchText,
                currentSearchText,
                currentSearchText,
                currentSource.value
              ],
              orderBy: "$currentSortColumnName $currentSortAscending"))
          .map((value) => GeneFilter(value))
          .toList();
      developer.log("FilteredData: ${_filteredData.length}");
    } on DatabaseException {
      developer.log("Catched DatabaseException");
    }
    notifyListeners();
  }
}
