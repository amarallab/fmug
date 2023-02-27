import '/model/found_gene.dart';

class FindGenesResult {
  bool searching;
  bool error;
  Set<String> missingCandidates;
  List<FoundGene> foundGenes;

  FindGenesResult(this.missingCandidates, this.foundGenes)
      : searching = false,
        error = false;

  FindGenesResult.searching()
      : searching = true,
        error = false,
        missingCandidates = {},
        foundGenes = [];

  FindGenesResult.error()
      : searching = false,
        error = true,
        missingCandidates = {},
        foundGenes = [];
}
