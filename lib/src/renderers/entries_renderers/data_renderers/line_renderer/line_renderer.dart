import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';
import 'package:flutter_financial_chart/src/renderers/entries_renderers/data_renderers/data_renderer_config.dart';

import '../data_renderer.dart';
import 'line_renderable.dart';

/// For adding line data to the chart
class LineRenderer extends DataRenderer<BaseEntry> {
  LineRenderer(
    DataSeries<BaseEntry> entries, {
    @required String id,
    LineConfig lineConfig,
  }) : super(
          entries,
          id,
          config: lineConfig ?? const LineConfig(),
        );

  @override
  void updateRenderable(
    DataSeries<BaseEntry> visibleEntries,
    int leftXFactor,
    int rightXFactor,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) {
    if (visibleEntries.isNotEmpty)
      rendererable = LinesRendererable(
        visibleEntries: visibleEntries,
        lastEntry: entries.last,
        leftXFactor: leftXFactor,
        rightXFactor: rightXFactor,
        config: config,
        touchInfo: touchInfo,
        isIndependentChart: isIndependentChart,
        renderer: this,
      );
  }

  @override
  List<double> getMinMaxValue(List<IndexedData<BaseEntry>> visibleEntries) =>
      null;
}

/// Line renderer config
class LineConfig extends DataRendererConfig {
  const LineConfig({
    this.thickness = 1,
    this.color = Colors.white70,
    this.hasArea = false,
    TooltipConfig tooltipConfig,
    LastTickMarkerConfig lastTickMarkerConfig,
  }) : super(
          tooltipConfig: tooltipConfig,
          lastTickMarkerConfig: lastTickMarkerConfig,
        );

  final double thickness;
  final Color color;
  final bool hasArea;
}
