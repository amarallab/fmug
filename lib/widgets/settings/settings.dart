import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/database_connector_provider.dart';
import '/providers/filter_list_provider.dart';
import '/providers/gene_selector_provider.dart';
import '/struts/sliver_max_width_padding.dart';
import '/struts/main_app_bar.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool rebuilding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      const MainAppBar(title: Text("Settings")),
      SliverMaxWidthPadding.defaultWidth(children: [
        const SizedBox(height: 20),
        Text("Gene Database", style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 20),
        const Text(
            "If the app is not working properly, you can rebuild the genes database. This action will remove the selection of genes that you could have selected previously."),
        const SizedBox(height: 20),
        Consumer3<DatabaseConnectorProvider, GeneSelectorProvider,
                FilterListProvider>(
            builder: (_, databaseConnectorProvider, geneSelectorProvider,
                    filterListProvider, __) =>
                ElevatedButton(
                    onPressed: rebuilding
                        ? null
                        : () async {
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            setState(() {
                              rebuilding = true;
                            });

                            await databaseConnectorProvider.rebuild();
                            await geneSelectorProvider.unselectAll();
                            await filterListProvider.removeAllFilters();

                            scaffoldMessenger.showSnackBar(const SnackBar(
                                content: Text("Database is ready!")));

                            navigator.popUntil((route) => route.isFirst);
                          },
                    child: const Text("Rebuild genes database")))
      ])
    ]));
  }
}
