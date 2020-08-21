import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_financial_chart/flutter_financial_chart.dart';

typedef OnRangeChange = Function(int xFactorInPx, int rightXFactor);

///
class SharedRange<T extends BaseEntry> extends ChangeNotifier {
  int _xFactorInPx = 4000;
  int _rightXFactor = 1;

  int get xFactorInPx => _xFactorInPx;

  int get rightXFactor => _rightXFactor;

  int _xFactorInPxMin;
  int _xFactorInPxMax;

  int _minXFactor, _maxXFactor;

  int _halfWidth;

  DataSeries<T> _mainVisibleEntries;

  DataSeries<T> get mainVisibleEntries => _mainVisibleEntries;

  void initialize({
    int minXFactor,
    int maxXFactor,
    int xFactorInPxMin,
    int xFactorInPxMax,
    int halfWidth,
  }) =>
      _updateVariables(
        minXFactor: minXFactor,
        maxXFactor: maxXFactor,
        xFactorInPxMin: xFactorInPxMin,
        xFactorInPxMax: xFactorInPxMax,
        halfWidth: halfWidth,
      );

  void updateMinMax(int minXFactor, int maxXFactor) =>
      _updateVariables(minXFactor: minXFactor, maxXFactor: maxXFactor);

  void updateVisibleEntries(DataSeries<T> entries) =>
      _mainVisibleEntries = entries;

  void _updateVariables({
    int minXFactor,
    int maxXFactor,
    int xFactorInPxMin,
    int xFactorInPxMax,
    int halfWidth,
  }) {
    _minXFactor = (_minXFactor != null && minXFactor != null)
        ? min(minXFactor, _minXFactor)
        : (minXFactor ?? _minXFactor);

    _maxXFactor = (_maxXFactor != null && maxXFactor != null)
        ? max(maxXFactor, _maxXFactor)
        : (maxXFactor ?? _maxXFactor);

    _xFactorInPxMin = (_xFactorInPxMin != null && xFactorInPxMin != null)
        ? min(xFactorInPxMin, _xFactorInPxMin)
        : (xFactorInPxMin ?? _xFactorInPxMin);

    _xFactorInPxMax = (_xFactorInPxMax != null && xFactorInPxMax != null)
        ? max(xFactorInPxMax, _xFactorInPxMax)
        : (xFactorInPxMax ?? _xFactorInPxMax);
    _halfWidth = halfWidth ?? _halfWidth;
  }

  ObserverList<OnRangeChange> _listeners = ObserverList<OnRangeChange>();

  void addRangeListener(OnRangeChange listener) => _listeners.add(listener);

  void removeRangeListener(OnRangeChange listener) =>
      _listeners.remove(listener);

  void updateRange({int xFactorInPx, int rightXFactor}) =>
      _updateRange(xFactorInPx: xFactorInPx, rightXFactor: rightXFactor);

  void _updateRange({int xFactorInPx, int rightXFactor}) {
    _xFactorInPx = xFactorInPx ?? this._xFactorInPx;
    _rightXFactor = rightXFactor ?? this._rightXFactor;
    _xFactorInPx = _xFactorInPx.clamp(_xFactorInPxMin, _xFactorInPxMax);
    _rightXFactor = _rightXFactor.clamp(
      _minXFactor + _xFactorInPx * _halfWidth,
      _maxXFactor + _xFactorInPx * _halfWidth,
    );
    notifyRangeListeners();
  }

  @override
  void dispose() {
    _listeners = null;
    super.dispose();
  }

  void notifyRangeListeners() {
    if (_listeners != null) {
      final List<OnRangeChange> localListeners =
          List<OnRangeChange>.from(_listeners);
      for (final OnRangeChange listener in localListeners) {
        try {
          if (_listeners.contains(listener))
            listener(_xFactorInPx, _rightXFactor);
        } catch (exception, stack) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: exception,
            stack: stack,
          ));
        }
      }
    }
  }

  bool initialized() => _rightXFactor != 1;
}
