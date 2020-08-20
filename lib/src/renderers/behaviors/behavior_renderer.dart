import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';

import '../base_renderer.dart';
import 'behavior_renderable.dart';

/// Hold's the information of a data series, Updates and paint's [rendererable]
/// When the chart requires update
abstract class BehaviorRenderer<T extends BaseEntry> extends BaseRenderer {
  BehaviorRenderer();

  DataSeries<T> mainVisibleEntries;

  BehaviorRendererable rendererable;

  /// Updates visible entries for this renderer
  void update({
    @required int leftXFactor,
    @required int rightXFactor,
    @required double minValue,
    @required double maxValue,
    TouchInfo touchInfo,
    bool isIndependentChart,
    DataSeries<T> mainVisibleEntries,
  }) {
    assert(leftXFactor < rightXFactor);
    this.mainVisibleEntries = mainVisibleEntries;
    updateRenderable(
      leftXFactor,
      rightXFactor,
      minValue,
      maxValue,
      touchInfo,
      isIndependentChart,
    );
  }

  /// Updates [rendererable] with the new [visibleEntries] and XFactor boundaries
  void updateRenderable(
    int leftXFactor,
    int rightXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    bool isIndependentChart,
  );

  /// Paints [rendererable]'s data on the [canvas]
  /// Will get called after [updateRenderable] method
  void paint(
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    double animatingMinValue,
    double animatingMaxValue,
  ) =>
      rendererable?.paint(
        canvas: canvas,
        size: size,
        animationsInfo: animationsInfo,
        animatingMinValue: animatingMinValue,
        animatingMaxValue: animatingMaxValue,
      );
}

abstract class BehaviorConfig {
  const BehaviorConfig();
}
