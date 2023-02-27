enum ColumnType { boolean, linear, log }

ColumnType stringToColumnType(String s) {
  switch (s) {
    case "boolean":
      return ColumnType.boolean;
    case "linear":
      return ColumnType.linear;
    case "log":
      return ColumnType.log;
    default:
      throw const FormatException();
  }
}

String columnTypeToString(ColumnType ct) {
  switch (ct) {
    case ColumnType.boolean:
      return "boolean";
    case ColumnType.linear:
      return "linear";
    case ColumnType.log:
      return "log";
  }
}
