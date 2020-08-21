import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/behavior_renderer.dart';

abstract class AxisConfig extends BehaviorConfig {
  const AxisConfig({
    bool hasLabel,
    TextStyle labelStyle,
    Color lineColor,
  })  : this.hasLabel = hasLabel ?? true,
        this.labelStyle =
            labelStyle ?? const TextStyle(fontSize: 10, color: Colors.black38),
        this.lineColor = lineColor ?? Colors.black12;

  final bool hasLabel;
  final TextStyle labelStyle;
  final Color lineColor;
}
