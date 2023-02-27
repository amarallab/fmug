import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/filtered_result_provider.dart';

import '/model/prepare_and_save_data_status.dart';

class FilterExportingDialog extends StatelessWidget {
  const FilterExportingDialog({super.key});

  Widget _buildContent(BuildContext context, PrepareAndSaveDataStatus status) {
    switch (status) {
      case PrepareAndSaveDataStatus.clean:
        return const Text("");
      case PrepareAndSaveDataStatus.askFilename:
        return const Text("");
      case PrepareAndSaveDataStatus.extractingSelectedGenes:
        return const Text("Extracting selected genes...");
      case PrepareAndSaveDataStatus.saving:
        return const Text("Saving into the file");
      case PrepareAndSaveDataStatus.done:
        return const Text("Done");
      case PrepareAndSaveDataStatus.error:
        return const Text("Error");
      case PrepareAndSaveDataStatus.cancelled:
        return const Text("Cancelled");
    }
  }

  List<Widget> _buildActions(
      BuildContext context, PrepareAndSaveDataStatus status) {
    switch (status) {
      case PrepareAndSaveDataStatus.done:
      case PrepareAndSaveDataStatus.error:
      case PrepareAndSaveDataStatus.cancelled:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context, "Close"),
            child: const Text("Close"),
          )
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FilteredResultProvider>(
        builder: (_, filteredResultProvider, __) => AlertDialog(
            title: const Text("Saving"),
            content: _buildContent(context, filteredResultProvider.status),
            actions: _buildActions(context, filteredResultProvider.status)));
  }
}
