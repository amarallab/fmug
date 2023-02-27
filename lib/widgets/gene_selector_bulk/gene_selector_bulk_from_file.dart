import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/gene_selector_bulk_provider.dart';
import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';
import '/widgets/width_aware_widget.dart';
import 'gene_selector_bulk_run.dart';

class GeneSelectorBulkFromFile extends StatefulWidget {
  const GeneSelectorBulkFromFile({super.key});

  @override
  State<GeneSelectorBulkFromFile> createState() =>
      _GeneSelectorBulkFromFileState();
}

class _GeneSelectorBulkFromFileState extends State<GeneSelectorBulkFromFile> {
  String? errorText;
  String? selectedFilename;
  List<String> candidates = [];
  bool _fileHasBeenSelected = false;
  bool _selectingFile = false;

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
                      : const Text("Bulk selection from file"))),
          SliverMaxWidthPadding.defaultWidth(children: [
            const SizedBox(height: 20),
            const Text(
                "Select a text file that contains your gene list. It could be separated by commas, semicolons, tabs or new lines."),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _selectingFile
                    ? null
                    : () async {
                        setState(() {
                          _selectingFile = true;
                        });

                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(lockParentWindow: true);
                        if (result == null) {
                          setState(() {
                            _selectingFile = false;
                          });
                          return;
                        }
                        final filename = result.files.single.path;
                        if (filename == null) {
                          setState(() {
                            _fileHasBeenSelected = false;
                            _selectingFile = false;
                            errorText = null;
                          });
                          return;
                        }

                        setState(() {
                          _fileHasBeenSelected = true;
                          errorText = null;
                        });

                        File file = File(filename);
                        String? text;
                        try {
                          text = await file.readAsString();
                        } catch (e) {
                          text = null;
                        }

                        setState(() {
                          if (text == null) {
                            errorText = "Cannot read the file $filename";
                            selectedFilename = null;
                            candidates = [];
                          } else {
                            errorText = null;
                            selectedFilename = filename;
                            candidates = text
                                .split(RegExp(r"[,;\n\r\t]+"))
                                .where((s) => s.isNotEmpty)
                                .toList();
                          }
                          _selectingFile = false;
                        });
                      },
                child: WidthAwareWidget(
                    childGenerator: (width) => width < 600
                        ? const Text("File")
                        : (_fileHasBeenSelected
                            ? const Text("Select another file")
                            : const Text("Select file")))),
            ...(errorText == null
                ? []
                : [
                    const SizedBox(height: 20),
                    Card(
                        color: Colors.amber,
                        child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(errorText!))),
                  ]),
            ...(candidates.isEmpty
                ? []
                : [
                    const SizedBox(height: 20),
                    candidates.length == 1
                        ? const Text("One entry read from the selected file.")
                        : Text(
                            "${candidates.length} entries read from the selected file."),
                  ]),
            ...(errorText == null && _fileHasBeenSelected
                ? [
                    const SizedBox(height: 20),
                    Consumer<GeneSelectorBulkProvider>(
                        builder: (_, geneSelectorBulkProvider, __) =>
                            ElevatedButton(
                                onPressed: candidates.isEmpty || _selectingFile
                                    ? null
                                    : () {
                                        geneSelectorBulkProvider
                                            .findGenes(candidates);
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const GeneSelectorBulkRun()));
                                      },
                                child: WidthAwareWidget(
                                    childGenerator: (width) => width < 600
                                        ? const Text("Start")
                                        : const Text("Start selection"))))
                  ]
                : [])
          ]),
        ]));
  }
}
