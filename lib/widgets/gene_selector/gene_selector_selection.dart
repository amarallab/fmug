import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/filter_list_provider.dart';
import '/providers/filtered_result_provider.dart';
import '/providers/gene_selection_review_provider.dart';
import '/providers/gene_selector_provider.dart';
import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';
import '/widgets/width_aware_widget.dart';
import 'gene_selector_searcher.dart';

class GeneSelectorAdvancedDataTableSource extends DataTableSource {
  final GeneSelectionReviewProvider _geneSelectionReviewProvider;

  GeneSelectorAdvancedDataTableSource(
      GeneSelectionReviewProvider geneSelectionReviewProvider)
      : _geneSelectionReviewProvider = geneSelectionReviewProvider;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _geneSelectionReviewProvider.filteredData.length;

  @override
  int get selectedRowCount => 0; //_geneSelectorProvider.selectedGenes.length;

  @override
  DataRow getRow(int index) {
    final geneName = _geneSelectionReviewProvider.filteredData[index];
    return DataRow(cells: [
      DataCell(Text(geneName.geneEnsembl)),
      DataCell(Text(geneName.value)),
      DataCell(Text(geneName.description)),
    ]);
  }
}

class GeneSelectorSelection extends StatefulWidget {
  const GeneSelectorSelection({super.key, required this.onApplyFilterTapped});

  final VoidCallback onApplyFilterTapped;

  @override
  State<GeneSelectorSelection> createState() => _GeneSelectorSelectionState();
}

class _GeneSelectorSelectionState extends State<GeneSelectorSelection> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  void _onSort(GeneSelectionReviewProvider geneSelectionReviewProvider,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      geneSelectionReviewProvider.updateData(
          sortColumnName: ["geneEnsembl", "value", "description"][columnIndex],
          sortAscending: ascending);
    });
  }

  String _foundGenesString(int count) {
    if (count == 0) {
      return "No genes selected";
    } else if (count == 1) {
      return "One gene selected";
    } else {
      return "Selected Genes: $count";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      const MainAppBar(title: Text("Gene List")),
      Consumer4<FilterListProvider, FilteredResultProvider,
              GeneSelectionReviewProvider, GeneSelectorProvider>(
          builder: (_, filterListProvider, filteredResultProvider,
                  geneSelectionReviewProvider, geneSelectorProvider, __) =>
              SliverMaxWidthPadding.defaultWidth(children: [
                const SizedBox(height: 20),
                GeneSelectorSearcher(
                    geneSelectionReviewProvider: geneSelectionReviewProvider),
                const SizedBox(height: 20),
                PaginatedDataTable(
                    actions: [
                      ElevatedButton(
                          child: WidthAwareWidget(
                              childGenerator: (width) => width < 600
                                  ? const Text("Clear")
                                  : const Text("Clear Selection")),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        title: const Text("Clear Selection"),
                                        content: const Text(
                                            "This action will clean the previous selection of genes you made."),
                                        actions: <Widget>[
                                          TextButton(
                                              child: const Text("Cancel"),
                                              onPressed: () =>
                                                  Navigator.of(context).pop()),
                                          TextButton(
                                              child: const Text("Proceed"),
                                              onPressed: () {
                                                geneSelectorProvider
                                                    .unselectAll();
                                                filteredResultProvider
                                                    .updateFilterResults(
                                                        filterListProvider
                                                            .filters);
                                                Navigator.of(context).pop();
                                              })
                                        ]));
                          }),
                      ElevatedButton(
                          onPressed: widget.onApplyFilterTapped,
                          child: WidthAwareWidget(
                              childGenerator: (width) => width < 600
                                  ? const Text("Filter")
                                  : const Text("Go to filters")))
                    ],
                    header: Text(_foundGenesString(
                        geneSelectorProvider.selectedGenes.length)),
                    source: GeneSelectorAdvancedDataTableSource(
                        geneSelectionReviewProvider),
                    columns: <DataColumn>[
                      DataColumn(
                          label: const Expanded(
                              child: Text("ID",
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic))),
                          onSort: (columnIndex, ascending) {
                            _onSort(geneSelectionReviewProvider, columnIndex,
                                ascending);
                          }),
                      DataColumn(
                          label: Expanded(
                              child: Text(
                                  geneSelectionReviewProvider.source.text,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic))),
                          onSort: (columnIndex, ascending) {
                            _onSort(geneSelectionReviewProvider, columnIndex,
                                ascending);
                          }),
                      DataColumn(
                          label: const Expanded(
                              child: Text("Description",
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic))),
                          onSort: (columnIndex, ascending) {
                            _onSort(geneSelectionReviewProvider, columnIndex,
                                ascending);
                          })
                    ],
                    columnSpacing: 8,
                    horizontalMargin: 10,
                    rowsPerPage: math.min(
                        8,
                        math.max(1,
                            geneSelectionReviewProvider.filteredData.length)),
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending),
                const SizedBox(height: 20),
              ]))
    ]));
  }
}
