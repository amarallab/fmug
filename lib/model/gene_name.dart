class GeneName {
  final int geneNcbi;
  final String geneEnsembl;
  final String description;

  GeneName(Map<String, dynamic> data)
      : geneNcbi = data["geneNcbi"],
        geneEnsembl = data["geneEnsembl"],
        description = data["description"];
}
