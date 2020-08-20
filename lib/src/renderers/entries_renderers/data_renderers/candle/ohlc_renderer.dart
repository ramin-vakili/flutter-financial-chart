import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';
import 'package:flutter_financial_chart/src/renderers/entries_renderers/data_renderers/candle/ohlc_mode_renderer.dart';

import 'ohlc_renderable.dart';

/// For adding OHLC data to the chart
class OHLCRenderer extends OHLCModeRenderer<OHLCEntry> {
  OHLCRenderer(
    DataSeries<OHLCEntry> entries, {
    String id,
    OHLCConfig config,
  }) : super(entries, id: id, config: config ?? const OHLCConfig());

  @override
  void updateRenderable(
    DataSeries<OHLCEntry> visibleEntries,
    int leftXFactor,
    int rightXFactor,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) {
    rendererable = OHLCRendererable(
      visibleEntries: visibleEntries,
      lastEntry: entries.last,
      leftXFactor: leftXFactor,
      rightXFactor: rightXFactor,
      touchInfo: touchInfo,
      isIndependentChart: isIndependentChart,
      config: config,
      renderer: this,
    );
  }
}
