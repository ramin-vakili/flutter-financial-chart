import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

import '../base_renderable.dart';
import 'entries_renderer.dart';

/// Base class for Renderables which has a [DataSeries] to paint
/// called [visibleEntries]
abstract class EntriesRendererable<T extends BaseEntry>
    extends BaseRendererable {
  EntriesRendererable({
    @required this.visibleEntries,
    @required this.lastEntry,
    @required int rightXFactor,
    @required int leftXFactor,
    @required bool isIndependentChart,
    @required TouchInfo touchInfo,
    @required EntriesRenderer renderer,
  }) : super(
          rightXFactor,
          leftXFactor,
          touchInfo,
          renderer,
          isIndependentChart,
        );

  final DataSeries<T> visibleEntries;
  final IndexedData<T> lastEntry;

  int startIndex = 0;
  int endIndex = 1;

  /// Paints [entries] on the [canvas]
  @override
  void paint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    double animatingMinValue,
    double animatingMaxValue,
    IndexedData<BaseEntry> prevLastEntry,
  }) {
    if (visibleEntries.isEmpty) return;
    super.paint(
      canvas: canvas,
      size: size,
      animationsInfo: animationsInfo,
      animatingMinValue: animatingMinValue,
      animatingMaxValue: animatingMaxValue,
    );

    onPaint(
      canvas: canvas,
      size: size,
      animationsInfo: animationsInfo,
      prevLastEntry: prevLastEntry,
    );
  }

  /// Paints [visibleEntries] based on the [animatingMaxValue] [_animatingMinValue]
  @override
  void onPaint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    IndexedData<T> prevLastEntry,
  });
}
