import 'package:example/indicator_charts/indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';

class MacdChart extends StatelessWidget {
  const MacdChart({
    Key key,
    this.sharedRange,
    this.positionListener,
    this.barData,
    this.xAxisType,
  }) : super(key: key);

  final SharedRange sharedRange;
  final PositionNotifier positionListener;
  final DataSeries<OHLCEntry> barData;
  final XAxisType xAxisType;

  @override
  Widget build(BuildContext context) {
//    final newData = barData.toList();

    MacdPoints macdPoints = MovingAverage.macd(barData, 7, 20, 4);

    return Chart(
      chartId: "MACD_CHART",
      mainRenderer: BarRenderer(
        macdPoints.divergenceValues,
        id: 'HISTOGRAM',
      ),
      renderers: [
        LineRenderer(macdPoints.signalValues,
            id: 'SIGNAL', lineConfig: LineConfig(color: Colors.redAccent)),
        LineRenderer(macdPoints.macdValues,
            id: 'DIVERG', lineConfig: LineConfig(color: Colors.green)),
      ],
      behaviors: [
        CrossHairBehavior(config: CrossHairConfig(hasTimeLabel: false))
      ],
      xAxis: xAxisType == XAxisType.category
          ? CategoryXAxis(config: CategoryXAxisConfig(hasLabel: false))
          : AbsoluteXAxis(config: AbsoluteXAxisConfig(hasLabel: false)),
      yAxis: YAxis(),
      positionListener: positionListener,
      sharedRange: sharedRange,
    );
  }
}
