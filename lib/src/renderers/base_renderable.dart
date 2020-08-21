import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';

import 'base_renderer.dart';

/// Base class for all Renderables for holding the common fields.
/// A class responsible for painting a frame of its [renderer]
///
/// The [renderer] owning this Rendererable will update it and call its [BaseRendererable.paint]
abstract class BaseRendererable {
  BaseRendererable(
    this.rightXFactor,
    this.leftXFactor,
    this.touchInfo,
    this.renderer,
    this.isIndependentChart,
  );

  final BaseRenderer renderer;

  /// Top and bottom padding, vertical conversion calculation use these values
  static const topPadding = 10.0;
  static const bottomPadding = 10.0;

  /// Indicates whether this frame of drawing chart belongs to a dependent chart or not
  final bool isIndependentChart;

  /// Animated values in a frame
  double animatedMaxValue;
  double animatedMinValue;

  /// Value difference in a frame
  double get animatedValueDifference => animatedMaxValue - animatedMinValue;

  /// Touch info for long press and tap
  final TouchInfo touchInfo;

  /// XFactor of this frame
  final int rightXFactor;
  final int leftXFactor;

  /// Range of XFactor in a frame
  int get xFactorDifference => rightXFactor - leftXFactor;

  /// Frame canvas size
  Size canvasSize;

  /// Converts value to y considering the padding
  double valueToY(double value) => _valueToYWithPadding(
        value,
        animatedMaxValue,
        animatedMinValue,
      );

  /// Converts XFactor to x coordinate
  double xFactorToX(int xFactor) => lerpDouble(
        0,
        canvasSize.width,
        (xFactor - leftXFactor) / xFactorDifference,
      );

  /// Converts x coordinate to XFactor value
  int xToXFactor(double x) =>
      x * xFactorDifference ~/ canvasSize.width + leftXFactor;

  /// Drawing range including top/bottom padding
  double get verticalDrawingRange =>
      canvasSize.height - topPadding - bottomPadding;

  double _valueToYWithPadding(
    double value,
    double maxValue,
    double minValue,
  ) {
    final drawingRange = verticalDrawingRange;
    final valueRange = maxValue - minValue;

    if (valueRange == 0) return topPadding + drawingRange / 2;

    final valueToBottomFraction = (value - minValue) / valueRange;
    final valueToTopFraction = 1 - valueToBottomFraction;

    final pxFromTop = valueToTopFraction * drawingRange;

    return topPadding + pxFromTop;
  }

  /// Converts y coordinate to value considering the padding
  double yToValue(double y) =>
      animatedMinValue -
      (((y - topPadding - verticalDrawingRange) / verticalDrawingRange) *
          animatedValueDifference);

  /// Set the variables up and paint the frame by calling [onPaint]
  /// The sub-classes should call their [onPaint] based on the their own
  /// parameters
  void paint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    double animatingMinValue,
    double animatingMaxValue,
  }) {
    canvasSize = size;
    this.animatedMaxValue = animatingMaxValue;
    this.animatedMinValue = animatingMinValue;
  }

  /// Paints this frame on the canvas
  void onPaint({
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
  });
}
