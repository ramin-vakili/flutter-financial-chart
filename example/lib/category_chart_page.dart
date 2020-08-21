import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';

import 'indicator_charts/indicator.dart';
import 'indicator_charts/indicator_frame.dart';
import 'mock_api.dart';

class ChartPage2 extends StatefulWidget {
  @override
  _ChartPage2State createState() => _ChartPage2State();
}

class _ChartPage2State extends State<ChartPage2> {
  DataSeries<OHLCEntry> ohlcValues = DataSeries<OHLCEntry>();

  List<TickEntry> maValues = [];

  List<BaseEntry> markerValues = [];

  final SharedRange _sharedRange = SharedRange();

  final List<Indicator> bottomIndicators = <Indicator>[];

  bool _connected = false;

  int chartType = 1;

  @override
  void initState() {
    super.initState();

    _connectToAPI();
  }

  void _connectToAPI() async {
    _connected = true;

    MockAPI(
        granularity: 10,
        historyForPastSeconds: 10 * 1000,
        onOHLCHistory: (DataSeries<OHLCEntry> history) {
          setState(() {
            ohlcValues = history;
          });
        },
        onNewCandle: (OHLCEntry ohlc) {
          final OHLCEntry entry = ohlc;
          ohlcValues = ohlcValues.clone();
          if (ohlcValues.isNotEmpty && ohlc.epoch == ohlcValues.last.e.epoch) {
            ohlcValues.removeLast();
          }
          setState(() {
            ohlcValues.add(entry);
          });
        });
  }

  PositionNotifier _positionNotifier = PositionNotifier();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          constraints: BoxConstraints.expand(),
          child: _connected
              ? Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: ohlcValues.length < 2
                              ? Container()
                              : Container(
                                  width: double.infinity,
                                  child: Chart(
                                    chartId: "MAIN_CHART",
                                    positionNotifier: _positionNotifier,
                                    behaviors: [
                                      CrossHairBehavior(
                                          config: CrossHairConfig(
                                        hasTimeLabel: false,
                                      ))
                                    ],
                                    xAxis: CategoryXAxis(
                                      config:
                                          CategoryXAxisConfig(hasLabel: false),
                                    ),
                                    yAxis: YAxis(),
                                    sharedRange: _sharedRange,
                                    mainRenderer: chartType % 3 == 1
                                        ? CandleRenderer(
                                            ohlcValues,
                                            id: 'CANDLE',
                                            config: CandleConfig(
                                              tooltipConfig:
                                                  TooltipConfig(enabled: true),
                                              lastTickMarkerConfig:
                                                  LastTickMarkerConfig(
                                                      dotEnabled: true),
                                            ),
                                          )
                                        : chartType % 3 == 2
                                            ? OHLCRenderer(
                                                ohlcValues,
                                                id: 'OHLC',
                                                config: OHLCConfig(
                                                  lastTickMarkerConfig:
                                                      LastTickMarkerConfig(
                                                          dotEnabled: true),
                                                ),
                                              )
                                            : LineRenderer(
                                                ohlcValues,
                                                id: 'LINE',
                                                lineConfig: LineConfig(
                                                    tooltipConfig:
                                                        TooltipConfig(
                                                      enabled: true,
                                                    ),
                                                    thickness: 1,
                                                    hasArea: true,
                                                    lastTickMarkerConfig:
                                                        LastTickMarkerConfig(
                                                            dotEnabled: true)),
                                              ),
                                  ),
                                ),
                        ),
                        ...bottomIndicators
                            .map((Indicator indicator) => Expanded(
                                  flex: 1,
                                  child: Container(
                                    width: double.infinity,
                                    child: IndicatorFrame(
                                      onDelete: () => setState(() =>
                                          bottomIndicators.remove(indicator)),
                                      chartBuilder: () => indicator.getChart(
                                        ohlcValues,
                                        indicator.id,
                                        _positionNotifier,
                                        _sharedRange,
                                      ),
                                    ),
                                  ),
                                )),
                        Container(
                          height: 20,
                          width: double.infinity,
                          child: Chart(
                            chartId: 'XAXIS_CHART',
                            sharedRange: _sharedRange,
                            positionListener: _positionNotifier,
                            behaviors: [
                              CrossHairBehavior(
                                  config: CrossHairConfig(hasTimeLabel: true))
                            ],
                            xAxis: CategoryXAxis(
                                config: CategoryXAxisConfig(hasLabel: true)),
                          ),
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Material(
                        color: Colors.transparent,
                        child: _buildTopButtons(),
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Row _buildTopButtons() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          child: Text('MACD'),
          onPressed: () {
            setState(() {
              bottomIndicators
                  .add(MACDIndicator('MACD', xAxisType: XAxisType.category));
            });
          },
        ),
        FlatButton(
          child: Text('RSI'),
          onPressed: () {
            setState(() {
              bottomIndicators
                  .add(RSIIndicator('RSI', xAxisType: XAxisType.category));
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.show_chart),
          onPressed: () => setState(() => chartType++),
        ),
        IconButton(
          icon: Icon(Icons.outlined_flag),
          onPressed: () {
            final secondLast = ohlcValues[ohlcValues.length - 2];
            setState(() => markerValues
                .add(TickEntry(secondLast.e.epoch, secondLast.e.value)));
          },
        ),
      ],
    );
  }
}
