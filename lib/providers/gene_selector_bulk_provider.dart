import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '/model/found_gene.dart';
import '/model/gene_name.dart';
import '/model/imported_candidate.dart';
import '/utils/operation.dart';
import 'database_connector_provider.dart';

enum GeneSelectorBulkStatus {
  clean,
  searching,
  review,
  error,
  selecting,
  finished,
  cancelled
}

class FindingGenesStatus {
  final int partial;
  final int total;
  final Duration elapsed;
  final Duration remain;

  FindingGenesStatus(this.partial, this.total, this.elapsed, this.remain);
}

class GeneSelectorBulkProvider with ChangeNotifier {
  DatabaseConnectorProvider? _databaseConnectorProvider;
  GeneSelectorBulkStatus _status = GeneSelectorBulkStatus.clean;
  FindingGenesStatus? _findingGenesStatus;
  bool _importingAllProteinCoding = false;
  List<ImportedCandidate>? _importedStatus;
  List<FoundGene> _foundGenes = [];

  GeneSelectorBulkStatus get status => _status;
  FindingGenesStatus? get findingGenesStatus => _findingGenesStatus;
  bool get importingAllProteinCoding => _importingAllProteinCoding;
  List<ImportedCandidate>? get importedStatus => _importedStatus;
  List<FoundGene> get foundGenes => _foundGenes;

  final _updateOperation = Operation.singleton(mustCancelCurrent: true);

  GeneSelectorBulkProvider();

  void update(DatabaseConnectorProvider databaseConnectorProvider) {
    _updateOperation.cancelAll();
    _databaseConnectorProvider = databaseConnectorProvider;
  }

  void clear() {
    _status = GeneSelectorBulkStatus.clean;
    _foundGenes = [];
    notifyListeners();
  }

  void startSelecting() {
    _status = GeneSelectorBulkStatus.selecting;
    notifyListeners();
  }

  void finishSelecting() {
    _status = GeneSelectorBulkStatus.finished;
    notifyListeners();
  }

  void findGenes(List<String> candidates) async {
    _importingAllProteinCoding = false;
    _updateOperation.schedule((status) async {
      _performFindGenesQuery(candidates, status);
    });
  }

  void findAllProteinCodingGenes() async {
    _importingAllProteinCoding = true;
    _updateOperation.schedule((status) async {
      _performFindAllProteinCodingGenes(status);
    });
  }

  Future _performFindGenesQuery(
      List<String> candidates, OperationStatus status) async {
    final stopwatch = Stopwatch();
    stopwatch.start();

    _status = GeneSelectorBulkStatus.searching;
    _foundGenes = [];
    _findingGenesStatus = null;
    _importedStatus = null;
    notifyListeners();

    final db = _databaseConnectorProvider?.db;
    if (db != null) {
      try {
        Map<int, FoundGene> mixingGenes = {};
        Set<String> missingCandidates = {};
        int count = 0;
        List<ImportedCandidate> importingStatus = [];

        for (var candidate in candidates) {
          // First, check if it is a number and is equal to a gene ncbi value
          var geneNcbi = int.tryParse(candidate);
          final geneNcbiResult = geneNcbi == null
              ? <GeneName>[]
              : (await db.query("genes",
                      where: "geneNcbi = ?", whereArgs: [geneNcbi]))
                  .map((value) => GeneName(value))
                  .toList();

          // If there is not a unique result, then, go to the rest
          final foundData = geneNcbiResult.length == 1
              ? geneNcbiResult
              : (await db.query("genes_filtering_table",
                      where: "value = ?", whereArgs: [candidate]))
                  .map((value) => GeneName(value))
                  .toList();

          // Now, check candidates
          if (foundData.isEmpty) {
            missingCandidates.add(candidate);
            importingStatus.add(ImportedCandidate.missing(candidate));
          } else {
            if (foundData.length == 1) {
              importingStatus
                  .add(ImportedCandidate.correct(candidate, foundData[0]));
            } else {
              importingStatus
                  .add(ImportedCandidate.multipleGenes(candidate, foundData));
            }
            for (var gene in foundData) {
              if (mixingGenes.containsKey(gene.geneNcbi)) {
                mixingGenes[gene.geneNcbi]!.candidates.add(candidate);
              } else {
                mixingGenes[gene.geneNcbi] = FoundGene(gene, {candidate});
              }
            }
          }

          count += 1;
          final int remainMilliseconds =
              ((stopwatch.elapsedMilliseconds / count) *
                          (candidates.length - count))
                      .round() +
                  1000;
          final remain = Duration(milliseconds: remainMilliseconds);
          _findingGenesStatus = FindingGenesStatus(
              count, candidates.length, stopwatch.elapsed, remain);
          notifyListeners();

          if (status.isCancelled) {
            _status = GeneSelectorBulkStatus.cancelled;
            _foundGenes = [];
            _findingGenesStatus = null;
            _importedStatus = null;
            notifyListeners();
            return;
          }
        }
        _status = GeneSelectorBulkStatus.review;
        _foundGenes = mixingGenes.values.toList();
        _findingGenesStatus = null;
        _importedStatus = importingStatus;
        notifyListeners();
        return;
      } on DatabaseException {
        developer.log("Error");
      }
    }
    _status = GeneSelectorBulkStatus.error;
    _foundGenes = [];
    _findingGenesStatus = null;
    _importedStatus = null;
    notifyListeners();
  }

  Future _performFindAllProteinCodingGenes(OperationStatus status) async {
    final stopwatch = Stopwatch();
    stopwatch.start();

    _status = GeneSelectorBulkStatus.searching;
    _foundGenes = [];
    _findingGenesStatus = null;
    _importedStatus = null;
    notifyListeners();

    final db = _databaseConnectorProvider?.db;
    if (db != null) {
      try {
        final foundGenes =
            (await db.rawQuery("SELECT * FROM genes WHERE proteinCoding == 1"))
                .map((value) => GeneName(value))
                .map((geneName) => FoundGene(geneName, {"Protein Coding"}))
                .toList();
        _status = GeneSelectorBulkStatus.review;
        _foundGenes = foundGenes;
        _findingGenesStatus = null;
        _importedStatus = [];
        notifyListeners();
        return;
      } on DatabaseException {
        developer.log("Error");
      }
    }
    _status = GeneSelectorBulkStatus.error;
    _foundGenes = [];
    _findingGenesStatus = null;
    _importedStatus = null;
    notifyListeners();
  }
}
