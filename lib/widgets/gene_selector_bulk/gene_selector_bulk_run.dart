import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/gene_selector_bulk_provider.dart';
import 'gene_selector_bulk_error.dart';
import 'gene_selector_bulk_finished.dart';
import 'gene_selector_bulk_searching.dart';
import 'gene_selector_bulk_selecting.dart';
import 'gene_selector_bulk_review.dart';

class GeneSelectorBulkRun extends StatelessWidget {
  const GeneSelectorBulkRun({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneSelectorBulkProvider>(
        builder: (_, geneSelectorBulkProvider, __) {
      switch (geneSelectorBulkProvider.status) {
        case GeneSelectorBulkStatus.clean:
        case GeneSelectorBulkStatus.error:
        case GeneSelectorBulkStatus.cancelled:
          return const GeneSelectorBulkError();
        case GeneSelectorBulkStatus.searching:
          return const GeneSelectorBulkSearching();
        case GeneSelectorBulkStatus.review:
          return const GeneSelectorBulkReview();
        case GeneSelectorBulkStatus.selecting:
          return const GeneSelectorBulkSelecting();
        case GeneSelectorBulkStatus.finished:
          return const GeneSelectorBulkFinished();
      }
    });
  }
}
