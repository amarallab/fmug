import 'package:flutter/material.dart';

import '/providers/gene_selection_review_provider.dart';
import 'gene_selector_search_dialog.dart';

class GeneSelectorSearcher extends StatefulWidget {
  const GeneSelectorSearcher(
      {super.key, required this.geneSelectionReviewProvider});

  final GeneSelectionReviewProvider geneSelectionReviewProvider;

  @override
  State<GeneSelectorSearcher> createState() => _GeneSelectorSearcherState();
}

class _GeneSelectorSearcherState extends State<GeneSelectorSearcher> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController()
      ..addListener(() => widget.geneSelectionReviewProvider
          .updateData(searchText: controller.text));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: "Search",
          prefixIcon: Icon(Icons.search),
        ),
      )),
      IconButton(
          onPressed: controller.text.isEmpty ? null : () => controller.clear(),
          icon: const Icon(Icons.close)),
      IconButton(
          onPressed: () {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    const GeneSelectorSearchDialog());
          },
          icon: const Icon(Icons.menu)),
    ]);
  }
}
