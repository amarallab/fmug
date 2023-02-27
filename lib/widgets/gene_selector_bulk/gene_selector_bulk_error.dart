import 'package:flutter/material.dart';

import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';
import '/widgets/width_aware_widget.dart';

class GeneSelectorBulkError extends StatelessWidget {
  const GeneSelectorBulkError({super.key});

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
                  const SizedBox(height: 20),
                  Text("The bulk selection could not be performed.",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                ]),
            const SizedBox(height: 20),
          ])
        ]));
  }
}
