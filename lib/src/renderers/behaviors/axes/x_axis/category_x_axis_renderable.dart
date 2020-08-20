import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/axes/axis_config.dart';
import 'package:intl/intl.dart' as intl;

import '../../behavior_renderable.dart';

intl.DateFormat dateFormat = intl.DateFormat('Hms');

const List<int> indexIntervals = [
  1000000, // 5 sec
  2000000, // 5 sec
  4000000, // 5 sec
  5000000, // 5 sec
  10000000, // 5 sec
  20000000, // 5 sec
  40000000, // 5 sec
  50000000, // 5 sec
  100000000, // 5 sec
  200000000, // 5 sec
  400000000, // 5 sec
  500000000, // 5 sec
  1000000000, // 5 sec
  2000000000, // 5 sec
  4000000000, // 5 sec
  5000000000, // 5 sec
  10000000000, // 5 sec
];


/// Renderable class for painting x-axis of type category
class CategoryXAxisRenderable<T extends BaseEntry>
    extends BehaviorRendererable {
  CategoryXAxisRenderable(
    int rightXFactor,
    int leftXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    CategoryXAxis renderer,
    bool isIndependentChart,
    AxisConfig config,
    this.mainVisibleEntries,
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

  final DataSeries<T> mainVisibleEntries;

  @override
  void onPaint({Canvas canvas, Size size, AnimationsInfo animationsInfo}) {
    if (mainVisibleEntries == null || mainVisibleEntries.length < 2) return;

    int selectedInterval = indexIntervals.lastWhere(
        (interval) => interval < 0.4 * xFactorDifference,
        orElse: () => indexIntervals.last);

    labelOffset = (config as CategoryXAxisConfig).hasLabel ? 20 : 0;

    for (final item in mainVisibleEntries) {
      if (item.index % selectedInterval == 0) {
        _drawAxisLine(canvas, xFactorToX(item.index));

        if ((config as CategoryXAxisConfig).hasLabel) {
          _drawAxisLabel(item.e.epoch, canvas, size, xFactorToX(item.index));
        }
      }
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
      canvas,
      Offset(lineX - textPainter.width / 2, size.height - textPainter.height),
    );
  }
}
