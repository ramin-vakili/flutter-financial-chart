import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';

import 'indicator.dart';

class RsiChart extends StatelessWidget {
  const RsiChart({
    Key key,
    this.sharedRange,
    this.positionListener,
    this.entries,
    this.xAxisType,
  }) : super(key: key);

  final SharedRange sharedRange;
  final PositionNotifier positionListener;
  final DataSeries<BaseEntry> entries;
  final XAxisType xAxisType;

  @override
  Widget build(BuildContext context) {
    final rsi = MovingAverage.rsi(entries, 14);
    return Chart(
      chartId: "RSI_CHART",
      behaviors: [
        CrossHairBehavior(config: CrossHairConfig(hasTimeLabel: false))
      ],
      xAxis: xAxisType == XAxisType.category
          ? CategoryXAxis(config: CategoryXAxisConfig(hasLabel: false))
          : AbsoluteXAxis(config: AbsoluteXAxisConfig(hasLabel: false)),
      yAxis: YAxis(),
      mainRenderer: LineRenderer(rsi, id: "RSI"),
      positionListener: positionListener,
      sharedRange: sharedRange,
    );
  }
}
