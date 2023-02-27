import 'dart:math' as math;
import 'package:json_annotation/json_annotation.dart';

import 'column_type.dart';
import 'd_type.dart';
import 'factor_class.dart';

@JsonSerializable()
class FilterColumn {
  final String columnName;
  final String commonName;
  final ColumnType columnType;
  final DType dType;
  final double addBeforeLogTransform;
  final FactorClass? factorClass;
  final String trueText;
  final String falseText;
  final bool defaultValue;
  final String tooltipText;

  FilterColumn(
      this.columnName,
      this.commonName,
      this.columnType,
      this.dType,
      this.addBeforeLogTransform,
      this.factorClass,
      this.trueText,
      this.falseText,
      this.defaultValue,
      this.tooltipText);

  factory FilterColumn.fromJson(Map<String, dynamic> json) {
    final columnName = json["columnName"];
    final commonName = json["commonName"];
    final columnType = stringToColumnType(json["columnType"]);
    final dType = stringToDType(json["dType"] ?? "boolean");
    final addBeforeLogTransform = json["addBeforeLogTransform"];
    final jsonFactorClass = json["factorClass"];
    final factorClass =
        jsonFactorClass == null ? null : stringToFactorClass(jsonFactorClass);
    final trueText = json["trueText"];
    final falseText = json["falseText"];
    final defaultValue = json["defaultValue"];
    final tooltipText = json["tooltipText"] ?? "";
    return FilterColumn(
        columnName,
        commonName,
        columnType,
        dType,
        addBeforeLogTransform,
        factorClass,
        trueText,
        falseText,
        defaultValue,
        tooltipText);
  }

  Map<String, dynamic> toJson() => {
        "columnName": columnName,
        "commonName": commonName,
        "columnType": columnTypeToString(columnType),
        "dType": dTypeToString(dType),
        "addBeforeLogTransform": addBeforeLogTransform,
        "factorClass":
            factorClass == null ? null : factorClassToString(factorClass!),
        "trueText": trueText,
        "falseText": falseText,
        "defaultValue": defaultValue,
        "tooltipText": tooltipText
      };

  factory FilterColumn.fromDatabase(Map<String, dynamic> data) {
    final columnName = data["columnName"] ?? "";
    final commonName = data["commonName"] ?? "";
    final display = data["display"];
    final ColumnType columnType;
    final DType dType = stringToDType(data["dtype"] ?? "boolean");
    final double addBeforeLogTransform;
    final jsonFactorClass = data["factorClass"] ?? "";
    final factorClass =
        jsonFactorClass.isEmpty ? null : stringToFactorClass(jsonFactorClass);
    final trueText = data["trueText"] ?? "";
    final falseText = data["falseText"] ?? "";
    final defaultValue = data["defaultValue"] == 1;
    final tooltipText = data["tooltipText"] ?? "";

    switch (dType) {
      case DType.boolean:
        columnType = ColumnType.boolean;
        addBeforeLogTransform = 0;
        break;
      case DType.int:
      case DType.float:
        switch (display) {
          case "linear":
            columnType = ColumnType.linear;
            addBeforeLogTransform = data["addBeforeLogTransform"] ?? 0;
            break;
          case "log":
            columnType = ColumnType.log;
            addBeforeLogTransform = data["addBeforeLogTransform"] ?? 0;
            break;
          default:
            columnType = ColumnType.boolean;
            addBeforeLogTransform = 0;
            assert(false);
        }
        break;
      default:
        columnType = ColumnType.boolean;
        addBeforeLogTransform = 0;
        assert(false);
    }
    return FilterColumn(
        columnName,
        commonName,
        columnType,
        dType,
        addBeforeLogTransform,
        factorClass,
        trueText,
        falseText,
        defaultValue,
        tooltipText);
  }

  @override
  int get hashCode => columnName.hashCode;

  @override
  bool operator ==(Object other) =>
      other is FilterColumn && other.columnName == columnName;

  double? applyLog(double value) {
    switch (columnType) {
      case ColumnType.boolean:
      case ColumnType.linear:
        return value;
      case ColumnType.log:
        final addedValue = value + addBeforeLogTransform;
        return addedValue == 0
            ? null
            : math.log(addedValue).toDouble() / math.ln10;
    }
  }

  double applyExp(double value) {
    switch (columnType) {
      case ColumnType.boolean:
      case ColumnType.linear:
        return value;
      case ColumnType.log:
        return math.pow(10, value).toDouble() - addBeforeLogTransform;
    }
  }
}
