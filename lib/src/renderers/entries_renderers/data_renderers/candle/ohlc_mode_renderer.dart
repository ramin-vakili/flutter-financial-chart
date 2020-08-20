import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';
import 'package:flutter_financial_chart/src/renderers/entries_renderers/data_renderers/data_renderer_config.dart';

import '../data_renderer.dart';

/// For adding OHLC data to the chart
abstract class OHLCModeRenderer<T extends OHLCEntry> extends DataRenderer<T> {
  OHLCModeRenderer(
    DataSeries<OHLCEntry> entries, {
    String id,
    OHLCConfig config,
  }) : super(entries, id, config: config ?? const OHLCConfig());

  @override
  List<double> getMinMaxValue(List<IndexedData<OHLCEntry>> visibleEntries) {
    final Iterable<double> maxValuesInAction = visibleEntries
        .where((indexedData) => !indexedData.e.high.isNaN)
        .map((indexedData) => indexedData.e.high);

    if (maxValuesInAction.isEmpty) return null;

    final Iterable<double> minValuesInAction = visibleEntries
        .where((indexedData) => !indexedData.e.low.isNaN)
        .map((indexedData) => indexedData.e.low);

    if (minValuesInAction.isEmpty) return null;

    return <double>[
      minValuesInAction.reduce(min),
      maxValuesInAction.reduce(max)
    ];
  }
}

class OHLCConfig extends DataRendererConfig {
  const OHLCConfig({
    Color positiveColor,
    Color negativeColor,
    TooltipConfig tooltipConfig,
    LastTickMarkerConfig lastTickMarkerConfig,
  })  : positiveColor = positiveColor ?? const Color(0xFF488c5b),
        negativeColor = negativeColor ?? const Color(0xFFba4e4e),
        super(
          tooltipConfig: tooltipConfig,
          lastTickMarkerConfig: lastTickMarkerConfig,
        );

  final Color positiveColor;
  final Color negativeColor;
}
