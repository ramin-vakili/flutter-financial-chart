import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/axes/axis_config.dart';

import 'absolute_x_axis_renderable.dart';
import 'x_axis.dart';

/// To add X-axis of type absolute to the chart
///
/// In [AbsoluteXAxis] the for showing data on the x-rage the absolute epoch value
/// of them matters.
class AbsoluteXAxis extends XAxis {
  AbsoluteXAxis({this.config = const AbsoluteXAxisConfig()});

  final AbsoluteXAxisConfig config;

  @override
  void updateRenderable(
    int leftXFactor,
    int rightXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) =>
      rendererable = XAxisRenderable(
        rightXFactor,
        leftXFactor,
        minValue,
        maxValue,
        touchInfo,
        this,
        isIndependentChart,
        config,
      );

  @override
  int getXFactor(IndexedData<BaseEntry> t) => t.e.epoch;

  @override
  int getXFactorDelta(IndexedData<BaseEntry> t, IndexedData<BaseEntry> t2) =>
      t2.e.epoch - t.e.epoch;
}

class AbsoluteXAxisConfig extends AxisConfig {
  const AbsoluteXAxisConfig({bool hasLabel, TextStyle labelStyle})
      : super(
          hasLabel: hasLabel,
          labelStyle: labelStyle,
        );
}
