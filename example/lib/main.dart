import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SafeArea(child: Scaffold(body: SampleLineChart())),
    );
  }
}

class SampleLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Chart(
      chartId: 'line-chart',
      mainRenderer: LineRenderer(
        DataSeries<TickEntry>.fromList(<TickEntry>[
          DateTimeTick(DateTime(2020, 10, 10, 10, 10), 10),
          DateTimeTick(DateTime(2020, 10, 10, 10, 11), 12),
          DateTimeTick(DateTime(2020, 10, 10, 10, 12), 9.6),
          DateTimeTick(DateTime(2020, 10, 10, 10, 13), 10.2),
          DateTimeTick(DateTime(2020, 10, 10, 10, 14), 11.5),
        ]),
        id: 'line-data',
        lineConfig: LineConfig(
          tooltipConfig: TooltipConfig(),
          color: Colors.amber,
          hasArea: true,
          thickness: 2,
        ),
      ),
      xAxis: CategoryXAxis(),
      yAxis: YAxis(),
      behaviors: [
        CrossHairBehavior(config: CrossHairConfig(hasTimeLabel: true))
      ],
    );
  }
}
