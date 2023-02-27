import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/database_connector_provider.dart';
import '/struts/main_app_bar.dart';
import '/struts/sliver_max_width_padding.dart';

class CheckDataConnectorError extends StatelessWidget {
  const CheckDataConnectorError({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: <Widget>[
      const MainAppBar(title: Text("Error")),
      SliverMaxWidthPadding.defaultWidth(children: [
        Center(
            child: Consumer<DatabaseConnectorProvider>(
          builder: (_, databaseConnectorProvider, __) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text("The database could not be read.",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                ElevatedButton(
                    child: const Text("Rebuild the database"),
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      await databaseConnectorProvider.rebuild();
                      scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text("Database is ready!")));
                    }),
              ]),
        ))
      ])
    ]));
  }
}
