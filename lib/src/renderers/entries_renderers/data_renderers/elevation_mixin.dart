import 'dart:ui';

import 'package:flutter/material.dart';

mixin ElevationMixin {
  void drawElevationOnBar({
    @required Canvas canvas,
    @required Rect barRect,
    double elevation = 4,
  }) {
    final path = Path()
      ..moveTo(barRect.left, barRect.top)
      ..lineTo(barRect.left, barRect.bottom)
      ..lineTo(barRect.right + elevation, barRect.bottom)
      ..lineTo(barRect.right + elevation, barRect.top)
      ..lineTo(barRect.left, barRect.top);

    canvas.drawShadow(path, Colors.black, elevation, false);
  }
}
