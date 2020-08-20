import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';
import 'package:flutter_financial_chart/src/renderers/entries_renderers/data_renderers/data_renderer_config.dart';

import '../entries_renderer.dart';

abstract class DataRenderer<T extends BaseEntry> extends EntriesRenderer<T> {
  DataRenderer(
    DataSeries<BaseEntry> entries,
    String id, {
    this.config,
  }) : super(entries, id);

  final DataRendererConfig config;

  @override
  void updateRenderable(
    DataSeries<T> visibleEntries,
    int leftXFactor,
    int rightXFactor,
    TouchInfo touchInfo,
    bool isIndependentChart,
  );
}
