import 'dart:async';
import 'dart:math';

import 'package:flutter_financial_chart/flutter_financial_chart.dart';

typedef OnNewCandle = void Function(OHLCEntry);
typedef OnOHLCHistory = void Function(DataSeries<OHLCEntry>);

const double trendDirectionChance = 0.56;

class MockAPI {
  MockAPI({
    this.onNewCandle,
    this.onOHLCHistory,
    this.granularity,
    int historyForPastSeconds = 1000,
  }) {
    _intervalStartTime = DateTime.now()
        .toUtc()
        .subtract(Duration(seconds: historyForPastSeconds));

    if (onOHLCHistory != null) {
      DateTime now = DateTime.now()
          .toUtc()
          .subtract(Duration(seconds: historyForPastSeconds));
      final DataSeries<OHLCEntry> ohlcValues = DataSeries<OHLCEntry>();
      for (int i = 0; i < historyForPastSeconds; i++) {
        now = now.add(Duration(seconds: 1));
        _generateOHLC(now, (OHLCEntry ohlc) {
          final OHLCEntry entry = ohlc;
          if (ohlcValues.isNotEmpty && ohlc.epoch == ohlcValues.last.e.epoch) {
            ohlcValues.removeLast();
          }
          ohlcValues.add(entry);
        });
      }

      onOHLCHistory(ohlcValues);
    }

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _generateOHLC(DateTime.now().toUtc(), onNewCandle),
    );
  }

  Random _random = Random();

  Timer _timer;

  double _max = 201;
  double _min = 199;

  double _value = 200;

  DateTime _intervalStartTime;

  final int granularity;

  double _open;

  double _low;

  double _high;

  bool _trendToUp = true;

  final OnNewCandle onNewCandle;

  final OnOHLCHistory onOHLCHistory;

  bool _decideBasedOnTrend() => _trendToUp
      ? _random.nextDouble() < trendDirectionChance
      : _random.nextDouble() >= trendDirectionChance;

  _updateMinMaxPrices() {
    final minMaxChange = _random.nextDouble() + 0.2;

    final bool increase = _random.nextBool();

    _max = increase ? _max + minMaxChange : _max - minMaxChange;
    _min = increase ? _min + minMaxChange : _min - minMaxChange;
  }

  void dispose() {
    _timer.cancel();
  }

  void _generateOHLC(DateTime now, OnNewCandle onNewCandle) {
    final randomValue = _random.nextDouble() * 0.056 * sqrt(granularity);

    _value =
        _decideBasedOnTrend() ? _value + randomValue : _value - randomValue;

    // Switching market trend when goes over limit
    if (_value > _max) {
      _trendToUp = false;
      _updateMinMaxPrices();
    } else if (_value < _min) {
      _trendToUp = true;
    }

    if (now.difference(_intervalStartTime).inSeconds < granularity) {
      if (_open == null) {
        _open = _value;
      }
      if (_low == null) {
        _low = _value;
      }
      if (_high == null) {
        _high = _value;
      }

      _high = max(_high, _value);
      _low = min(_low, _value);

      onNewCandle(OHLCEntry(
        epoch: _intervalStartTime.millisecondsSinceEpoch,
        open: _open,
        high: _high,
        low: _low,
        value: _value,
        close: _value,
        intervalInSec: granularity,
      ));
    } else {
      _open = null;
      _high = null;
      _low = null;
      _intervalStartTime = now;
    }
  }
}
