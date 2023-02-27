class GeneFilter {
  final int geneNcbi;
  final String geneEnsembl;
  final String description;
  final String value;
  final String source;

  GeneFilter(Map<String, dynamic> data)
      : geneNcbi = data["geneNcbi"],
        geneEnsembl = data["geneEnsembl"],
        description = data["description"],
        value = data["value"],
        source = data["source"];
}
