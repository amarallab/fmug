import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/filter_list_provider.dart';
import '/providers/filtered_result_provider.dart';
import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';

import 'filter_exporting_dialog.dart';
import 'filter_header.dart';
import 'filter_list.dart';
import 'filter_selector_dialog.dart';
import 'filter_summary_and_export.dart';

class Filtering extends StatelessWidget {
  const Filtering({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FilterListProvider, FilteredResultProvider>(
        builder: (_, filterListProvider, filteredResultProvider, __) =>
            Scaffold(
              body: CustomScrollView(slivers: <Widget>[
                const MainAppBar(title: Text("Filtering")),
                const FilterHeader(),
                FilterList(
                    filters: List.from(filterListProvider.filters),
                    onDeleteTapped: (filter) =>
                        filterListProvider.removeFilter(filter),
                    onFilterDefinitionChanged: (filter) =>
                        filterListProvider.updateFilter(filter)),
                SliverMaxWidthPadding.defaultWidth(children: [
                  ElevatedButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => FilterSelectorDialog(
                              excludedColumns: filterListProvider.filters
                                  .map((definition) => definition.column)
                                  .toList(),
                              onSelected: (newColumn, treatNullAsZero) {
                                filterListProvider.addNewFilter(
                                    newColumn, treatNullAsZero);
                              })),
                      child: const Text("Add filter"))
                ]),
                FilterSummaryAndExport(
                    showExportingDialog: (outputFilename) async {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const FilterExportingDialog());
                  await filteredResultProvider.prepareAndSaveData(
                      outputFilename, filterListProvider.filters);
                }),
              ]),
              // floatingActionButton: FloatingActionButton(
              //     onPressed: () => showDialog(
              //         context: context,
              //         builder: (context) => FilterSelectorDialog(
              //             excludedColumns: filterListProvider.filters
              //                 .map((definition) => definition.column)
              //                 .toList(),
              //             onSelected: (newColumn, treatNullAsZero) {
              //               filterListProvider.addNewFilter(
              //                   newColumn, treatNullAsZero);
              //             })),
              //     child: const Icon(Icons.add)))
            ));
  }
}
