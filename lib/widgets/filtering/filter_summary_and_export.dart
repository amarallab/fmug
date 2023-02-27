import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:provider/provider.dart';

import '/model/prepare_and_save_data_status.dart';

import '/providers/filter_list_provider.dart';
import '/providers/filtered_result_provider.dart';
import '/struts/sliver_max_width_padding.dart';

import 'filter_exporting_dialog.dart';

import '/utils/utils.dart';

typedef ShowExportingDialogFunc = Future Function(String name);

class FilterSummaryAndExport extends StatefulWidget {
  const FilterSummaryAndExport({super.key, required this.showExportingDialog});

  final ShowExportingDialogFunc showExportingDialog;

  @override
  State<FilterSummaryAndExport> createState() => _FilterSummaryAndExportState();
}

class _FilterSummaryAndExportState extends State<FilterSummaryAndExport> {
  bool _exportingFile = false;

  Widget _inputListCountWidget(BuildContext context, int inputListCount) {
    final value = numberFormatFixed(inputListCount, fixedDecimals: 0);
    return Flexible(
        child: Text.rich(
            TextSpan(children: <TextSpan>[
              const TextSpan(text: "Number of genes in input list: "),
              TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
            maxLines: 7,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis));
  }

  Widget _filteredListCountWidget(BuildContext context, int filteredListCount) {
    final value = numberFormatFixed(filteredListCount, fixedDecimals: 0);
    return Flexible(
        child: Text.rich(
            TextSpan(children: <TextSpan>[
              const TextSpan(text: "Number of genes in filtered list: "),
              TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
            maxLines: 7,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis));
  }

  Widget _medianInputListWidget(BuildContext context, double medianInputList) {
    final percentage =
        numberFormatFixed(medianInputList * 100, fixedDecimals: 1);

    return Flexible(
        child: Text.rich(
            TextSpan(children: <TextSpan>[
              const TextSpan(
                  text:
                      "The median gene in your input list has more publications than "),
              TextSpan(
                  text: "$percentage %",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: " of genes")
            ]),
            maxLines: 7,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis));
  }

  Widget _medianFilteredListWidget(
      BuildContext context, double medianFilteredList) {
    final percentage =
        numberFormatFixed(medianFilteredList * 100, fixedDecimals: 1);

    return Flexible(
        child: Text.rich(
            TextSpan(children: <TextSpan>[
              const TextSpan(
                  text:
                      "The median gene in your filtered list has more publications than "),
              TextSpan(
                  text: "$percentage %",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: " of genes")
            ]),
            maxLines: 7,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FilterListProvider, FilteredResultProvider>(
        builder: (_, filterListProvider, filteredResultProvider, __) {
      final summary = filteredResultProvider.summary;
      if (summary == null) {
        return const SliverMaxWidthPadding.defaultWidth(children: []);
      }

      return SliverMaxWidthPadding.defaultWidth(children: [
        const SizedBox(height: 20),
        Text("Summary", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _inputListCountWidget(
                                context, summary.inputListCount),
                            const SizedBox(width: 20),
                            _filteredListCountWidget(
                                context, summary.filteredListCount)
                          ]),
                      const SizedBox(height: 20),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _medianInputListWidget(
                                context, summary.medianInputList),
                            const SizedBox(width: 20),
                            _medianFilteredListWidget(
                                context, summary.medianFilteredList)
                          ])
                    ]))),
        const SizedBox(height: 20),
        Text("Finish", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        ElevatedButton(
            onPressed: _exportingFile
                ? null
                : () async {
                    setState(() {
                      _exportingFile = true;
                    });

                    if ((defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.android)) {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => const FilterExportingDialog());
                      filteredResultProvider.prepareAndSaveDataMobile(
                          filterListProvider.filters, (text) async {
                        final encoded = utf8.encode(text);
                        final data = Uint8List.fromList(encoded);
                        final params = SaveFileDialogParams(
                            sourceFilePath: null,
                            data: data,
                            localOnly: false,
                            fileName: "filtered-genes.csv");
                        try {
                          final result =
                              await FlutterFileDialog.saveFile(params: params);
                          setState(() {
                            _exportingFile = false;
                          });
                          return result != null
                              ? PrepareAndSaveDataStatus.done
                              : PrepareAndSaveDataStatus.cancelled;
                        } catch (e) {
                          setState(() {
                            _exportingFile = false;
                          });
                          return PrepareAndSaveDataStatus.error;
                        }
                      });
                    } else {
                      final outputFilename = await FilePicker.platform.saveFile(
                          dialogTitle: "Please select an output file:",
                          fileName: "filtered-genes.csv",
                          lockParentWindow: true);
                      if (outputFilename == null) {
                        setState(() {
                          _exportingFile = false;
                        });

                        return;
                      }

                      await widget.showExportingDialog(outputFilename);
                      setState(() {
                        _exportingFile = false;
                      });
                    }
                  },
            child: const Text("Export filtered list")),
        const SizedBox(height: 87),
      ]);
    });
  }
}
