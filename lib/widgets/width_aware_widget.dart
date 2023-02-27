import 'package:flutter/material.dart';

typedef WidthAwareChildFunc = Widget Function(num width);

class WidthAwareWidget extends StatelessWidget {
  const WidthAwareWidget({super.key, required this.childGenerator});

  final WidthAwareChildFunc childGenerator;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return childGenerator(width);
  }
}
