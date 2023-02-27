import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/gene_selector_bulk_provider.dart';

import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';

import '/widgets/width_aware_widget.dart';

class GeneSelectorBulkFinished extends StatelessWidget {
  const GeneSelectorBulkFinished({super.key});

  Widget _foundGenesWidget(int count) {
    if (count == 0) {
      return const Text("No genes found");
    } else if (count == 1) {
      return const Text.rich(TextSpan(children: <TextSpan>[
        TextSpan(text: "You have selected "),
        TextSpan(text: "one", style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: " gene.")
      ]));
    } else {
      return Text.rich(TextSpan(children: <TextSpan>[
        const TextSpan(text: "You have selected "),
        TextSpan(
            text: "$count",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const TextSpan(text: " genes.")
      ]));
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
          SliverMaxWidthPadding.defaultWidth(children: [
            const SizedBox(height: 20),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer<GeneSelectorBulkProvider>(
                      builder: (_, geneSelectorBulkProvider, __) =>
                          _foundGenesWidget(
                              geneSelectorBulkProvider.foundGenes.length)),
                ]),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("OK"))
          ])
        ]));
  }
}
