import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '/model/filter_definition.dart';
import '/model/filter_column.dart';

class FilterListProvider with ChangeNotifier {
  List<FilterDefinition> _filters = [];
  List<FilterDefinition> get filters => _filters;

  FilterListProvider() {
    _performLoadFilters();
  }

  Future addNewFilter(FilterColumn column, bool treatNullAsZero) async {
    _filters.add(FilterDefinition(
        column: column,
        treatNullAsZero: treatNullAsZero,
        boolValue: column.defaultValue));
    await _performSaveFilters();
    notifyListeners();
  }

  Future updateFilter(FilterDefinition filter) async {
    final index = _filters.indexWhere((value) => value.key == filter.key);
    if (index == -1) {
      return;
    }
    _filters[index] = filter;
    await _performSaveFilters();
    notifyListeners();
  }

  Future removeFilter(FilterDefinition filter) async {
    _filters.remove(filter);
    await _performSaveFilters();
    notifyListeners();
  }

  Future removeAllFilters() async {
    _filters = [];
    await _performSaveFilters();
    notifyListeners();
  }

  Future _performLoadFilters() async {
    final documentsDirectory = await getApplicationSupportDirectory();
    final path = join(documentsDirectory.path, "filters.json");
    final file = File(path);
    if (await file.exists()) {
      final data = await file.readAsString();
      if (data.isEmpty) {
        _filters = [];
      } else {
        try {
          final List<dynamic> values = jsonDecode(data);
          _filters =
              values.map((value) => FilterDefinition.fromJson(value)).toList();
        } on FormatException {
          _filters = [];
        }
      }
    } else {
      _filters = [];
    }
    notifyListeners();
  }

  Future _performSaveFilters() async {
    final documentsDirectory = await getApplicationSupportDirectory();
    final path = join(documentsDirectory.path, "filters.json");
    final file = File(path);
    await file.writeAsString(jsonEncode(_filters));
  }
}
