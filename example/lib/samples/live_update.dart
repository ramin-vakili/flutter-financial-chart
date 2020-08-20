import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';

class SampleLineChart extends StatefulWidget {
  const SampleLineChart();

  @override
  _SampleLineChartState createState() => _SampleLineChartState();
}

class _SampleLineChartState extends State<SampleLineChart> {
  final _dataSeries = DataSeries<TickEntry>.fromList(<TickEntry>[
    DateTimeTick(DateTime(2020, 10, 10, 10, 10), 10),
    DateTimeTick(DateTime(2020, 10, 10, 10, 11), 12),
    DateTimeTick(DateTime(2020, 10, 10, 10, 12), 9.6),
    DateTimeTick(DateTime(2020, 10, 10, 10, 13), 10.2),
    DateTimeTick(DateTime(2020, 10, 10, 10, 14), 11.5),
  ]);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Chart(
          chartId: 'line-chart',
          mainRenderer: LineRenderer(
            _dataSeries,
            id: 'line-data',
            lineConfig: LineConfig(tooltipConfig: TooltipConfig()),
          ),
          xAxis: CategoryXAxis(),
          yAxis: YAxis(),
          behaviors: [
            CrossHairBehavior(config: CrossHairConfig(hasTimeLabel: true))
          ],
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () => setState(() {
              _dataSeries
                  .add(DateTimeTick(DateTime(2020, 10, 10, 10, 15), 12.5));
            }),
          ),
        )
      ],
    );
  }
}
