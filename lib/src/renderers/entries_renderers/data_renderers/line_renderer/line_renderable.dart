import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

import '../data_renderable.dart';
import 'line_renderer.dart';

class LinesRendererable extends DataRendererable<BaseEntry> {
  LinesRendererable({
    @required DataSeries<BaseEntry> visibleEntries,
    @required IndexedData<BaseEntry> lastEntry,
    @required int leftXFactor,
    @required int rightXFactor,
    this.touchInfo,
    LineRenderer renderer,
    bool isIndependentChart,
    LineConfig config,
  })  : _paint = Paint()
          ..color = config.color ?? Colors.white60
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true
          ..strokeWidth = config.thickness,
        super(
          visibleEntries: visibleEntries,
          lastEntry: lastEntry,
          leftXFactor: leftXFactor,
          rightXFactor: rightXFactor,
          isIndependentChart: isIndependentChart,
          config: config,
          touchInfo: touchInfo,
          renderer: renderer,
        );

  final Paint _paint;
  final TouchInfo touchInfo;

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    IndexedData<BaseEntry> prevLastEntry,
  }) {
    super.onPaint(
      canvas: canvas,
      size: size,
      animationsInfo: animationsInfo,
      prevLastEntry: prevLastEntry,
    );

    Path path = Path();

    bool movedToStartPoint = false;

    for (int i = 0; i < visibleEntries.length - 1; i++) {
      final item = visibleEntries[i];
      if (item.e.value.isNaN) continue;

      if (!movedToStartPoint) {
        movedToStartPoint = true;
        path.moveTo(
          xFactorToX(renderer.xFactorDecider.getXFactor(item)),
          valueToY(item.e.value),
        );
        continue;
      }

      final x = xFactorToX(renderer.xFactorDecider.getXFactor(item));
      final y = valueToY(item.e.value);
      path.lineTo(x, y);
    }

    if (prevLastEntry != null &&
        renderer.xFactorDecider.getXFactor(prevLastEntry) ==
            renderer.xFactorDecider.getXFactor(visibleEntries.last)) {
      // Chart's first load
      final IndexedData<BaseEntry> lastEntry = visibleEntries.last;
      path.lineTo(
          xFactorToX(renderer.xFactorDecider.getXFactor(lastEntry)),
          valueToY(ui.lerpDouble(
            prevLastEntry.e.value,
            lastEntry.e.value,
            animationsInfo.newTickPercent,
          )));
    } else {
      _addNewTickTpPath(path, animationsInfo.newTickPercent);
    }

    canvas.drawPath(path, _paint);

    if ((config as LineConfig).hasArea) {
      _drawArea(
        canvas,
        size,
        linePath: path,
        lineEndX: xFactorToX(renderer.xFactorDecider.getXFactor(lastEntry)),
      );
    }
  }

  @override
  String getTooltipText(IndexedData<BaseEntry> entry) =>
      '(${entry.e.value.toStringAsFixed(4)})';

  @override
  ui.Offset getTooltipAnchorPoint(IndexedData<BaseEntry> entry) => ui.Offset(
      xFactorToX(renderer.xFactorDecider.getXFactor(entry)),
      valueToY(entry.e.value));

  @override
  ui.Rect getEntryTouchArea(IndexedData<BaseEntry> entry) => Rect.fromCenter(
        center: getTooltipAnchorPoint(entry),
        width: 4,
        height: 4,
      );

  void _drawArea(
    Canvas canvas,
    Size size, {
    Path linePath,
    double lineEndX,
  }) {
    final areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.01),
        ],
      );

    linePath.lineTo(
      lineEndX,
      size.height,
    );
    linePath.lineTo(0, size.height);

    canvas.drawPath(
      linePath,
      areaPaint,
    );
  }

  void _addNewTickTpPath(Path path, double newTickAnimationPercent) {
    final IndexedData<BaseEntry> lastEntry = visibleEntries.last;
    final IndexedData<BaseEntry> preLastEntry =
        visibleEntries.get(visibleEntries.length - 2);

    if (lastEntry.e.value.isNaN) return;

    path.lineTo(
      ui.lerpDouble(
        xFactorToX(renderer.xFactorDecider.getXFactor(preLastEntry)),
        xFactorToX(renderer.xFactorDecider.getXFactor(lastEntry)),
        newTickAnimationPercent,
      ),
      valueToY(ui.lerpDouble(
        preLastEntry.e.value,
        lastEntry.e.value,
        newTickAnimationPercent,
      )),
    );
  }
}
