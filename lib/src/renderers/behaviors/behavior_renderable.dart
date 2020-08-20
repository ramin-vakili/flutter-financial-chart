import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';

import '../base_renderable.dart';
import 'behavior_renderer.dart';

/// Responsible for painting a frame of its [BehaviorRenderer] for a subset of
/// [BehaviorRenderer]'s entries called [visibleEntries] inside [paint] method
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

  /// Paints [entries] on the [canvas]
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

  /// Paints [visibleEntries] based on the [animatingMaxValue] [_animatingMinValue]
  @override
  void onPaint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
  });
}
