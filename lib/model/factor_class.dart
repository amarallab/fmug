enum FactorClass { defaultClass, extendedClass }

FactorClass stringToFactorClass(String s) {
  switch (s) {
    case "default":
      return FactorClass.defaultClass;
    case "extended":
      return FactorClass.extendedClass;
    default:
      throw const FormatException();
  }
}

String factorClassToString(FactorClass fc) {
  switch (fc) {
    case FactorClass.defaultClass:
      return "default";
    case FactorClass.extendedClass:
      return "extended";
  }
}
