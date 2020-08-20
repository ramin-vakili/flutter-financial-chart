import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

import '../entries_renderable.dart';
import 'marker_renderer.dart';

class MarkerRendererable extends EntriesRendererable<BaseEntry> {
  MarkerRendererable({
    @required DataSeries<BaseEntry> visibleEntries,
    @required IndexedData<BaseEntry> lastEntry,
    @required int leftXFactor,
    @required int rightXFactor,
    Color lineColor,
    bool isIndependentChart,
    TouchInfo touchInfo,
    MarkerRenderer renderer,
  }) : super(
          visibleEntries: visibleEntries,
          lastEntry: lastEntry,
          leftXFactor: leftXFactor,
          rightXFactor: rightXFactor,
          touchInfo: touchInfo,
          renderer: renderer,
          isIndependentChart: isIndependentChart,
        );

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    IndexedData<BaseEntry> prevLastEntry,
  }) {
    final icon = Icons.flag;
    var builder = ParagraphBuilder(ParagraphStyle(
      fontFamily: icon.fontFamily,
    ))
      ..addText(String.fromCharCode(icon.codePoint));
    var para = builder.build();
    para.layout(const ParagraphConstraints(width: 64));
    for (final item in visibleEntries) {
      canvas.drawParagraph(
        para,
        Offset(xFactorToX(item.index) - 6, valueToY(item.e.value) - 16),
      );
    }
  }
}
