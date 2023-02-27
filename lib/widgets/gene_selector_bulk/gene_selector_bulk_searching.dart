import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/gene_selector_bulk_provider.dart';
import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';

import '/widgets/width_aware_widget.dart';

class GeneSelectorBulkSearching extends StatelessWidget {
  const GeneSelectorBulkSearching({super.key});

  String _durationToString(Duration duration) {
    return duration.toString().split(".")[0];
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
            Consumer<GeneSelectorBulkProvider>(
                builder: (_, geneSelectorBulkProvider, __) {
              final status = geneSelectorBulkProvider.findingGenesStatus;
              final children = status == null
                  ? [
                      Text("Searching genes...",
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 20),
                      const CircularProgressIndicator()
                    ]
                  : [
                      Text("Searching genes...",
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 20),
                      CircularProgressIndicator(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          value: status.partial / status.total),
                      const SizedBox(height: 20),
                      Text("remain ${_durationToString(status.remain)}")
                    ];
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children);
            }),
            const SizedBox(height: 20),
          ])
        ]));
  }
}
