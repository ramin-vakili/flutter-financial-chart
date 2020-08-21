import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';

import '../../behavior_renderable.dart';
import 'y_axis_renderer.dart';

const List<double> valueIntervals = [
  0.0001,
  0.00025,
  0.0005,
  0.00075,
  0.001,
  0.0025,
  0.005,
  0.0075,
  0.01,
  0.025,
  0.05,
  0.075,
  0.1,
  0.25,
  0.5,
  0.75,
  1,
  2,
  2.5,
  5,
  10,
  25,
  50,
  100,
  250,
];

class YAxisRenderable extends BehaviorRendererable {
  YAxisRenderable(
    int rightXFactor,
    int leftXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    YAxis renderer,
    bool isIndependentChart,
    YAxisConfig config,
  )   : _paint = Paint()
          ..color = config.lineColor
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..strokeWidth = 0.5,
        super(
          rightXFactor,
          leftXFactor,
          minValue,
          maxValue,
          touchInfo,
          renderer,
          isIndependentChart,
          config,
        );

  final Paint _paint;

  @override
  void onPaint({Canvas canvas, Size size, AnimationsInfo animationsInfo}) {
    double selectedInterval = valueIntervals.firstWhere((interval) {
      final double distancePixel = valueToY(animatingMaxValue - interval);
      return distancePixel > 0.15 * size.height &&
          distancePixel > (config as YAxisConfig).labelStyle.fontSize * 2;
    }, orElse: () => valueIntervals.last);

    double lineValue = animatingMaxValue - animatingMaxValue % selectedInterval;

    while (lineValue >= animatingMinValue) {
      double lineY = valueToY(lineValue);
      _drawAxisLine(canvas, lineY);

      _drawAxisLabel(lineValue, canvas, size, lineY);

      lineValue -= selectedInterval;
    }
  }

  void _drawAxisLine(ui.Canvas canvas, double lineY) {
    canvas.drawLine(
      Offset(0, lineY),
      Offset(canvasSize.width - 50, lineY),
      _paint,
    );
  }

  void _drawAxisLabel(
      double lineValue, ui.Canvas canvas, ui.Size size, double lineY) {
    final textStyle = TextStyle(
      color: (config as YAxisConfig).labelStyle.color,
      fontSize: (config as YAxisConfig).labelStyle.fontSize,
    );
    final textSpan = TextSpan(
      text: '${lineValue.toStringAsFixed(4)}',
      style: textStyle,
    );
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 50, maxWidth: 50);
    textPainter.paint(canvas, Offset(size.width - 50, lineY - 5));
  }
}
