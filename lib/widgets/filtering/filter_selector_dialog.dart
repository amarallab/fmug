import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/model/factor_class.dart';
import '/model/filter_column.dart';
import '/providers/filter_columns_provider.dart';
import '/widgets/width_Aware_widget.dart';

typedef FilterColumnCallback = void Function(FilterColumn, bool);

enum ListSelectableItemType { header, selectable, disabled }

class ListSelectableItem<T> {
  ListSelectableItemType type;
  String? text;
  T? selectable;

  ListSelectableItem(this.type, this.text, this.selectable);

  factory ListSelectableItem.text(String text) {
    return ListSelectableItem(ListSelectableItemType.header, text, null);
  }

  factory ListSelectableItem.selectable(T column, bool isDisabled) {
    return isDisabled
        ? ListSelectableItem(ListSelectableItemType.disabled, null, column)
        : ListSelectableItem(ListSelectableItemType.selectable, null, column);
  }
}

class FilterSelectorDialog extends StatefulWidget {
  const FilterSelectorDialog(
      {Key? key, required this.excludedColumns, required this.onSelected})
      : super(key: key);

  final List<FilterColumn> excludedColumns;
  final FilterColumnCallback onSelected;

  @override
  State<FilterSelectorDialog> createState() => _FilterSelectorDialogState();
}

class _FilterSelectorDialogState extends State<FilterSelectorDialog> {
  FilterColumn? _selectedColumn;
  int _nullResponseValue = 0;

  String? get filterDescription {
    final tooltipText = _selectedColumn?.tooltipText;
    if (tooltipText == null) return null;
    if (_nullResponseValue == 0) {
      return "$tooltipText.";
    } else {
      return "$tooltipText, treating null values as zero.";
    }
  }

  @override
  initState() {
    super.initState();
    _selectedColumn = null;
  }

  @override
  Widget build(BuildContext context) {
    return WidthAwareWidget(
        childGenerator: (width) => AlertDialog(
                title: const Text("Select filter"),
                content: _buildContent(context),
                contentPadding: width < 400 ? EdgeInsets.zero : null,
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, "Cancel"),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: _selectedColumn == null
                        ? null
                        : () {
                            widget.onSelected(
                                _selectedColumn!, _nullResponseValue == 1);
                            Navigator.pop(context, "OK");
                          },
                    child: const Text("OK"),
                  ),
                ]));
  }

  Widget _buildContent(BuildContext context) {
    final width = MediaQuery.of(context).size.width.toDouble();
    final height = MediaQuery.of(context).size.height.toDouble();
    const borderWidth = 100.0;
    final maxWidth =
        width > 400 ? math.min(width, 800) - borderWidth * 2 : width;
    final maxHeight = math.max(20.0, height - 300);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Consumer<FilterColumnsProvider>(builder: (_, filterColumnsProvider, __) {
        final allValues = filterColumnsProvider.filterColumns
            .where((column) => column.commonName.isNotEmpty)
            // .where((column) => !widget.excludedColumns.contains(column))
            .toList();
        allValues.sort((a, b) => a.commonName.compareTo(b.commonName));

        final defaultValues = allValues
            .where((column) => column.factorClass == FactorClass.defaultClass);

        final extendedValues = allValues
            .where((column) => column.factorClass == FactorClass.extendedClass);

        List<ListSelectableItem> values = [
          ListSelectableItem.text("Default"),
          ...defaultValues.map((c) => ListSelectableItem.selectable(
              c, widget.excludedColumns.contains(c))),
          ListSelectableItem.text("Advanced"),
          ...extendedValues.map((c) => ListSelectableItem.selectable(
              c, widget.excludedColumns.contains(c)))
        ];

        return SizedBox(
            width: maxWidth,
            height: maxHeight, //math.min(1240, maxHeight) + 100,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: values.length,
                              itemBuilder: (context, index) {
                                final value = values[index];
                                switch (value.type) {
                                  case ListSelectableItemType.header:
                                    return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Text(value.text!,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)));
                                  case ListSelectableItemType.selectable:
                                    final selectable = value.selectable!;
                                    final isSelected = (selectable.columnName ==
                                        _selectedColumn?.columnName);
                                    return Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : null),
                                        child: ListTile(
                                            title: Text(selectable.commonName),
                                            selected: isSelected,
                                            selectedColor: Colors.white,
                                            onTap: () {
                                              setState(() {
                                                _selectedColumn = selectable;
                                              });
                                            }));
                                  case ListSelectableItemType.disabled:
                                    final selectable = value.selectable!;
                                    return Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: null),
                                        child: ListTile(
                                            title: Text(selectable.commonName),
                                            selected: false,
                                            textColor: Colors.grey));
                                }
                              })),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                          isExpanded: true,
                          focusColor: Colors.transparent,
                          value: _nullResponseValue,
                          onChanged: (int? value) {
                            setState(() {
                              _nullResponseValue = value ?? 0;
                            });
                          },
                          items: const [
                            DropdownMenuItem<int>(
                                value: 0, child: Text("Don't use null values")),
                            DropdownMenuItem<int>(
                                value: 1,
                                child: Text("Treat null values as zero"))
                          ]),
                      ...(filterDescription == null || height < 600
                          ? []
                          : [
                              const SizedBox(height: 8),
                              InputDecorator(
                                decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.help_outline_outlined),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(filterDescription ?? ""),
                              ),
                            ])
                    ])));
      }),
    ]);
  }
}
