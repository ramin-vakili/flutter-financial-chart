import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/x_factor_decider.dart';

/// Base class of all Renderers. A renderer manages updates of its Renderable for each frame
abstract class BaseRenderer {
  /// The ID of the chart this renderer belongs to
  String chartId;

  @protected
  XFactorDecider mXFactorDecider;

  /// Indicated whether we are in absolute or category mode on x-range,
  /// Helps in x-range conversions,
  XFactorDecider get xFactorDecider => mXFactorDecider;

  void setXFactorDecider(XFactorDecider xFactorDecider) =>
      mXFactorDecider = xFactorDecider;
}
