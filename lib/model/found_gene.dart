import 'gene_name.dart';

class FoundGene {
  final GeneName gene;
  Set<String> candidates;

  FoundGene(this.gene, this.candidates);
}
