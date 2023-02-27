import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/database_connector_provider.dart';
import '/providers/filter_columns_provider.dart';
import '/providers/filter_list_provider.dart';
import '/providers/filtered_result_provider.dart';
import '/providers/gene_selection_review_provider.dart';
import '/providers/gene_selector_bulk_provider.dart';
import '/providers/gene_selector_provider.dart';
import '/widgets/check_data_connector/check_data_connector_error.dart';
import '/widgets/check_data_connector/check_data_connector_loading.dart';
import '/widgets/root.dart';

class FindMyUnderstudiedGenesApp extends StatelessWidget {
  const FindMyUnderstudiedGenesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
        primarySwatch: MaterialColor(
            const Color.fromRGBO(78, 42, 132, 1).value, const <int, Color>{
          50: Color.fromRGBO(78, 42, 132, 0.1),
          100: Color.fromRGBO(78, 42, 132, 0.2),
          200: Color.fromRGBO(78, 42, 132, 0.3),
          300: Color.fromRGBO(78, 42, 132, 0.4),
          400: Color.fromRGBO(78, 42, 132, 0.5),
          500: Color.fromRGBO(78, 42, 132, 0.6),
          600: Color.fromRGBO(78, 42, 132, 0.7),
          700: Color.fromRGBO(78, 42, 132, 0.8),
          800: Color.fromRGBO(78, 42, 132, 0.9),
          900: Color.fromRGBO(78, 42, 132, 1)
        }),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(78, 42, 132, 1),
            secondary: Colors.grey.shade400,
            brightness: Brightness.light),
        useMaterial3: true);

    final darkTheme = ThemeData(
        primarySwatch: MaterialColor(
            const Color.fromRGBO(78, 42, 132, 1).value, const <int, Color>{
          50: Color.fromRGBO(78, 42, 132, 0.1),
          100: Color.fromRGBO(78, 42, 132, 0.2),
          200: Color.fromRGBO(78, 42, 132, 0.3),
          300: Color.fromRGBO(78, 42, 132, 0.4),
          400: Color.fromRGBO(78, 42, 132, 0.5),
          500: Color.fromRGBO(78, 42, 132, 0.6),
          600: Color.fromRGBO(78, 42, 132, 0.7),
          700: Color.fromRGBO(78, 42, 132, 0.8),
          800: Color.fromRGBO(78, 42, 132, 0.9),
          900: Color.fromRGBO(78, 42, 132, 1)
        }),
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(78, 42, 132, 1),
            secondary: Colors.grey.shade700,
            brightness: Brightness.dark),
        useMaterial3: true);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DatabaseConnectorProvider()),
          ChangeNotifierProxyProvider<DatabaseConnectorProvider,
                  FilterColumnsProvider>(
              create: (_) => FilterColumnsProvider(),
              update: (_, databaseConnectorProvider, filterColumnsProvider) =>
                  filterColumnsProvider!..update(databaseConnectorProvider)),
          ChangeNotifierProvider<FilterListProvider>(
              create: (_) => FilterListProvider()),
          ChangeNotifierProxyProvider<DatabaseConnectorProvider,
                  GeneSelectionReviewProvider>(
              create: (_) => GeneSelectionReviewProvider(),
              update: (_, databaseConnectorProvider,
                      genesSelectionReviewProvider) =>
                  genesSelectionReviewProvider!
                    ..update(databaseConnectorProvider)),
          ChangeNotifierProxyProvider<DatabaseConnectorProvider,
                  GeneSelectorBulkProvider>(
              create: (_) => GeneSelectorBulkProvider(),
              update:
                  (_, databaseConnectorProvider, genesSelectorBulkProvider) =>
                      genesSelectorBulkProvider!
                        ..update(databaseConnectorProvider)),
          ChangeNotifierProxyProvider<DatabaseConnectorProvider,
                  GeneSelectorProvider>(
              create: (_) => GeneSelectorProvider(),
              update: (_, databaseConnectorProvider, genesSelectorProvider) =>
                  genesSelectorProvider!..update(databaseConnectorProvider)),
          ChangeNotifierProxyProvider2<DatabaseConnectorProvider,
                  FilterListProvider, FilteredResultProvider>(
              create: (_) => FilteredResultProvider(),
              update: (_, databaseConnectorProvider, filterListProvider,
                      filteredResultProvider) =>
                  filteredResultProvider!
                    ..update(databaseConnectorProvider)
                    ..updateFilterResults(filterListProvider.filters))
        ],
        child: MaterialApp(
            title: "Find my understudied genes",
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            home: Consumer<DatabaseConnectorProvider>(
                builder: (_, databaseConnectorProvider, __) {
              switch (databaseConnectorProvider.status) {
                case DatabaseConnectorStatus.unknown:
                case DatabaseConnectorStatus.loading:
                  return const CheckDataConnectorLoading();
                case DatabaseConnectorStatus.error:
                  return const CheckDataConnectorError();
                case DatabaseConnectorStatus.loaded:
                case DatabaseConnectorStatus.rebuilding:
                  return const Root();
              }
            })));
  }
}
