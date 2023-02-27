import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';
import '/widgets/width_aware_widget.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key, required this.onGeneSelectionTapped});

  final VoidCallback onGeneSelectionTapped;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      MainAppBar(
          title: WidthAwareWidget(
              childGenerator: (width) => width < 600
                  ? const Text("FMUG")
                  : const Text("Find My Understudied Genes"))),
      SliverMaxWidthPadding.defaultWidth(children: [
        const SizedBox(height: 20),
        const Text.rich(TextSpan(
            text:
                "Find My Understudied Genes (FMUG) is a rationally-designed tool to helps biologists identify understudied genes and characterize their tractability for future research.")),
        const SizedBox(height: 20),
        const Text.rich(
          TextSpan(
              text:
                  "More information (including a tutorial and information on how to cite FMUG) is available at:"),
        ),
        const SizedBox(height: 20),
        Center(
            child: InkWell(
          onTap: () async {
            final url = Uri.parse("https://fmug.amaral.northwestern.edu/");
            await launchUrl(url, mode: LaunchMode.externalApplication);
          },
          child: Text(
            "https://fmug.amaral.northwestern.edu/",
            style: TextStyle(
                decoration: TextDecoration.underline,
                color: Theme.of(context).primaryColor),
          ),
        )),
        const SizedBox(height: 20),
        const Text.rich(TextSpan(children: <TextSpan>[
          TextSpan(
              text: "To continue, select your genes of interest by using the "),
          TextSpan(
              text: "genes", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
              text: " icon in the bottom bar or by tapping the button below.")
        ])),
        const SizedBox(height: 20),
        ElevatedButton(
            onPressed: onGeneSelectionTapped,
            child: const Text("Start gene selection")),
      ])
    ]));
  }
}
