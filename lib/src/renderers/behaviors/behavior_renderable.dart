import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';

import '../base_renderable.dart';
import 'behavior_renderer.dart';

/// Responsible for painting a frame of its [BehaviorRenderer].
///
/// Since [BehaviorRenderer]s don't have entries to paint they are not involved
/// in determining [minValue] and [maxValue] inside a chart frame.
/// These values which are already determined by other [EntriesRenderer]s present
/// in the chart, are passed to a [BehaviorRendererable] through its constructor.
abstract class BehaviorRendererable extends BaseRendererable {
  BehaviorRendererable(
    int rightXFactor,
    int leftXFactor,
    double minValue,
    double maxValue,
    TouchInfo touchInfo,
    BehaviorRenderer renderer,
    bool isIndependentChart,
    this.config,
  ) : super(
          rightXFactor,
          leftXFactor,
          touchInfo,
          renderer,
          isIndependentChart,
        );

  final BehaviorConfig config;

  /// Paints this behaviour by calling [onPaint]
  void paint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    double animatingMinValue,
    double animatingMaxValue,
  }) {
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
    );
  }

  @override
  void onPaint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
  });
}
