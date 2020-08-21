import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/util/helpers.dart';
import 'package:intl/intl.dart' as intl;

import '../behavior_renderable.dart';
import 'crosshair_renderer.dart';

intl.DateFormat dateFormat = intl.DateFormat('Hms');

class CrossHairRenderable<T extends BaseEntry> extends BehaviorRendererable {
  CrossHairRenderable(
    this.mainVisibleEntries,
    int rightXFactor,
    int leftXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    CrossHairBehavior renderer,
    bool isIndependentChart, {
    this.config,
  })  : _paint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
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
  final CrossHairConfig config;

  final DataSeries<T> mainVisibleEntries;

  @override
  void onPaint({Canvas canvas, Size size, AnimationsInfo animationsInfo}) {
    if (touchInfo.status == TouchStatus.longPressDown) {
      final entry = searchClosesEntry(
        touchInfo.xFactor,
        mainVisibleEntries,
        renderer.xFactorDecider,
      );
      _paint.color = config.labelBackgroundColor;

      final x = xFactorToX(renderer.xFactorDecider.getXFactor(entry));
      // Vertical line
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, 0),
        _paint,
      );

      if (config.hasTimeLabel) {
        final date = DateTime.fromMillisecondsSinceEpoch(entry.e.epoch);
        _drawAxisLabel(
          '${dateFormat.format(date)}',
          canvas,
          x - config.labelWidth / 2,
          size.height - config.labelHalfHeight * 2,
          x + config.labelWidth / 2,
          size.height,
        );
      }

      final touchYValue = yToValue(touchInfo.y);

      // Horizontal line
      if (isIndependentChart) {
        if (touchYValue <= animatedMaxValue &&
            touchYValue >= animatedMinValue) {
          canvas.drawLine(
            Offset(0, touchInfo.y),
            Offset(size.width, touchInfo.y),
            _paint,
          );

          if (config.hasValueLabel) {
            _drawAxisLabel(
              '${yToValue(touchInfo.y).toStringAsFixed(4)}',
              canvas,
              size.width - config.labelWidth,
              touchInfo.y - config.labelHalfHeight,
              size.width,
              touchInfo.y + config.labelHalfHeight,
            );
          }
        }
      }
    }
  }

  void _drawAxisLabel(String text, Canvas canvas, double left, double top,
      double right, double bottom) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(left, top, right, bottom), Radius.circular(4)),
        _paint);

    final textStyle = TextStyle(
      color: config.labelTextColor,
      fontSize: 10,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 50, maxWidth: 50);
    textPainter.paint(
        canvas, Offset(right - 50, top + config.labelHalfHeight - 5));
  }
}
