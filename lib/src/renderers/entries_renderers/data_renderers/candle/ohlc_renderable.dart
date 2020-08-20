import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

import '../bar_mode_renderable.dart';
import 'ohlc_mode_renderer.dart';
import 'ohlc_renderer.dart';

class OHLCRendererable extends BarModeRenderable<OHLCEntry> {
  OHLCRendererable({
    @required DataSeries<OHLCEntry> visibleEntries,
    @required IndexedData<BaseEntry> lastEntry,
    @required int leftXFactor,
    @required int rightXFactor,
    bool isIndependentChart,
    OHLCConfig config,
    TouchInfo touchInfo,
    OHLCRenderer renderer,
  })  : _paint = Paint()
          ..color = config.positiveColor
          ..strokeWidth = 1.4
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
    super.onPaint(
      canvas: canvas,
      size: size,
      animationsInfo: animationsInfo,
      prevLastEntry: prevLastEntry,
    );

    if (visibleEntries.isEmpty || visibleEntries.length < 3) return;

    final OHLCConfig ohlcConfig = config;

    for (int i = 0; i < visibleEntries.length - 1; i++) {
      final entry = visibleEntries[i];
      _paint.color = entry.e.close > entry.e.open
          ? ohlcConfig.positiveColor
          : ohlcConfig.negativeColor;

      final ohlcX = xFactorToX(renderer.xFactorDecider.getXFactor(entry));

      _drawOHLCOpenCloseLines(canvas, ohlcX, entryHalfWidth,
          valueToY(entry.e.close), valueToY(entry.e.open));

      _drawOHLCHighLowLine(ohlcX, entry, canvas);
    }

    // Last candle
    final IndexedData<OHLCEntry> lastEntry = visibleEntries.last;
    final ohlcX = xFactorToX(renderer.xFactorDecider.getXFactor(lastEntry));
    final IndexedData<OHLCEntry> prevLast = prevLastEntry;

    _drawLastOHLC(
      prevLast,
      lastEntry,
      animationsInfo.newTickPercent,
      canvas,
      ohlcX,
      entryHalfWidth,
    );
  }

  @override
  String getTooltipText(IndexedData<OHLCEntry> entry) =>
      'Open:${entry.e.open}\nClose:${entry.e.close}\nHigh:${entry.e.high}\nLow:${entry.e.low}';

  @override
  Offset getTooltipAnchorPoint(IndexedData<OHLCEntry> entry) => Offset(
      xFactorToX(renderer.xFactorDecider.getXFactor(entry)),
      valueToY(entry.e.high));

  @override
  Rect getEntryTouchArea(IndexedData<OHLCEntry> entry) {
    calculateEntriesWidth(visibleEntries);
    return Rect.fromLTRB(
      xFactorToX(renderer.xFactorDecider.getXFactor(entry)) - entryHalfWidth,
      valueToY(entry.e.high),
      xFactorToX(renderer.xFactorDecider.getXFactor(entry)) + entryHalfWidth,
      valueToY(entry.e.low),
    );
  }

  void _drawOHLCOpenCloseLines(Canvas canvas, double candleX,
      double ohlcHalfWidth, double closeY, double openY) {
    canvas.drawLine(
        Offset(candleX - ohlcHalfWidth, openY), Offset(candleX, openY), _paint);
    canvas.drawLine(Offset(candleX + ohlcHalfWidth, closeY),
        Offset(candleX, closeY), _paint);
  }

  void _drawLastOHLC(
    IndexedData<OHLCEntry> prevLast,
    IndexedData<OHLCEntry> lastEntry,
    double newTickAnimationPercent,
    Canvas canvas,
    double candleX,
    double candleHalfWidth,
  ) {
    double closeY;

    if (prevLast != null &&
        renderer.xFactorDecider.getXFactor(prevLast) ==
            renderer.xFactorDecider.getXFactor(lastEntry)) {
      final animatedClose = lerpDouble(
        prevLast.e.close,
        lastEntry.e.close,
        newTickAnimationPercent,
      );
      closeY = valueToY(animatedClose);
      _paint.color = animatedClose > lastEntry.e.open
          ? (config as OHLCConfig).positiveColor
          : (config as OHLCConfig).negativeColor;
    } else {
      closeY = valueToY(lastEntry.e.close);
    }
    _drawOHLCOpenCloseLines(
        canvas, candleX, candleHalfWidth, closeY, valueToY(lastEntry.e.open));

    _drawOHLCHighLowLine(candleX, lastEntry, canvas);
  }

  void _drawOHLCHighLowLine(
      double candleX, IndexedData<OHLCEntry> entry, Canvas canvas) {
    final highPoint = Offset(candleX, valueToY(entry.e.high));
    final lowPoint = Offset(candleX, valueToY(entry.e.low));

    canvas.drawLine(lowPoint, highPoint, _paint);
  }
}
