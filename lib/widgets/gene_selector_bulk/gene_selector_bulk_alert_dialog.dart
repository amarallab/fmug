import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/model/imported_candidate.dart';
import '/providers/gene_selector_bulk_provider.dart';

class GeneSelectorBulkAlertDialogTableSource extends DataTableSource {
  final List<ImportedCandidate> importedStatus;

  GeneSelectorBulkAlertDialogTableSource(this.importedStatus);

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => importedStatus.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    final current = importedStatus[index];
    switch (current.status) {
      case ImportingStatus.missing:
        return DataRow(cells: [
          DataCell(Text(current.candidate)),
          const DataCell(Text("Not found"))
        ]);
      case ImportingStatus.importMultipleGenes:
        final allData = current.importedGenes
            .map((current) => current.geneEnsembl)
            .join(", ");
        return DataRow(cells: [
          DataCell(Text(current.candidate)),
          DataCell(Text(allData))
        ]);
      default:
        return DataRow(cells: [
          DataCell(Text(current.candidate)),
          const DataCell(Text("---"))
        ]);
    }
  }
}

class GeneSelectorBulkAlertDialog extends StatelessWidget {
  const GeneSelectorBulkAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width.toDouble();
    final height = MediaQuery.of(context).size.height.toDouble();
    const borderWidth = 100.0;
    final maxWidth = math.min(width, 800) - borderWidth * 2;
    final maxHeight = math.max(20.0, height - 500);

    return Consumer<GeneSelectorBulkProvider>(
        builder: (_, geneSelectorBulkProvider, __) {
      final importedStatus = (geneSelectorBulkProvider.importedStatus ?? [])
          .where((candidate) => candidate.status != ImportingStatus.correct)
          .toList();

      final maxRowsPerPage = math.max(
          2,
          ((maxHeight - 1.5 * kMinInteractiveDimension) /
                  kMinInteractiveDimension)
              .ceil());

      return AlertDialog(
          title: const Text("Import warnings"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
                width: maxWidth,
                height: math.min(640, maxHeight) + 100,
                child: SingleChildScrollView(
                    child: PaginatedDataTable(
                        source: GeneSelectorBulkAlertDialogTableSource(
                            importedStatus),
                        columns: const [
                          DataColumn(
                              label: Expanded(
                                  child: Text("Candidate",
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic)))),
                          DataColumn(label: Expanded(child: Text("Issues")))
                        ],
                        columnSpacing: 8,
                        horizontalMargin: 10,
                        rowsPerPage: maxRowsPerPage)))
          ]),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, "Close"),
              child: const Text("Close"),
            ),
          ]);
    });
  }
}
