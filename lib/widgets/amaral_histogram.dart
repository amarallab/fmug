import 'dart:math' as math;
import 'package:flutter/material.dart';
import '/utils/utils.dart';

class _AmaralHistogramCustomPaint extends CustomPainter {
  _AmaralHistogramCustomPaint(
      {required this.binnedData,
      required this.minValue,
      required this.maxValue,
      required this.binInterval,
      required this.xScale,
      required this.yScale,
      required this.rangeValues,
      required this.yAxisWidth,
      required this.xAxisHeight,
      required this.tickWidth,
      required this.tickHeight,
      required this.selectedColor,
      required this.notSelectedColor}) {
    // X-Axis
    final xMaxValue = binInterval == 0 ? 1.0 : binnedData.length * binInterval;
    final xLogValue = (math.log(xMaxValue) / math.ln10).floor();
    final xDivider = math.pow(10, xLogValue);
    xStep = math.max(1, xDivider / 2);
    this.xMaxValue = xMaxValue;

    // Y-Axis
    final yMaxValue = binnedData.reduce(math.max).ceil();
    final yLogValue =
        yMaxValue == 0 ? 0 : (math.log(yMaxValue) / math.ln10).floor();
    final yDivider = math.pow(10, yLogValue);
    yStep = math.max(1, yDivider / 4);
    this.yMaxValue = ((yMaxValue / yStep).ceil() * yStep).ceil();
  }

  final List<double> binnedData;
  final double minValue;
  final double maxValue;
  final double binInterval;
  final AmaralScale xScale;
  final AmaralScale yScale;
  final RangeValues rangeValues;
  final double yAxisWidth;
  final double xAxisHeight;
  final double tickWidth;
  final double tickHeight;
  final Color selectedColor;
  final Color notSelectedColor;

  late final double xMaxValue;
  late final int yMaxValue;
  late final double xStep;
  late final double yStep;

  void _gridPlot(Canvas canvas, Offset offset, Size size) {
    var mainPaint = Paint()
      ..color = Colors.blueGrey[200]!
      ..style = PaintingStyle.fill;

    var tickPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final tickFont = TextStyle(
      color: Colors.blueGrey[600]!,
      fontSize: 12,
    );

    // X-Axis
    double? lastX;
    for (double xValue = 0; xValue <= xMaxValue; xValue += xStep) {
      final textValue = xScale == AmaralScale.linear
          ? minValue + xValue
          : math.pow(10, minValue + xValue);

      int fixedDecimals = 2;
      if (xScale == AmaralScale.log) {
        for (int i = 0; i < 5; i++) {
          if (textValue >= math.pow(10, -i)) {
            fixedDecimals = i;
            break;
          }
        }
      }

      final tickTextPainter = TextPainter(
        text: TextSpan(
          text: numberFormatFixed(textValue, fixedDecimals: fixedDecimals),
          style: tickFont,
        ),
        textDirection: TextDirection.ltr,
      );
      tickTextPainter.layout();

      final x = yAxisWidth + (xValue / xMaxValue) * (size.width - yAxisWidth);

      if (lastX != null && (x - tickTextPainter.width / 2) - lastX <= 0) {
        continue;
      }
      canvas.drawLine(
          offset + Offset(x, 0),
          offset + Offset(x, size.height - xAxisHeight),
          lastX == null ? tickPaint : mainPaint);
      canvas.drawLine(
          offset + Offset(x, size.height - xAxisHeight),
          offset + Offset(x, size.height - xAxisHeight + tickHeight),
          tickPaint);
      final tickOffset = offset +
          Offset(x - tickTextPainter.width / 2,
              size.height - xAxisHeight + tickHeight);
      tickTextPainter.paint(canvas, tickOffset);
      lastX = x + tickTextPainter.width / 2; // other side
    }

    // Y-Axis
    double? lastY;
    for (double yValue = 0; yValue <= yMaxValue; yValue += yStep) {
      final y = (1 - yValue / yMaxValue) * (size.height - xAxisHeight);
      if (lastY != null && lastY - y <= 20) {
        continue;
      }
      canvas.drawLine(offset + Offset(yAxisWidth - tickWidth, y),
          offset + Offset(yAxisWidth, y), tickPaint);
      canvas.drawLine(
          offset + Offset(yAxisWidth, y),
          offset + Offset(size.width, y),
          lastY == null ? tickPaint : mainPaint);
      final tickTextPainter = TextPainter(
        text: TextSpan(
          text: yScale == AmaralScale.linear
              ? "${yValue.toInt()}"
              : "${math.pow(10, yValue).toInt()}",
          style: tickFont,
        ),
        textDirection: TextDirection.ltr,
      );
      tickTextPainter.layout();
      final tickOffset = Offset(yAxisWidth - tickTextPainter.width, y);
      tickTextPainter.paint(canvas, tickOffset);
      lastY = y;
    }
  }

  void _mainPlot(Canvas canvas, Offset offset, Size size) {
    final selectedPaint = Paint()
      ..color = selectedColor //(0xff995588)
      ..style = PaintingStyle.fill;

    final notSelectedPaint = Paint()
      ..color = notSelectedColor
      ..style = PaintingStyle.fill;

    final widthInterval = size.width / binnedData.length;
    for (int i = 0; i < binnedData.length; i++) {
      if (!binnedData[i].isFinite) {
        continue;
      }
      final minBinValue = minValue + i * binInterval;
      final maxBinValue = minValue + (i + 1) * binInterval;
      final paint =
          (maxBinValue < rangeValues.start || rangeValues.end < minBinValue)
              ? notSelectedPaint
              : selectedPaint;
      final heightPercentage = binnedData[i] / yMaxValue;
      canvas.drawRect(
          (offset +
                  Offset(widthInterval * i,
                      (1 - heightPercentage) * size.height)) &
              Size(widthInterval, heightPercentage * size.height),
          paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double margin = 10.0;
    const offset = Offset(margin, margin);
    size = Size(size.width - margin * 2, size.height - margin * 2);

    _gridPlot(canvas, offset, size);
    _mainPlot(canvas, offset + Offset(yAxisWidth, 0),
        Size(size.width - yAxisWidth, size.height - xAxisHeight));
  }

  @override
  bool shouldRepaint(covariant _AmaralHistogramCustomPaint oldDelegate) {
    return false;
  }
}

enum AmaralScale { linear, log }

class AmaralHistogram extends StatelessWidget {
  AmaralHistogram(
      {super.key,
      required this.data,
      required this.width,
      required this.xScale,
      required this.yScale,
      required this.rangeValues,
      required this.height,
      double? yAxisWidth,
      double? xAxisHeight,
      double? tickWidth,
      double? tickHeight})
      : yAxisWidth = yAxisWidth ?? 70.0,
        xAxisHeight = xAxisHeight ?? 25.0,
        tickWidth = tickWidth ?? tickHeight ?? 10.0,
        tickHeight = tickHeight ?? tickWidth ?? 10.0 {
    final tmpMinValue = data.reduce(math.min);
    final minValue =
        xScale == AmaralScale.linear ? tmpMinValue : math.min(0.0, tmpMinValue);
    final maxValue = data.reduce(math.max);

    binInterval = (maxValue - minValue) * 10 / width;
    final bins =
        binInterval == 0 ? 1 : ((maxValue - minValue) / binInterval).ceil();
    final binnedData = List.filled(bins, 0.0);
    for (int i = 0; i < data.length; i++) {
      final bin = binInterval == 0
          ? 0
          : math.min(bins - 1, ((data[i] - minValue) / binInterval).floor());
      binnedData[bin]++;
    }

    if (yScale == AmaralScale.log) {
      for (int i = 0; i < binnedData.length; i++) {
        binnedData[i] = math.log(binnedData[i]) / math.log(10);
      }
    }
    this.binnedData = binnedData;
    this.minValue = minValue;
    this.maxValue = maxValue;
  }

  final List<double> data;
  final double width;
  final AmaralScale xScale;
  final AmaralScale yScale;
  final RangeValues rangeValues;
  final double height;
  final double yAxisWidth;
  final double xAxisHeight;
  final double tickWidth;
  final double tickHeight;

  late final double binInterval;
  late final List<double> binnedData;
  late final double minValue;
  late final double maxValue;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CustomPaint(
            size: Size(double.infinity, height),
            painter: _AmaralHistogramCustomPaint(
                binnedData: binnedData,
                minValue: minValue,
                maxValue: maxValue,
                binInterval: binInterval,
                xScale: xScale,
                yScale: yScale,
                rangeValues: rangeValues,
                yAxisWidth: yAxisWidth,
                xAxisHeight: xAxisHeight,
                tickWidth: tickWidth,
                tickHeight: tickHeight,
                selectedColor: Theme.of(context).colorScheme.primary,
                notSelectedColor: Theme.of(context).colorScheme.secondary)));
  }
}
