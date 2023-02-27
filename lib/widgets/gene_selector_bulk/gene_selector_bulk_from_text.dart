import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/gene_selector_bulk_provider.dart';
import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';

import '/widgets/width_aware_widget.dart';

import 'gene_selector_bulk_run.dart';

class GeneSelectorBulkFromText extends StatefulWidget {
  const GeneSelectorBulkFromText({super.key});

  @override
  State<GeneSelectorBulkFromText> createState() =>
      _GeneSelectorBulkFromTextState();
}

class _GeneSelectorBulkFromTextState extends State<GeneSelectorBulkFromText> {
  final controller = TextEditingController();
  List<String> candidates = [];
  String feedbackText = "";
  bool limitReached = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
                      : const Text("Bulk selection from text"))),
          SliverMaxWidthPadding.defaultWidth(children: [
            const SizedBox(height: 20),
            const Text(
                "Enter your gene list separated by commas, semicolons, tabs or new lines. You can copy & paste from your favorite text editor."),
            const SizedBox(height: 20),
            TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                maxLength: Platform.isWindows ? 2000 : null,
                maxLines: null,
                onChanged: (text) {
                  setState(() {
                    candidates = text
                        .split(RegExp(r"[,;\n\r\t]+"))
                        .where((s) => s.isNotEmpty)
                        .toList();
                    final count = candidates.length;
                    if (candidates.isEmpty) {
                      feedbackText = "";
                    } else if (count == 1) {
                      feedbackText = "One possible gene entered";
                    } else {
                      feedbackText = "$count possible genes entered";
                    }
                    limitReached = Platform.isWindows &&
                        (text.replaceAll("\r", "").length >= 2000);
                  });
                }),
            const SizedBox(height: 20),
            ...(limitReached
                ? const [
                    Card(
                        color: Colors.amber,
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text.rich(TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text:
                                      "Text limit reached. If you need to write more genes, consider write them in a "),
                              TextSpan(
                                  text: "text",
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic)),
                              TextSpan(text: " or "),
                              TextSpan(
                                  text: "CSV",
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic)),
                              TextSpan(text: " file and use the "),
                              TextSpan(
                                  text: "Bulk import from file",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: " option.")
                            ])))),
                    SizedBox(height: 20),
                  ]
                : []),
            Text(feedbackText),
            const SizedBox(height: 20),
            Consumer<GeneSelectorBulkProvider>(
                builder: (_, geneSelectorBulkProvider, __) => ElevatedButton(
                    onPressed: candidates.isEmpty
                        ? null
                        : () {
                            geneSelectorBulkProvider.findGenes(candidates);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    const GeneSelectorBulkRun()));
                          },
                    child: const Text("Start selection"))),
            const SizedBox(height: 20),
          ])
        ]));
  }
}
