import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/axes/axis_config.dart';

import '../../behavior_renderer.dart';
import 'y_axis_rendrable.dart';

/// To add YAxis to the chart
class YAxis extends BehaviorRenderer {
  final YAxisConfig config;

  YAxis({this.config = const YAxisConfig()});

  @override
  void updateRenderable(
    int leftXFactor,
    int rightXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) =>
      rendererable = YAxisRenderable(
        rightXFactor,
        leftXFactor,
        minValue,
        maxValue,
        touchInfo,
        this,
        isIndependentChart,
        config,
      );
}

class YAxisConfig extends AxisConfig {
  const YAxisConfig({bool hasLabel, TextStyle labelStyle})
      : super(
          hasLabel: hasLabel,
          labelStyle: labelStyle,
        );
}
