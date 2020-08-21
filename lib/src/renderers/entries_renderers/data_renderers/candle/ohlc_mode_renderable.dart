import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

import '../bar_mode_renderable.dart';
import 'ohlc_mode_renderer.dart';

abstract class OHLCModeRendererable extends BarModeRenderable<OHLCEntry> {
  OHLCModeRendererable({
    @required DataSeries<OHLCEntry> visibleEntries,
    @required IndexedData<OHLCEntry> lastEntry,
    @required int leftXFactor,
    @required int rightXFactor,
    bool isIndependentChart,
    OHLCConfig config,
    TouchInfo touchInfo,
    OHLCModeRenderer renderer,
  }) : super(
          visibleEntries: visibleEntries,
          lastEntry: lastEntry,
          leftXFactor: leftXFactor,
          rightXFactor: rightXFactor,
          isIndependentChart: isIndependentChart,
          config: config,
          touchInfo: touchInfo,
          renderer: renderer,
        );

  @override
  String getTooltipText(IndexedData<OHLCEntry> entry) =>
      'O: ${entry.e.open.toStringAsFixed(2)}    C: ${entry.e.close.toStringAsFixed(2)}\nH: ${entry.e.high.toStringAsFixed(2)}    L: ${entry.e.low.toStringAsFixed(2)}';

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
}
