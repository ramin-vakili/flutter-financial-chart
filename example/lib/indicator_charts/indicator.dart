import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';

import 'macd_chart.dart';
import 'rsi_chart.dart';

abstract class Indicator {
  Indicator(this.id, {this.xAxisType = XAxisType.category});

  final String id;
  final XAxisType xAxisType;

  Widget getChart(
    DataSeries<BaseEntry> entries,
    String id,
    PositionNotifier positionListener,
    SharedRange sharedRange,
  );
}

class MACDIndicator extends Indicator {
  MACDIndicator(
    String id, {
    XAxisType xAxisType = XAxisType.category,
  }) : super(id, xAxisType: xAxisType);

  @override
  Widget getChart(
    DataSeries<BaseEntry> entries,
    String id,
    PositionNotifier positionListener,
    SharedRange sharedRange,
  ) =>
      MacdChart(
        barData: entries,
        sharedRange: sharedRange,
        positionListener: positionListener,
        xAxisType: xAxisType,
      );
}

class RSIIndicator extends Indicator {
  RSIIndicator(
    String id, {
    XAxisType xAxisType = XAxisType.category,
  }) : super(id, xAxisType: xAxisType);

  @override
  Widget getChart(
    DataSeries<BaseEntry> entries,
    String id,
    PositionNotifier positionListener,
    SharedRange sharedRange,
  ) =>
      RsiChart(
        entries: entries,
        sharedRange: sharedRange,
        positionListener: positionListener,
        xAxisType: xAxisType,
      );
}

enum XAxisType {
  absolute,
  category,
}
