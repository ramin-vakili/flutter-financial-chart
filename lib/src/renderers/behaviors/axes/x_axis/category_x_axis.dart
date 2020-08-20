import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/axes/axis_config.dart';

import 'category_x_axis_renderable.dart';
import 'x_axis.dart';

/// To add X-axis of type category to the chart
///
/// In [CategoryXAxis] the for showing data on the x-rage only the order(index) of them
/// matters. And data entries will be painted with equal distance.
///
/// Useful when want to remove the market gaps.
class CategoryXAxis<T extends BaseEntry> extends XAxis<T> {
  CategoryXAxis({this.config = const CategoryXAxisConfig()});

  final CategoryXAxisConfig config;

  @override
  void updateRenderable(
    int leftXFactor,
    int rightXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    bool isIndependentChart,
  ) {
    rendererable = CategoryXAxisRenderable(
      rightXFactor,
      leftXFactor,
      minValue,
      maxValue,
      touchInfo,
      this,
      isIndependentChart,
      config,
      mainVisibleEntries,
    );
  }

  @override
  int getXFactor(IndexedData<BaseEntry> t) => t.index;

  @override
  int getXFactorDelta(IndexedData<BaseEntry> t, IndexedData<BaseEntry> t2) =>
      t2.index - t.index;
}

class CategoryXAxisConfig extends AxisConfig {
  const CategoryXAxisConfig({bool hasLabel, TextStyle labelStyle})
      : super(
          hasLabel: hasLabel,
          labelStyle: labelStyle,
        );
}
