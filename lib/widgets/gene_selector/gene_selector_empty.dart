import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/gene_selector_bulk_provider.dart';
import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';
import '/widgets/gene_selector_bulk/gene_selector_bulk_from_file.dart';
import '/widgets/gene_selector_bulk/gene_selector_bulk_from_text.dart';
import '/widgets/width_aware_widget.dart';
import '/widgets/gene_selector_bulk/gene_selector_bulk_run.dart';

class GeneSelectorEmpty extends StatelessWidget {
  const GeneSelectorEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      const MainAppBar(title: Text("Gene List")),
      Consumer<GeneSelectorBulkProvider>(
          builder: (_, geneSelectorBulkProvider, __) =>
              SliverMaxWidthPadding.defaultWidth(children: [
                const SizedBox(height: 20),
                Text("No genes selected",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                const Text("Define a selection from a list of genes."),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                          fit: FlexFit.tight,
                          child: ElevatedButton(
                              child: WidthAwareWidget(
                                  childGenerator: (width) => width < 600
                                      ? const Text("From Text")
                                      : const Text("Bulk import from text")),
                              onPressed: () {
                                geneSelectorBulkProvider.clear();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const GeneSelectorBulkFromText()));
                              })),
                      const SizedBox(width: 8),
                      Flexible(
                          fit: FlexFit.tight,
                          child: ElevatedButton(
                              child: WidthAwareWidget(
                                  childGenerator: (width) => width < 600
                                      ? const Text("From file")
                                      : const Text("Bulk import from file")),
                              onPressed: () {
                                geneSelectorBulkProvider.clear();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const GeneSelectorBulkFromFile()));
                              }))
                    ]),
                const SizedBox(height: 40),
                const Text(
                    "Just trying FMUG? Select a list of all protein coding genes."),
                const SizedBox(height: 20),
                ElevatedButton(
                    child: WidthAwareWidget(
                        childGenerator: (width) => width < 600
                            ? const Text("Select")
                            : const Text("Select all protein coding genes")),
                    onPressed: () {
                      geneSelectorBulkProvider.findAllProteinCodingGenes();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const GeneSelectorBulkRun()));
                    }),
                const SizedBox(height: 20),
              ]))
    ]));
  }
}
