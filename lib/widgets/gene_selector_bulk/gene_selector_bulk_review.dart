import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/model/found_gene.dart';
import '/providers/filter_list_provider.dart';
import '/providers/filtered_result_provider.dart';
import '/providers/gene_selection_review_provider.dart';
import '/providers/gene_selector_provider.dart';
import '/providers/gene_selector_bulk_provider.dart';
import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';
import '/widgets/width_aware_widget.dart';
import 'gene_selector_bulk_alert.dart';

class GeneSelectorBulkReviewDataTableSource extends DataTableSource {
  final List<FoundGene> _result;

  GeneSelectorBulkReviewDataTableSource(List<FoundGene> result)
      : _result = result;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _result.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    final geneName = _result[index];
    return DataRow(selected: false, cells: [
      DataCell(Text(geneName.gene.geneEnsembl)),
      DataCell(Text(geneName.gene.description)),
      DataCell(Text(geneName.candidates.join(", "))),
    ]);
  }
}

class GeneSelectorBulkReview extends StatelessWidget {
  const GeneSelectorBulkReview({super.key});

  Widget _foundGenesText(int count) {
    if (count == 0) {
      return WidthAwareWidget(
          childGenerator: (width) => width < 400
              ? const Text("0")
              : width < 600
                  ? const Text("No genes")
                  : const Text("No genes found"));
    } else if (count == 1) {
      return WidthAwareWidget(
          childGenerator: (width) => width < 400
              ? const Text("1")
              : width < 600
                  ? const Text("One gene")
                  : const Text("One gene found"));
    } else {
      return WidthAwareWidget(
          childGenerator: (width) => width < 400
              ? Text("$count")
              : width < 600
                  ? Text("$count genes")
                  : Text("Found Genes: $count"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: <Widget>[
          MainAppBar(
              title: WidthAwareWidget(
                  childGenerator: (child) => child < 600
                      ? const Text("Selection")
                      : const Text("Bulk selection"))),
          Consumer<GeneSelectorBulkProvider>(
              builder: (_, geneSelectorBulkProvider, __) =>
                  SliverMaxWidthPadding.defaultWidth(children: [
                    const SizedBox(height: 20),
                    ...(geneSelectorBulkProvider.importingAllProteinCoding
                        ? []
                        : const [
                            GeneSelectorBulkAlert(),
                            SizedBox(height: 20),
                          ]),
                    Consumer5<
                            FilterListProvider,
                            FilteredResultProvider,
                            GeneSelectorBulkProvider,
                            GeneSelectorProvider,
                            GeneSelectionReviewProvider>(
                        builder: (_,
                                filterListProvider,
                                filteredResultProvider,
                                geneSelectorBulkProvider,
                                geneSelectorProvider,
                                geneSelectionReviewProvider,
                                __) =>
                            PaginatedDataTable(
                                header: _foundGenesText(
                                    geneSelectorBulkProvider.foundGenes.length),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () => Navigator.of(context)
                                          .popUntil((route) => route.isFirst),
                                      child: const Text("Cancel")),
                                  ElevatedButton(
                                      onPressed: geneSelectorBulkProvider
                                              .foundGenes.isNotEmpty
                                          ? () async {
                                              geneSelectorBulkProvider
                                                  .startSelecting();
                                              await geneSelectorProvider
                                                  .selectBulk(
                                                      geneSelectorBulkProvider
                                                          .foundGenes
                                                          .map((value) => value
                                                              .gene.geneNcbi)
                                                          .toList());
                                              geneSelectorBulkProvider
                                                  .finishSelecting();
                                              filteredResultProvider
                                                  .updateFilterResults(
                                                      filterListProvider
                                                          .filters);
                                              geneSelectionReviewProvider
                                                  .updateData();
                                            }
                                          : null,
                                      child: const Text("Proceed"))
                                ],
                                source: GeneSelectorBulkReviewDataTableSource(
                                    geneSelectorBulkProvider.foundGenes),
                                columns: const <DataColumn>[
                                  DataColumn(
                                    label: Expanded(
                                        child: Text("ID",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic))),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                        child: Text("Description",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic))),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                        child: Text("Candidates",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic))),
                                  )
                                ],
                                columnSpacing: 8,
                                horizontalMargin: 10,
                                rowsPerPage: math.min(
                                    8,
                                    math.max(1,
                                        geneSelectorBulkProvider.foundGenes.length)))),
                    const SizedBox(height: 20),
                  ]))
        ]));
  }
}
