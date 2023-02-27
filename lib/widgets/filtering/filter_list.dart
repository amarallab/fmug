import 'package:flutter/material.dart';

import '/model/filter_definition.dart';
import 'filter_detail.dart';

typedef FilterDefinitionCallback = void Function(FilterDefinition filter);

class FilterList extends StatefulWidget {
  const FilterList(
      {super.key,
      required this.filters,
      required this.onDeleteTapped,
      required this.onFilterDefinitionChanged});

  static const double kDefaultWidth = 800;

  final List<FilterDefinition> filters;
  final FilterDefinitionCallback onDeleteTapped;
  final FilterDefinitionCallback onFilterDefinitionChanged;

  @override
  State<FilterList> createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
  final _listKey = GlobalKey<SliverAnimatedListState>();

  double _padding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const borderWidth = 16.0;
    if (width > FilterList.kDefaultWidth + borderWidth * 2) {
      return (width - FilterList.kDefaultWidth) / 2;
    } else {
      return borderWidth;
    }
  }

  Widget _buildListItem(BuildContext context, FilterDefinition filter,
      Animation<double> animation,
      {VoidCallback? onDeleteFilterTapped,
      FilterDefinitionCallback? onFilterDefinitionChanged}) {
    return Padding(
        padding:
            EdgeInsets.symmetric(vertical: 8.0, horizontal: _padding(context)),
        child: SizeTransition(
            sizeFactor: animation,
            child: FilterDetail(
                filter: filter,
                onDeleteFilterTapped: onDeleteFilterTapped ?? () {},
                onFilterDefinitionChanged:
                    onFilterDefinitionChanged ?? (value) {})));
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
        key: _listKey,
        initialItemCount: widget.filters.length,
        itemBuilder: (context, index, animation) {
          final filter = widget.filters[index];
          return _buildListItem(context, filter, animation,
              onDeleteFilterTapped: () {
            widget.onDeleteTapped(filter);
            _listKey.currentState?.removeItem(
                index,
                (context, animation) =>
                    _buildListItem(context, filter, animation)); // no callback!
          }, onFilterDefinitionChanged: widget.onFilterDefinitionChanged);
        });
  }

  _handleAddedItems({
    required List<FilterDefinition> oldFilters,
    required List<FilterDefinition> newFilters,
  }) {
    for (var i = 0; i < newFilters.length; i++) {
      final index = oldFilters
          .indexWhere((oldFilter) => oldFilter.key == newFilters[i].key);
      if (index == -1) {
        _listKey.currentState?.insertItem(i);
      }
    }
  }

  @override
  void didUpdateWidget(covariant FilterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleAddedItems(
        oldFilters: oldWidget.filters, newFilters: widget.filters);
  }
}
