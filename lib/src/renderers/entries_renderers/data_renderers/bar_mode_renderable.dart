import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

import 'data_renderable.dart';
import 'data_renderer.dart';
import 'data_renderer_config.dart';
import 'elevation_mixin.dart';

/// Base class for Renderables with bar mode data which need calculate the width of
/// each entry like Candle, OHLC, Bar.
abstract class BarModeRenderable<T extends BaseEntry>
    extends DataRendererable<T> with ElevationMixin {
  BarModeRenderable({
    @required DataSeries<T> visibleEntries,
    @required IndexedData<T> lastEntry,
    @required int leftXFactor,
    @required int rightXFactor,
    bool isIndependentChart,
    DataRendererConfig config,
    TouchInfo touchInfo,
    DataRenderer renderer,
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

  double calculateEntriesWidth(DataSeries<T> visibleEntries) {
    final firstEntry = visibleEntries.get(0);
    final secondEntry = visibleEntries.get(1);

    int granularity =
        renderer.xFactorDecider.getXFactorDelta(firstEntry, secondEntry);

    entryHalfWidth =
        (granularity / (xFactorDifference / canvasSize.width)) * 0.3;
    return entryHalfWidth;
  }

  double entryHalfWidth;

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    IndexedData<T> prevLastEntry,
  }) {
    super.onPaint(
      canvas: canvas,
      size: size,
      animationsInfo: animationsInfo,
      prevLastEntry: prevLastEntry,
    );
    calculateEntriesWidth(visibleEntries);
  }
}
