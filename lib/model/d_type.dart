enum DType { boolean, int, float }

DType stringToDType(String s) {
  switch (s) {
    case "boolean":
    case "bool":
      return DType.boolean;
    case "int":
      return DType.int;
    case "float":
      return DType.float;
    default:
      throw const FormatException();
  }
}

String dTypeToString(DType dt) {
  switch (dt) {
    case DType.boolean:
      return "boolean";
    case DType.int:
      return "int";
    case DType.float:
      return "float";
  }
}
