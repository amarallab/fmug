import 'package:flutter/material.dart';

import '/model/column_type.dart';
import '/model/filter_definition.dart';

import 'filter_list.dart';

class FilterSelectorTitle extends StatelessWidget {
  const FilterSelectorTitle(
      {Key? key, required this.filter, required this.onChanged})
      : super(key: key);

  final FilterDefinition filter;
  final FilterDefinitionCallback onChanged;

  @override
  Widget build(BuildContext context) {
    switch (filter.column.columnType) {
      case ColumnType.boolean:
        return DropdownButton<bool>(
            isExpanded: true,
            focusColor: Colors.transparent,
            value: filter.boolValue ?? false,
            onChanged: (bool? value) {
              filter.boolValue = value;
              onChanged(filter);
            },
            items: [
              DropdownMenuItem<bool>(
                  value: false, child: Text(filter.column.falseText)),
              DropdownMenuItem<bool>(
                  value: true, child: Text(filter.column.trueText))
            ]);
      case ColumnType.linear:
      case ColumnType.log:
        return Text(filter.column.commonName);
    }
  }
}
