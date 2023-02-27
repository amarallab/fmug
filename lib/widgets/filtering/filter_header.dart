import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/filter_list_provider.dart';
import '/struts/sliver_max_width_padding.dart';

class FilterHeader extends StatelessWidget {
  const FilterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterListProvider>(
        builder: (_, filterListProvider, __) =>
            SliverMaxWidthPadding.defaultWidth(
                children: filterListProvider.filters.isEmpty
                    ? [
                        const SizedBox(height: 20),
                        Text("There are no filters configured",
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 20),
                        const Text(
                            "Click on the next button to add a new filter"),
                        const SizedBox(height: 20),
                      ]
                    : [
                        const SizedBox(height: 20),
                        Text("Filters applied",
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 20),
                      ]));
  }
}
