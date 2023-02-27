import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/gene_selector_provider.dart';
import '/widgets/gene_selector/gene_selector_empty.dart';
import '/widgets/gene_selector/gene_selector_selection.dart';

class GeneSelector extends StatelessWidget {
  const GeneSelector({super.key, required this.onApplyFilterTapped});

  final VoidCallback onApplyFilterTapped;

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneSelectorProvider>(
        builder: (_, geneSelectorProvider, __) {
      if (geneSelectorProvider.selectedGenes.isEmpty) {
        return const GeneSelectorEmpty();
      } else {
        return GeneSelectorSelection(onApplyFilterTapped: onApplyFilterTapped);
      }
    });
  }
}
