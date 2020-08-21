import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

import '../bar_mode_renderable.dart';
import 'bar_renderer.dart';

class BarRendererable extends BarModeRenderable<BaseEntry> {
  BarRendererable({
    @required DataSeries<BaseEntry> visibleEntries,
    @required IndexedData<BaseEntry> lastEntry,
    @required int leftXFactor,
    @required int rightXFactor,
    bool isIndependentChart,
    BarConfig barConfig,
    TouchInfo touchInfo,
    BarRenderer renderer,
  })  : _paint = Paint()
          ..color = barConfig.positiveColor ?? Colors.white
          ..style = PaintingStyle.fill,
        super(
          visibleEntries: visibleEntries,
          lastEntry: lastEntry,
          leftXFactor: leftXFactor,
          rightXFactor: rightXFactor,
          isIndependentChart: isIndependentChart,
          config: barConfig,
          touchInfo: touchInfo,
          renderer: renderer,
        );

  final Paint _paint;

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    IndexedData<BaseEntry> prevLastEntry,
  }) {
    super.onPaint(
      canvas: canvas,
      size: size,
      animationsInfo: animationsInfo,
      prevLastEntry: prevLastEntry,
    );

    for (int i = 0; i < visibleEntries.length - 1; i++) {
      final entry = visibleEntries[i];
      if (entry.e.value.isNaN) continue;

      _drawEntryBar(
        canvas: canvas,
        xFactor: renderer.xFactorDecider.getXFactor(entry),
        value: entry.e.value,
        size: size,
      );
    }

    // Last entry
    final IndexedData<BaseEntry> lastEntry = visibleEntries.last;

    if (lastEntry.e.value.isNaN) return;

    double animatedValue;
    if (prevLastEntry != null &&
        renderer.xFactorDecider.getXFactor(prevLastEntry) ==
            renderer.xFactorDecider.getXFactor(lastEntry)) {
      // Chart's first load
      animatedValue = lerpDouble(
        prevLastEntry.e.value,
        lastEntry.e.value,
        animationsInfo.newTickPercent,
      );
    } else {
      animatedValue = lerpDouble(
        0,
        lastEntry.e.value,
        animationsInfo.newTickPercent,
      );
    }

    _drawEntryBar(
      canvas: canvas,
      xFactor: renderer.xFactorDecider.getXFactor(lastEntry),
      value: animatedValue,
      size: size,
    );
  }

  @override
  String getTooltipText(IndexedData<BaseEntry> entry) {
    // TODO: implement getTooltipText
    throw UnimplementedError();
  }

  @override
  Offset getTooltipAnchorPoint(IndexedData<BaseEntry> entry) {
    // TODO: implement getTooltipAnchorPoint
    throw UnimplementedError();
  }

  @override
  Rect getEntryTouchArea(IndexedData<BaseEntry> entry) {
    throw UnimplementedError();
  }

  void _drawEntryBar({Canvas canvas, int xFactor, double value, Size size}) {
    final xPos = xFactorToX(xFactor);
    final yPos = valueToY(value);

    if (animatedMinValue < 0) {
      if (value >= 0) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(xPos - entryHalfWidth, yPos,
                    xPos + entryHalfWidth, valueToY(0)),
                Radius.circular(1)),
            _paint);
      } else {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTRB(xPos - entryHalfWidth, valueToY(0),
                    xPos + entryHalfWidth, yPos),
                Radius.circular(1)),
            Paint()..color = (config as BarConfig).negativeColor);
      }
    } else {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTRB(xPos - entryHalfWidth, yPos, xPos + entryHalfWidth,
                  size.height),
              Radius.circular(1)),
          _paint);
    }
  }
}
