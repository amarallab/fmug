class Source {
  final String value;
  final String text;

  const Source({required this.value, required this.text});
}

const sourceList = [
  Source(value: "dbxrefs", text: "Dbxrefs"),
  Source(value: "symbolFromNomenclatureAuthority", text: "Nomenclature"),
  Source(value: "synonyms", text: "Synonyms")
];

final defaultSourceList = sourceList[1];
