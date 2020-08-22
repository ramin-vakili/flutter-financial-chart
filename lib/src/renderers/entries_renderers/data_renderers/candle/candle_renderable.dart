import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';
import 'package:flutter_financial_chart/src/renderers/entries_renderers/data_renderers/candle/ohlc_mode_renderable.dart';

class CandleRendererable extends OHLCModeRendererable {
  CandleRendererable({
    @required DataSeries<OHLCEntry> visibleEntries,
    @required IndexedData<OHLCEntry> lastEntry,
    @required int leftXFactor,
    @required int rightXFactor,
    bool isIndependentChart,
    CandleConfig config,
    TouchInfo touchInfo,
    CandleRenderer renderer,
  })  : _paint = Paint()
          ..color = config.positiveColor
          ..strokeWidth = 0.9
          ..style = PaintingStyle.fill,
        super(
          visibleEntries: visibleEntries,
          lastEntry: lastEntry,
          leftXFactor: leftXFactor,
          rightXFactor: rightXFactor,
          isIndependentChart: isIndependentChart,
          config: config,
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
    calculateEntriesWidth(visibleEntries);

    if (visibleEntries.isEmpty || visibleEntries.length < 2) return;

    for (int i = 0; i < visibleEntries.length - 1; i++) {
      final entry = visibleEntries[i];
      _paint.color = entry.e.close > entry.e.open
          ? (config as CandleConfig).positiveColor
          : (config as CandleConfig).negativeColor;

      final candleX = xFactorToX(renderer.xFactorDecider.getXFactor(entry));
      final candleTop = valueToY(max(entry.e.close, entry.e.open));
      final candleBottom = valueToY(min(entry.e.close, entry.e.open));

      _drawCandleRect(canvas, candleX, entryHalfWidth, candleTop, candleBottom);
      _drawCandleHighLowLine(candleX, entry, canvas, candleTop, candleBottom);
    }

    // Last candle
    final IndexedData<OHLCEntry> lastEntry = visibleEntries.last;
    final candleX = xFactorToX(renderer.xFactorDecider.getXFactor(lastEntry));
    final IndexedData<OHLCEntry> prevLast = prevLastEntry;

    _drawLastCandle(
      prevLast,
      lastEntry,
      animationsInfo.newTickPercent,
      canvas,
      candleX,
      entryHalfWidth,
    );

    super.onPaint(
      canvas: canvas,
      size: size,
      animationsInfo: animationsInfo,
      prevLastEntry: prevLastEntry,
    );
  }

  @override
  Offset getTooltipAnchorPoint(IndexedData<OHLCEntry> entry) => Offset(
      xFactorToX(renderer.xFactorDecider.getXFactor(entry)),
      valueToY(max(entry.e.open, entry.e.close)));

  void _drawCandleRect(
    Canvas canvas,
    double candleX,
    double candleHalfWidth,
    double candleTop,
    double candleBottom,
  ) {
    final candleRect = Rect.fromLTRB(
      candleX - candleHalfWidth,
      candleTop,
      candleX + candleHalfWidth,
      candleBottom,
    );

    final double elevation = (config as CandleConfig).elevation;

    if (elevation > 0) {
      drawElevationOnBar(
        canvas: canvas,
        barRect: candleRect,
        elevation: elevation,
      );
    }
    canvas.drawRect(candleRect, _paint);
  }

  void _drawLastCandle(
    IndexedData<OHLCEntry> prevLast,
    IndexedData<OHLCEntry> lastEntry,
    double newTickAnimationPercent,
    Canvas canvas,
    double candleX,
    double candleHalfWidth,
  ) {
    double candleTop;
    double candleBottom;
    if (prevLast != null &&
        renderer.xFactorDecider.getXFactor(prevLast) ==
            renderer.xFactorDecider.getXFactor(lastEntry)) {
      final animatedClose = ui.lerpDouble(
        prevLast.e.close,
        lastEntry.e.close,
        newTickAnimationPercent,
      );
      candleTop = valueToY(max(animatedClose, lastEntry.e.open));
      candleBottom = valueToY(min(animatedClose, lastEntry.e.open));
      _paint.color = animatedClose > lastEntry.e.open
          ? (config as CandleConfig).positiveColor
          : (config as CandleConfig).negativeColor;
    } else {
      candleTop = valueToY(max(lastEntry.e.close, lastEntry.e.open));
      candleBottom = valueToY(min(lastEntry.e.close, lastEntry.e.open));
    }

    _drawCandleRect(canvas, candleX, candleHalfWidth, candleTop, candleBottom);

    _drawCandleHighLowLine(candleX, lastEntry, canvas, candleTop, candleBottom);
  }

  void _drawCandleHighLowLine(
    double candleX,
    IndexedData<OHLCEntry> entry,
    Canvas canvas,
    double candleTop,
    double candleBottom,
  ) {
    final highPoint = Offset(candleX, valueToY(entry.e.high));
    final lowPoint = Offset(candleX, valueToY(entry.e.low));

    _paint..color = (config as CandleConfig).lineColor;

    canvas.drawLine(lowPoint, Offset(candleX, candleBottom), _paint);
    canvas.drawLine(highPoint, Offset(candleX, candleTop), _paint);
  }
}
