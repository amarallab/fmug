import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/model/source.dart';
import '/providers/gene_selection_review_provider.dart';

class GeneSelectorSearchDialog extends StatelessWidget {
  const GeneSelectorSearchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneSelectionReviewProvider>(
        builder: (_, geneSelectionReviewProvider, __) => AlertDialog(
              title: const Text("Refine Search"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const ListTile(title: Text("Source")),
                ...sourceList.map((current) => RadioListTile<Source>(
                    title: Text(current.text),
                    value: current,
                    groupValue: geneSelectionReviewProvider.source,
                    onChanged: (Source? value) {
                      // setState(() {
                      geneSelectionReviewProvider.updateData(source: value);
                      // });
                    }))
              ]),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, "Close"),
                  child: const Text("Close"),
                ),
              ],
            ));
  }
}
