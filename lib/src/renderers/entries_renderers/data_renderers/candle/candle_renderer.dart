import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';
import 'package:flutter_financial_chart/src/renderers/entries_renderers/data_renderers/data_renderer_config.dart';

import 'candle_renderable.dart';
import 'ohlc_mode_renderer.dart';

/// For adding Candle data to the chart
class CandleRenderer extends OHLCModeRenderer<OHLCEntry> {
  CandleRenderer(
    DataSeries<OHLCEntry> entries, {
    @required String id,
    CandleConfig config,
  }) : super(entries, id: id, config: config ?? const CandleConfig());

  @override
  void updateRenderable(
    DataSeries<OHLCEntry> visibleEntries,
    int leftXFactor,
    int rightXFactor,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) {
    rendererable = CandleRendererable(
      visibleEntries: visibleEntries,
      lastEntry: entries.last,
      leftXFactor: leftXFactor,
      rightXFactor: rightXFactor,
      config: config,
      isIndependentChart: isIndependentChart,
      touchInfo: touchInfo,
      renderer: this,
    );
  }
}

class CandleConfig extends OHLCConfig {
  const CandleConfig({
    Color positiveColor,
    Color negativeColor,
    this.lineColor = Colors.blueGrey,
    TooltipConfig tooltipConfig,
    LastTickMarkerConfig lastTickMarkerConfig,
  }) : super(
          positiveColor: positiveColor,
          negativeColor: negativeColor,
          tooltipConfig: tooltipConfig,
          lastTickMarkerConfig: lastTickMarkerConfig,
        );

  final Color lineColor;
}
