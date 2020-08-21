import 'package:flutter/material.dart';

abstract class DataRendererConfig {
  final TooltipConfig tooltipConfig;
  final LastTickMarkerConfig lastTickMarkerConfig;

  const DataRendererConfig({this.tooltipConfig, this.lastTickMarkerConfig});
}

class TooltipConfig {
  const TooltipConfig({
    this.enabled = true,
    this.backgroundColor = const Color(0xFF5F6178),
    this.labelStyle = const TextStyle(color: Colors.white, fontSize: 10),
  });

  final bool enabled;
  final Color backgroundColor;
  final TextStyle labelStyle;
}

class LastTickMarkerConfig {
  const LastTickMarkerConfig({
    this.textColor = Colors.white70,
    this.labelBackgroundColor = const Color(0xFFA32110),
    this.labelWidth = 64,
    this.labelHeight = 24,
    this.dotEnabled = false,
  });

  final Color textColor;
  final Color labelBackgroundColor;
  final double labelWidth;
  final double labelHeight;
  final bool dotEnabled;
}
