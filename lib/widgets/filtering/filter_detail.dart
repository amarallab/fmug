import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/model/column_type.dart';
import '/model/filter_result.dart';
import '/model/filter_definition.dart';
import '/providers/filtered_result_provider.dart';
import '/utils/utils.dart';
import '/widgets/amaral_histogram.dart';
import 'filter_selector_title.dart';
import 'filter_list.dart';

class FilterDetail extends StatelessWidget {
  const FilterDetail(
      {super.key,
      required this.filter,
      required this.onDeleteFilterTapped,
      required this.onFilterDefinitionChanged});

  final FilterDefinition filter;
  final VoidCallback onDeleteFilterTapped;
  final FilterDefinitionCallback onFilterDefinitionChanged;

  Widget _buildErrorMessage(BuildContext context, List<String> messages) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages.map((message) => Text(message)).toList()));
  }

  List<Widget> buildColumnDetail(BuildContext context, FilterResult? result) {
    if (filter.column.columnType == ColumnType.boolean) {
      return [];
    }
    if (result == null) {
      return [];
    }
    final filterValues = result.filterValues;
    if (filterValues == null || filterValues.data.isEmpty) {
      return [];
    }

    final valueLimits = result.valueLimits;
    if (valueLimits == null) {
      return [
        _buildErrorMessage(context, [
          "There is not enough data.",
          "It is recommended to remove this filter."
        ])
      ];
    }

    final width = MediaQuery.of(context).size.width;
    final height = math.max(100.0, math.min(300.0, width / 3));

    return [
      AmaralHistogram(
          data: filterValues.data
              .map((value) => filter.column.applyLog(value))
              .whereType<double>()
              .toList(),
          width: width,
          xScale: filter.column.columnType == ColumnType.linear
              ? AmaralScale.linear
              : AmaralScale.log,
          yScale: AmaralScale.linear,
          rangeValues: result.rangeValuesForFiltering,
          height: height,
          yAxisWidth: 50),
      ...(filter.column.columnType == ColumnType.log
          ? [
              Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                  child: Center(
                      child: Text(
                          filter.column.addBeforeLogTransform == 0
                              ? "log(x)"
                              : "log(x + ${filter.column.addBeforeLogTransform})",
                          style: const TextStyle(fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center)))
            ]
          : []),
      Padding(
          padding: const EdgeInsets.fromLTRB(50, 0, 0, 20),
          child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12.0),
              ),
              child: RangeSlider(
                  values: result.rangeValues,
                  min: valueLimits.start,
                  max: valueLimits.end,
                  divisions: 100,
                  labels: RangeLabels(
                      numberFormatFixed(
                          filter.column.applyExp(result.rangeValues.start),
                          fixedDecimals: result.fixedDecimals),
                      numberFormatFixed(
                          filter.column.applyExp(result.rangeValues.end),
                          fixedDecimals: result.fixedDecimals)),
                  onChanged: (RangeValues values) {
                    filter.filterRange = FilterRange(
                        filter.column.applyExp(values.start),
                        filter.column.applyExp(values.end));
                    onFilterDefinitionChanged(filter);
                  }))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
          ListTile(
              leading: const Icon(Icons.filter_list),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(0.0),
                onPressed: onDeleteFilterTapped,
              ),
              title: FilterSelectorTitle(
                  filter: filter, onChanged: onFilterDefinitionChanged)),
          Consumer<FilteredResultProvider>(
              builder: (_, filteredResultProvider, __) {
            final filteredResult =
                filteredResultProvider.getFilterResultForDefinition(filter);
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: buildColumnDetail(context, filteredResult)));
          })
        ]));
  }
}
