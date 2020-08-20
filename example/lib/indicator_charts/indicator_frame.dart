import 'package:flutter/material.dart';

typedef ChartBuilder = Widget Function();

class IndicatorFrame extends StatelessWidget {
  const IndicatorFrame({
    Key key,
    this.onDelete,
    this.chartBuilder,
  }) : super(key: key);

  final VoidCallback onDelete;
  final ChartBuilder chartBuilder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(),
          child: chartBuilder(),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        )
      ],
    );
  }
}
