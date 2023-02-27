import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import 'filter_column.dart';
import 'column_type.dart';
import 'd_type.dart';

double clamp(double value, double min, double max) {
  if (value <= min) return min;
  if (value >= max) return max;
  return value;
}

@JsonSerializable()
class FilterRange {
  double min;
  double max;
  FilterRange(this.min, this.max);

  factory FilterRange.fromJson(Map<String, dynamic> json) {
    final min = json["min"];
    final max = json["max"];
    return FilterRange(min, max);
  }

  Map<String, dynamic> toJson() => {"min": min, "max": max};
}

@JsonSerializable()
class FilterDefinition {
  UniqueKey key;
  FilterColumn column;
  bool treatNullAsZero;
  bool? boolValue;

  FilterRange? filterRange;

  FilterDefinition(
      {UniqueKey? key,
      required this.column,
      required this.treatNullAsZero,
      this.boolValue,
      this.filterRange})
      : key = key ?? UniqueKey();

  factory FilterDefinition.fromJson(Map<String, dynamic> json) {
    final jsonColumn = json["column"];
    if (jsonColumn == null) throw const FormatException();
    final column = FilterColumn.fromJson(jsonColumn);
    final treatNullAsZero = json["treatNullAsZero"];
    final boolValue = json["boolValue"];
    final jsonFilterRange = json["filterRange"];
    final filterRange =
        jsonFilterRange == null ? null : FilterRange.fromJson(jsonFilterRange);
    return FilterDefinition(
        column: column,
        treatNullAsZero: treatNullAsZero,
        boolValue: boolValue,
        filterRange: filterRange);
  }

  Map<String, dynamic> toJson() => {
        "column": column.toJson(),
        "treatNullAsZero": treatNullAsZero,
        "boolValue": boolValue,
        "filterRange": filterRange?.toJson()
      };

  String whereValue(String tablePrefix) {
    if (column.columnType == ColumnType.boolean) {
      return (boolValue ?? false)
          ? "($tablePrefix.${column.columnName} == 1)"
          : "($tablePrefix.${column.columnName} == 0)";
    }

    if (filterRange == null) {
      return column.columnType == ColumnType.linear
          ? "1==1"
          : treatNullAsZero
              ? "(IFNULL($tablePrefix.${column.columnName}, 0) >= 0)"
              : "($tablePrefix.${column.columnName} >= 0)";
    }

    if (column.dType == DType.boolean) {
      return "1==1";
    }

    final String minValue;
    final String maxValue;
    if (column.dType == DType.int) {
      minValue = "${filterRange!.min.round()}";
      maxValue = "${filterRange!.max.round()}";
    } else {
      minValue = filterRange!.min.toStringAsFixed(2);
      maxValue = filterRange!.max.toStringAsFixed(2);
    }

    if (treatNullAsZero) {
      return "(IFNULL($tablePrefix.${column.columnName}, 0) BETWEEN $minValue AND $maxValue)";
    } else {
      return "($tablePrefix.${column.columnName} BETWEEN $minValue AND $maxValue)";
    }
  }
}
