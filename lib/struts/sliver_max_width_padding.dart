import 'package:flutter/material.dart';

class SliverMaxWidthPadding extends StatelessWidget {
  const SliverMaxWidthPadding(
      {super.key, this.maxWidth, required this.children});

  const SliverMaxWidthPadding.defaultWidth({super.key, required this.children})
      : maxWidth = kDefaultWidth;

  final double? maxWidth;
  final List<Widget> children;

  static const double kDefaultWidth = 800;

  double _padding(BuildContext context) {
    if (maxWidth == null) {
      return 0;
    }
    final width = MediaQuery.of(context).size.width;
    const borderWidth = 16.0;
    if (width > maxWidth! + borderWidth * 2) {
      return (width - maxWidth!) / 2;
    } else {
      return borderWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: _padding(context)),
        sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[...children])));
  }
}
