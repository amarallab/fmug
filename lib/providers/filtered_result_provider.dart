import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/utils/utils.dart' as utils;

import '/model/column_type.dart';
import '/model/filter_definition.dart';
import '/model/filter_result.dart';
import '/model/gene_columns.dart';
import '/model/genes_summary.dart';
import '/model/prepare_and_save_data_status.dart';

import '/utils/operation.dart';
import 'database_connector_provider.dart';

typedef PrepareAndSaveDataFunc = Future<PrepareAndSaveDataStatus> Function(
    String);

class FilteredResultProvider with ChangeNotifier {
  DatabaseConnectorProvider? _databaseConnectorProvider;
  Map<UniqueKey, FilterResult> _filterResults = {};
  GenesSummary? _summary;
  PrepareAndSaveDataStatus status = PrepareAndSaveDataStatus.clean;

  final _updateAllFiltersOperation = Operation.debounce(
      const Duration(milliseconds: 100),
      mustCancelCurrent: true);
  GenesSummary? get summary => _summary;

  FilteredResultProvider();

  FilterResult? getFilterResultForDefinition(FilterDefinition definition) {
    return _filterResults[definition.key];
  }

  double _medianForSortedList(List<int> sortedList) {
    if (sortedList.isEmpty) {
      return 0.0;
    } else if (sortedList.length == 1) {
      return sortedList[0].toDouble();
    } else if (sortedList.length % 2 == 0) {
      final middle = (sortedList.length / 2).ceil();
      return (sortedList[middle - 1] + sortedList[middle]) / 2;
    } else {
      final middle = (sortedList.length / 2).ceil();
      return sortedList[middle].toDouble();
    }
  }

  void update(DatabaseConnectorProvider databaseConnectorProvider) {
    _databaseConnectorProvider = databaseConnectorProvider;
  }

  Future updateFilterResults(List<FilterDefinition> filters) async {
    for (final filter in filters) {
      final existingResult = _filterResults[filter.key];
      if (existingResult != null) {
        existingResult.definition = filter;
      }
    }
    notifyListeners();

    _updateAllFiltersOperation.schedule((status) async {
      await _updateAllFilters(filters, status);
    });
  }

  Future _updateAllFilters(
      List<FilterDefinition> filters, OperationStatus status) async {
    final db = _databaseConnectorProvider?.db;
    if (db == null) {
      return;
    }

    Map<UniqueKey, FilterResult> filterResults = {};
    try {
      List<String> allFilterWheres = ["1==1"];
      for (var current in filters) {
        switch (current.column.columnType) {
          case ColumnType.boolean:
            filterResults[current.key] = FilterResult(current, null);
            break;
          case ColumnType.linear:
          case ColumnType.log:
            final selectSql = current.treatNullAsZero
                ? "CAST(IFNULL(g.${current.column.columnName}, 0) AS FLOAT) AS value"
                : "CAST(g.${current.column.columnName} AS FLOAT) AS value";
            final firstWhereSql = current.treatNullAsZero
                ? "1==1"
                : "g.${current.column.columnName} IS NOT NULL";
            var result = await db.rawQuery("""
                SELECT $selectSql 
                FROM genes g INNER JOIN selected_genes sg ON g.geneNcbi == sg.geneNcbi
                WHERE $firstWhereSql
                """);
            final data = result
                .map((data) => data["value"])
                .whereType<double>()
                .toList();

            final newFilterResult = FilterResult(current, FilterValues(data));
            filterResults[current.key] = newFilterResult;
            break;
        }

        allFilterWheres.add(current.whereValue("g"));

        if (status.isCancelled) {
          return;
        }
      }

      _filterResults = filterResults;
      final whereValue = allFilterWheres.join(" AND ");
      developer.log(whereValue);

      int totalGenesCount = 0;
      int inputListCount = 0;
      int filteredListCount;
      double medianInputList = 0.0;
      double medianFilteredList = 0.0;

      {
        final result = await db.rawQuery("""
            SELECT COUNT(*) AS count 
            FROM genes
          """);
        totalGenesCount = utils.firstIntValue(result) ?? 0;
      }

      {
        final result = await db.rawQuery("""
            SELECT COUNT(*) AS count 
            FROM selected_genes
          """);
        inputListCount = utils.firstIntValue(result) ?? 0;
      }

      {
        final result = await db.rawQuery("""
            SELECT COUNT(g.geneNcbi) AS count
            FROM genes g INNER JOIN selected_genes sg ON g.geneNcbi == sg.geneNcbi
            WHERE $whereValue
            """);
        filteredListCount = utils.firstIntValue(result) ?? 0;
      }

      final double medianValue;
      {
        final result = await db.rawQuery("""
            SELECT g.nPubs AS nPubs
            FROM genes g INNER JOIN selected_genes sg ON g.geneNcbi == sg.geneNcbi
            ORDER BY nPubs
            """);
        final data =
            result.map((data) => data["nPubs"]).whereType<int>().toList();
        medianValue = _medianForSortedList(data);
      }

      final double medianFilteredValue;
      {
        final result = await db.rawQuery("""
            SELECT g.nPubs AS nPubs
            FROM genes g INNER JOIN selected_genes sg ON g.geneNcbi == sg.geneNcbi
            WHERE $whereValue
            ORDER BY nPubs
            """);
        final data =
            result.map((data) => data["nPubs"]).whereType<int>().toList();
        medianFilteredValue = _medianForSortedList(data);
      }

      {
        final result = await db.rawQuery("""
            SELECT COUNT(g.geneNcbi) AS count
            FROM genes g
            WHERE g.nPubs <= ?
            """, [medianValue]);
        final underMedianCount = utils.firstIntValue(result) ?? 0;
        medianInputList = underMedianCount / totalGenesCount;
      }

      {
        final result = await db.rawQuery("""
            SELECT COUNT(g.geneNcbi) AS count
            FROM genes g
            WHERE g.nPubs <= ?
            """, [medianFilteredValue]);
        final underMedianCount = utils.firstIntValue(result) ?? 0;
        medianFilteredList = underMedianCount / totalGenesCount;
      }

      _summary = GenesSummary(inputListCount, filteredListCount,
          medianInputList, medianFilteredList);
    } on DatabaseException {
      developer.log("catched DatabaseException");
      _summary = null;
    }
    notifyListeners();
  }

  Future<String?> extractSelectedGenesAsCSV(
      List<FilterDefinition> filters) async {
    final db = _databaseConnectorProvider?.db;
    if (db == null) {
      return null;
    }

    try {
      List<String> allFilterWheres = ["1==1"];
      for (var current in filters) {
        allFilterWheres.add(current.whereValue("g"));
      }
      final whereValue = allFilterWheres.join(" AND ");
      developer.log(whereValue);
      final rows = [
        geneColumns.map((pair) => pair[0]).toList(), // header
        ...(await db.query(
                "genes g INNER JOIN selected_Genes sg ON g.geneNcbi == sg.geneNcbi",
                where: whereValue,
                orderBy: "geneNcbi"))
            .map((value) => geneColumns.map((pair) => value[pair[1]]).toList())
      ];
      return const ListToCsvConverter().convert(rows);
    } on DatabaseException {
      developer.log("catched DatabaseException");
      return null;
    }
  }

  Future prepareAndSaveData(
      String outputFilename, List<FilterDefinition> filters) async {
    status = PrepareAndSaveDataStatus.extractingSelectedGenes;
    notifyListeners();

    final text = await extractSelectedGenesAsCSV(filters);
    if (text == null) {
      status = PrepareAndSaveDataStatus.error;
      notifyListeners();
      return;
    }

    status = PrepareAndSaveDataStatus.saving;
    notifyListeners();

    final file = File(outputFilename);
    try {
      await file.writeAsString(text);
    } catch (e) {
      status = PrepareAndSaveDataStatus.error;
      notifyListeners();
      return;
    }

    status = PrepareAndSaveDataStatus.done;
    notifyListeners();
  }

  Future prepareAndSaveDataMobile(
      List<FilterDefinition> filters, PrepareAndSaveDataFunc func) async {
    status = PrepareAndSaveDataStatus.extractingSelectedGenes;
    notifyListeners();

    final text = await extractSelectedGenesAsCSV(filters);
    if (text == null) {
      status = PrepareAndSaveDataStatus.error;
      notifyListeners();
      return;
    }

    status = PrepareAndSaveDataStatus.askFilename;
    notifyListeners();

    status = await func(text);
    notifyListeners();
  }
}
