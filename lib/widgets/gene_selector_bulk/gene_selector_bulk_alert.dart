import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/model/imported_candidate.dart';
import '/providers/gene_selector_bulk_provider.dart';

import 'gene_selector_bulk_alert_dialog.dart';

class GeneSelectorBulkAlert extends StatelessWidget {
  const GeneSelectorBulkAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneSelectorBulkProvider>(
        builder: (_, geneSelectorBulkProvider, __) {
      final allCorrect = geneSelectorBulkProvider.importedStatus
              ?.where((current) => current.status != ImportingStatus.correct)
              .isEmpty ??
          true;

      if (allCorrect) {
        return const Card(
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("All candidates were found.")));
      }

      final missingValues = geneSelectorBulkProvider.importedStatus
              ?.where((current) => current.status == ImportingStatus.missing)
              .map((current) => current.candidate)
              .toList() ??
          [];

      String missingCandidates = missingValues.length > 6
          ? "${missingValues.toList().sublist(0, 6).join(", ")}... (total: ${missingValues.length})"
          : missingValues.join(", ");

      final missingWidgets = missingValues.isEmpty
          ? []
          : [
              const SizedBox(height: 20),
              missingValues.length == 1
                  ? const Text("Cannot find genes using this candidate:")
                  : const Text("Cannot find genes using these candidates:"),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(missingCandidates))
            ];

      final duplicatedValues = geneSelectorBulkProvider.importedStatus
              ?.where((current) =>
                  current.status == ImportingStatus.importMultipleGenes)
              .map((current) =>
                  "${current.candidate} (found ${current.importedGenes.length})")
              .toList() ??
          [];

      final duplicatedCount = geneSelectorBulkProvider.importedStatus
          ?.where((current) =>
              current.status == ImportingStatus.importMultipleGenes)
          .length;

      final duplicatedTotal = geneSelectorBulkProvider.importedStatus
          ?.where((current) =>
              current.status == ImportingStatus.importMultipleGenes)
          .map((current) => current.importedGenes.length)
          .fold(0, (a, b) => a + b);

      final duplicateCandidates = duplicatedValues.length > 4
          ? "${duplicatedValues.toList().sublist(0, 4).join(", ")}... ($duplicatedCount candidates find $duplicatedTotal genes)"
          : duplicatedValues.join(", ");

      final duplicatedWidgets = duplicatedValues.isEmpty
          ? []
          : [
              const SizedBox(height: 20),
              duplicatedValues.length == 1
                  ? const Text("This candidate find more than one gene:")
                  : const Text("These candidates find more than one gene:"),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(duplicateCandidates))
            ];

      return Card(
          color: Colors.amber,
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text("Warning",
                              style: Theme.of(context).textTheme.titleLarge)),
                      ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    const GeneSelectorBulkAlertDialog());
                          },
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.tertiary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onTertiary),
                          child: const Text("Details")),
                    ]),
                    ...missingWidgets,
                    ...duplicatedWidgets
                  ])));
    });
  }
}
