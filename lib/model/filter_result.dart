import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'filter_definition.dart';
import 'column_type.dart';
import 'd_type.dart';

double clamp(double value, double min, double max) {
  if (value <= min) return min;
  if (value >= max) return max;
  return value;
}

class FilterValues {
  FilterValues(this.data)
      : min = data.isEmpty ? 0 : data.reduce(math.min),
        max = data.isEmpty ? 1 : data.reduce(math.max);
  List<double> data;
  double min;
  double max;
}

class FilterResult {
  FilterDefinition definition;
  final FilterValues? _filterValues;

  FilterResult(FilterDefinition filter, FilterValues? filterValues)
      : definition = filter,
        _filterValues = filterValues;

  FilterValues? get filterValues => _filterValues;

  RangeValues? get valueLimits {
    switch (definition.column.columnType) {
      case ColumnType.boolean:
        return const RangeValues(0, 1);
      case ColumnType.linear:
        final value0 = _filterValues?.min ?? 0;
        final value1 = _filterValues?.max ?? 1;
        if (value0 < value1) {
          return RangeValues(value0, value1);
        } else if (value0 > value1) {
          return RangeValues(value1, value0);
        } else {
          return null;
        }
      case ColumnType.log:
        final value0 =
            (_filterValues?.min ?? 0) + definition.column.addBeforeLogTransform;
        final value1 =
            (_filterValues?.max ?? 1) + definition.column.addBeforeLogTransform;
        final logValue0 = value0 == 0 ? 0.0 : math.log(value0) / math.ln10;
        final logValue1 = value1 == 0 ? 0.0 : math.log(value1) / math.ln10;
        if (logValue0 < logValue1) {
          return RangeValues(math.min(0.0, logValue0), logValue1);
        } else if (logValue0 > logValue1) {
          return RangeValues(math.min(0.0, logValue1), logValue0);
        } else {
          return null;
        }
    }
  }

  RangeValues _calculateRangeValues(bool forFilter) {
    final RangeValues result;
    final valueLimits = this.valueLimits ?? const RangeValues(0, 1);

    switch (definition.column.columnType) {
      case ColumnType.boolean:
        return const RangeValues(0, 1);
      case ColumnType.linear:
        final value0 = definition.filterRange?.min ?? valueLimits.start;
        final value1 = definition.filterRange?.max ?? valueLimits.end;
        if (value0 <= value1) {
          result = RangeValues(value0, value1);
        } else {
          result = RangeValues(value1, value0);
        }
        break;
      case ColumnType.log:
        final filterRange = definition.filterRange;
        if (filterRange == null) {
          return valueLimits;
        } else {
          double value0 =
              filterRange.min + definition.column.addBeforeLogTransform;
          double value1 =
              filterRange.max + definition.column.addBeforeLogTransform;
          if (forFilter && definition.column.dType == DType.int) {
            value0 = value0.round().toDouble();
            value1 = value1.round().toDouble();
          }
          final logValue0 = value0 == 0 ? 0.0 : math.log(value0) / math.ln10;
          final logValue1 = value1 == 0 ? 0.0 : math.log(value1) / math.ln10;
          if (logValue0 <= logValue1) {
            result = RangeValues(logValue0, logValue1);
          } else {
            result = RangeValues(logValue1, logValue0);
          }
        }
    }
    return RangeValues(clamp(result.start, valueLimits.start, valueLimits.end),
        clamp(result.end, valueLimits.start, valueLimits.end));
  }

  RangeValues get rangeValuesForFiltering {
    return _calculateRangeValues(true);
  }

  RangeValues get rangeValues {
    return _calculateRangeValues(false);
  }

  int get fixedDecimals {
    final valueLimits = this.valueLimits ?? const RangeValues(0, 1);

    switch (definition.column.dType) {
      case DType.boolean:
      case DType.int:
        return 0;
      case DType.float:
        final range = valueLimits.end - valueLimits.start;
        final value = math.log(range) / math.ln10;
        if (value > 0) return 1;
        return (-value).ceil() + 1;
    }
  }
}
