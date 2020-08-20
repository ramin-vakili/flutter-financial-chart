import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';

import '../behavior_renderer.dart';
import 'crosshair_renderable.dart';

/// To add cross-hair behavior ro the chart
class CrossHairBehavior extends BehaviorRenderer {
  CrossHairBehavior({this.config = const CrossHairConfig()});

  final CrossHairConfig config;

  @override
  void updateRenderable(
    int leftXFactor,
    int rightXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) =>
      rendererable = CrossHairRenderable(
        mainVisibleEntries,
        rightXFactor,
        leftXFactor,
        minValue,
        maxValue,
        touchInfo,
        this,
        isIndependentChart,
        config: config,
      );
}

class CrossHairConfig extends BehaviorConfig {
  const CrossHairConfig({
    this.labelBackgroundColor = Colors.blueGrey,
    this.labelTextColor = Colors.white70,
    this.labelWidth = 60,
    this.labelHalfHeight = 16,
    this.hasTimeLabel = false,
    this.hasValueLabel = true,
  });

  final Color labelBackgroundColor;
  final Color labelTextColor;
  final double labelWidth;
  final double labelHalfHeight;

  final bool hasTimeLabel;
  final bool hasValueLabel;
}
