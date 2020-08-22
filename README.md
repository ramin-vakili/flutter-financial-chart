# Flutter Financial Chart

A Flutter chart package to visualize financial data.

[![Pub Version](https://img.shields.io/pub/v/flutter_financial_chart)](https://pub.dev/packages/flutter_financial_chart)

<br>

| Live update | Switch, tooltip, cross-hair |
| ------------------ | ------------------ |
| <img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/live_update.gif" alt="live_update" width="300" height="400">  | <img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/tooltip_crosshair.gif" alt="tooltip_crosshair" width="300" height="400"> |

| Zoom, scroll | Add/Remove dynamically |
| ------------------ | ------------------ |
| <img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/zoom_scroll.gif" alt="zoom_scroll" width="300" height="400">  | <img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/add_remove_dynamically.gif" alt="add_remove" width="300" height="400"> |


### Features
- Line, Bar, OHLC, CandleStick chart
- Multiple DataSeries on a single chart (Useful for on chart technical indicators)
- Connecting x-axis zoom and scroll range of multiple charts
- Zoom and pan
- Tooltip
- Cross-hair
- Live update
- Animation for tool-tip, live update, y-axis range changes
- SMA, MACD and RSI indicators

<br>

## Getting Started

### 1. Create a simple line chart
A simple line chart:

For charts `x-axis` there are two options:
1. `AbsoluteXAxis`: Uses absolute date values of data entries to align them on x-axis.

2. `CategoryXAxis`: Uses the index (order) of data entries hence data entries will be shown with equal distance. (Useful to remove market close gaps.)

```dart
Chart(
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
      ),
      xAxis: CategoryXAxis(),
      yAxis: YAxis(),
    );
```

<img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/line_chart.png" alt="line_chart" width="400">

Add a `AxisConfig`s to axes customize them:
Updating...

##### Other Data Renderers for now
<pre><code>
    1. BarRenderer
    2. OHLCRenderer
    3. CandleRenderer
</code></pre>

##### Defining config for `Renderer`
Can customize the colors of the `Renderer` by giving a `Config` object to it
and specify colors and sizes there.

```dart
lineConfig: LineConfig(
            tooltipConfig: TooltipConfig(),
            color: Colors.amber,
            hasArea: true,
            thickness: 2,
          )),
```

<img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/line_chart_config_colors.png" alt="line_chart_config_colors" width="400">

### 2. Enabling tooltip

Give the `LineRenderer` a `config` and enable tooltip there:

```dart
Chart(
      mainRenderer: LineRenderer(
        ...
        lineConfig: LineConfig(tooltipConfig: TooltipConfig())),
      ),
      ...
    );
```

<img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/line_chart_tooltip.png" alt="line_chart_tooltip" width="400">

### 3. Adding CrossHair behaviour

Define a `CrossHairBehaviour` to chart's `behaviours` param

```dart
Chart(
      ...
      behaviors: [
        CrossHairBehavior(config: CrossHairConfig(hasTimeLabel: true))
      ],
      ...
    );
```

<img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/line_chart_cross_hair.png" alt="line_chart_cross_hair" width="400">

### 4. Live update
Just keep a reference on the `DataSeries` given to the `Renderer` and  
update the chart widget. The chart will animate in the new data.

```dart
Chart(
          ...
          mainRenderer: LineRenderer(
            _dataSeries,
            ...
          ),
          ...
        )
        
 ...
 
 IconButton(
            icon: Icon(Icons.add),
            onPressed: () => setState(() {
              _dataSeries
                  .add(DateTimeTick(DateTime(2020, 10, 10, 10, 15), 12.5));
            }),
          )
...
```
### 5. Last tick indicator
Add and customize it using `Renderer`'s config:

```dart
CandleRenderer(
      ...
      config: CandleConfig(
        lastTickMarkerConfig: LastTickMarkerConfig(
           dotEnabled: true,
           labelBackgroundColor: Colors.redAccent,
         ),
       ),
 )
```

### 6. Connecting multiple charts to each other
To connect multiple charts to each other so their x-range zoom and scroll be synced:
1. Create an object of `SharedRange`:

```dart
final _sharedRange = SharedRange();
```

2. Give the same `SharedRange` created to the charts:
```dart
Chart(
      chartId: 'chart_1',
      sharedRange: _sharedRange,
      
...

Chart(
      chartId: 'chart_2',
      sharedRange: _sharedRange,
```

**NOTE**: Charts must have the same type of `x-axis`

To connect the charts `CrossHair` functionality, one chart must be the main chart.

1. Create an object of `PositionNotifier`:
```dart
final _positionNotifier = PositionNotifier();
```

2. Give it as `positionNotifier` to the main chart and as `positionListener` to the
   other charts:
```dart
Chart(
      chartId: 'main_chart',
      positionNotifier: positionNotifier,
      
...

Chart(
      chartId: 'other_chart',
      positionListener: positionNotifier,
```

### 7. Technical indicators
1. For adding technical indicator which their y-axis scale is the same as the main chart
   We can add them by and more renderers to the chart's `renderers param

```dart
class LineChartWithMA extends StatelessWidget {
  final dataSeries = DataSeries<TickEntry>.fromList(<TickEntry>[
    DateTimeTick(DateTime(2020, 10, 10, 10, 10), 10),
    DateTimeTick(DateTime(2020, 10, 10, 10, 11), 12),
    DateTimeTick(DateTime(2020, 10, 10, 10, 12), 9.6),
    DateTimeTick(DateTime(2020, 10, 10, 10, 13), 10.2),
    DateTimeTick(DateTime(2020, 10, 10, 10, 14), 10.5),
    DateTimeTick(DateTime(2020, 10, 10, 10, 16), 9.9),
    DateTimeTick(DateTime(2020, 10, 10, 10, 17), 10.0),
    DateTimeTick(DateTime(2020, 10, 10, 10, 18), 10.1),
    DateTimeTick(DateTime(2020, 10, 10, 10, 19), 10.3),
    DateTimeTick(DateTime(2020, 10, 10, 10, 20), 11.5),
    DateTimeTick(DateTime(2020, 10, 10, 10, 21), 10.1),
  ]);

  @override
  Widget build(BuildContext context) {
    final ma = MovingAverage.movingAverage(dataSeries, period: 5);

    return Chart(
      chartId: 'line-chart',
      mainRenderer: LineRenderer(dataSeries, id: 'line-data', lineConfig: LineConfig(
        color: Colors.black38,
        thickness: 2,
        hasArea: true
      )),
      renderers: [
        LineRenderer(ma, id: 'MA-data', lineConfig: LineConfig(
          color: Colors.red,
          thickness: 1
        )),
      ],
      xAxis: CategoryXAxis(),
      yAxis: YAxis(),
    );
  }
}

```

<img src="https://github.com/ramin-vakili/flutter-financial-chart/raw/master/screen_shots/ma_indicator.png" alt="ma_indicator" width="400">

2. For adding indicator with different y-axis scale than the main chart we should
   connect them via a `SharedRange`.

```dart
class RSIChart extends StatelessWidget {
  final dataSeries = DataSeries<TickEntry>.fromList(<TickEntry>[
    DateTimeTick(DateTime(2020, 10, 10, 10, 10), 10),
    DateTimeTick(DateTime(2020, 10, 10, 10, 11), 12),
    DateTimeTick(DateTime(2020, 10, 10, 10, 12), 9.6),
    DateTimeTick(DateTime(2020, 10, 10, 10, 13), 10.2),
    DateTimeTick(DateTime(2020, 10, 10, 10, 14), 10.5),
    DateTimeTick(DateTime(2020, 10, 10, 10, 16), 9.9),
    DateTimeTick(DateTime(2020, 10, 10, 10, 17), 10.0),
    DateTimeTick(DateTime(2020, 10, 10, 10, 18), 10.1),
    DateTimeTick(DateTime(2020, 10, 10, 10, 19), 10.3),
    DateTimeTick(DateTime(2020, 10, 10, 10, 20), 11.5),
    DateTimeTick(DateTime(2020, 10, 10, 10, 21), 10.1),
  ]);

  @override
  Widget build(BuildContext context) {
    final rsi = MovingAverage.rsi(dataSeries, period: 8);

    return Chart(
      chartId: 'rsi-chart',
      mainRenderer: LineRenderer(rsi, id: 'rsi-data'),
      // Give the same SharedRange which is passed to the main chart
      sharedRange: _sharedRange,
      xAxis: CategoryXAxis(),
      yAxis: YAxis(),
    );
  }
}
```

Available indicators for now:
- SMA (Simple Moving Average)
- MACD (Moving Average Convergence Divergence)
- RSI (Relative Strength Index)

### 8. Adding data markers
updating...

### 9. Road map
- [ ] Polishing the painting part
- [ ] More control for customizing colors and sizes through `configs`
- [ ] More technical indicators

