import 'gene_name.dart';

enum ImportingStatus { missing, correct, importMultipleGenes }

class ImportedCandidate {
  final String candidate;
  final ImportingStatus status;
  final List<GeneName> importedGenes;

  ImportedCandidate(this.candidate, this.status, this.importedGenes);

  ImportedCandidate.missing(this.candidate)
      : status = ImportingStatus.missing,
        importedGenes = [];

  ImportedCandidate.correct(this.candidate, GeneName geneName)
      : status = ImportingStatus.correct,
        importedGenes = [geneName];

  ImportedCandidate.multipleGenes(this.candidate, this.importedGenes)
      : status = ImportingStatus.importMultipleGenes;
}
