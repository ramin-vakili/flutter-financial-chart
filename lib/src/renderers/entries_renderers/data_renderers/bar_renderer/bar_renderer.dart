import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';
import 'package:flutter_financial_chart/src/renderers/entries_renderers/data_renderers/data_renderer_config.dart';

import 'bar_renderable.dart';

/// For adding Bar data to the chart
class BarRenderer extends DataRenderer<BaseEntry> {
  BarRenderer(
    DataSeries<BaseEntry> entries, {
    @required String id,
    BarConfig config,
  }) : super(entries, id, config: config ?? const BarConfig());

  @override
  void updateRenderable(
    DataSeries<BaseEntry> visibleEntries,
    int leftXFactor,
    int rightXFactor,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) {
    rendererable = BarRendererable(
      visibleEntries: visibleEntries,
      lastEntry: entries.last,
      leftXFactor: leftXFactor,
      rightXFactor: rightXFactor,
      barConfig: config,
      isIndependentChart: isIndependentChart,
      renderer: this,
    );
  }

  @override
  List<double> getMinMaxValue(List<IndexedData<BaseEntry>> visibleEntries) =>
      null;
}

class BarConfig extends DataRendererConfig {
  const BarConfig({
    this.positiveColor = Colors.green,
    this.negativeColor = const Color(0xFFba4e4e),
    TooltipConfig tooltipConfig,
    LastTickMarkerConfig lastTickMarkerConfig,
  }) : super(
          tooltipConfig: tooltipConfig,
          lastTickMarkerConfig: lastTickMarkerConfig,
        );

  final Color positiveColor;
  final Color negativeColor;
}
