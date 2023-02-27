import 'package:flutter/material.dart';

import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';

class CheckDataConnectorLoading extends StatelessWidget {
  const CheckDataConnectorLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      const MainAppBar(title: Text("Welcome")),
      SliverMaxWidthPadding.defaultWidth(children: [
        const SizedBox(height: 20),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Loading gene database...",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              const CircularProgressIndicator()
            ])
      ])
    ]));
  }
}
