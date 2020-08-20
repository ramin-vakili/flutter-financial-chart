import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

import '../entries_renderer.dart';
import 'marker_renderable.dart';

/// For painting [MarkerRendererable] on the canvas
class MarkerRenderer extends EntriesRenderer {
  MarkerRenderer(DataSeries<BaseEntry> entries, String id) : super(entries, id);

  @override
  void updateRenderable(
    DataSeries<BaseEntry> visibleEntries,
    int leftXFactor,
    int rightXFactor,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) {
    rendererable = MarkerRendererable(
      visibleEntries: visibleEntries,
      lastEntry: entries.last,
      leftXFactor: leftXFactor,
      rightXFactor: rightXFactor,
      isIndependentChart: isIndependentChart,
      touchInfo: touchInfo,
      renderer: this,
    );
  }

  @override
  List<double> getMinMaxValue(List<IndexedData<BaseEntry>> visibleEntries) =>
      null;
}
