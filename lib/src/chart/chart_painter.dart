import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/behavior_renderer.dart';
import 'package:flutter_financial_chart/src/renderers/entries_renderers/entries_renderer.dart';

/// Responsible to pass canvas info to the [Renderer]s so they can paint their
/// own data.
class ChartPainter extends CustomPainter {
  ChartPainter({
    this.animatingMinValue,
    this.animatingMaxValue,
    this.mainRenderer,
    this.renderers,
    this.behaviors,
    this.axes,
    this.animationsInfo,
  });

  final EntriesRenderer mainRenderer;
  final List<EntriesRenderer> renderers;
  final List<BehaviorRenderer> behaviors;
  final List<BehaviorRenderer> axes;

  final AnimationsInfo animationsInfo;

  final double animatingMinValue;
  final double animatingMaxValue;

  @override
  void paint(Canvas canvas, Size size) {
//    final stopwatch = Stopwatch()..start();
    _paintAxes(canvas, size);

    _paintRenderers(canvas, size);

    _paintBehaviors(canvas, size);
//    print('paint() executed in ${stopwatch.elapsed}');
  }

  void _paintRenderers(Canvas canvas, Size size) {
    mainRenderer?.paint(
        canvas, size, animationsInfo, animatingMinValue, animatingMaxValue);
    if (renderers != null && renderers.isNotEmpty) {
      for (final renderer in renderers) {
        renderer?.paint(
          canvas,
          size,
          animationsInfo,
          animatingMinValue,
          animatingMaxValue,
        );
      }
    }
  }

  void _paintAxes(Canvas canvas, Size size) {
    if (axes != null && axes.isNotEmpty) {
      for (final axis in axes) {
        axis?.paint(
          canvas,
          size,
          animationsInfo,
          animatingMinValue,
          animatingMaxValue,
        );
      }
    }
  }

  void _paintBehaviors(Canvas canvas, Size size) {
    if (behaviors != null && behaviors.isNotEmpty) {
      for (final behavior in behaviors) {
        behavior?.paint(
          canvas,
          size,
          animationsInfo,
          animatingMinValue,
          animatingMaxValue,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
