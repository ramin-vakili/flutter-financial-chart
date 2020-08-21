import 'package:example/samples/sample_line_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

const _samplesList = <Widget>[
  SampleLineChart(),
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SampleLineChart(),
        ),
      ),
    );
  }
}
