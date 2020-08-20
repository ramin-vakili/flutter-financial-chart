import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/axes/axis_config.dart';
import 'package:intl/intl.dart' as intl;

import '../../behavior_renderable.dart';
import 'absolute_x_axis.dart';

intl.DateFormat dateFormat = intl.DateFormat('Hms');

const List<int> timeIntervals = [
  5000, // 5 sec
  10000, // 10 sec
  30000, // 30 sec
  60000, // 1 min
  120000, // 2 min
  180000, // 3 min
  300000, // 5 min
  600000, // 10 min
  900000, // 15 min
  1800000, // 30 min
  3600000, // 1 hour
  7200000, // 2 hours
  14400000, // 4 hours
  28800000, // 8 hours
  86400000, // 24 hours
  172800000, // 2 days
  259200000, // 3 days
  604800000, // 1 week
  2419200000, // 4 weeks
];

class XAxisRenderable extends BehaviorRendererable {
  XAxisRenderable(
    int rightXFactor,
    int leftXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    AbsoluteXAxis renderer,
    bool isIndependentChart,
    AxisConfig config,
  )   : _paint = Paint()
          ..color = Colors.white12
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
  double labelOffset = 20;

  @override
  void onPaint({Canvas canvas, Size size, AnimationsInfo animationsInfo}) {
    int selectedInterval = timeIntervals.lastWhere(
        (interval) => interval < 0.4 * xFactorDifference,
        orElse: () => timeIntervals.last);

    int lineXFactor = (rightXFactor - rightXFactor % selectedInterval).toInt();

    labelOffset = (config as AbsoluteXAxisConfig).hasLabel ? 20 : 0;

    while (lineXFactor >= leftXFactor) {
      double lineX = xFactorToX(lineXFactor);
      _drawAxisLine(canvas, lineX);

      if ((config as AbsoluteXAxisConfig).hasLabel) {
        _drawAxisLabel(lineXFactor, canvas, size, lineX);
      }

      lineXFactor -= selectedInterval;
    }
  }

  void _drawAxisLine(ui.Canvas canvas, double lineX) {
    canvas.drawLine(
      Offset(lineX, canvasSize.height - labelOffset),
      Offset(lineX, 0),
      _paint,
    );
  }

  void _drawAxisLabel(
    int lineXFactor,
    ui.Canvas canvas,
    ui.Size size,
    double lineX,
  ) {
    final textStyle = TextStyle(
      color: Colors.white38,
      fontSize: 10,
    );

    final date = DateTime.fromMillisecondsSinceEpoch(lineXFactor);

    final textSpan = TextSpan(
      text: '${dateFormat.format(date)}',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(minWidth: 50, maxWidth: 100);
    textPainter.paint(
        canvas, Offset(lineX - textPainter.width / 2, size.height - 20));
  }
}
