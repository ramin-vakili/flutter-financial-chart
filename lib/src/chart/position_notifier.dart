import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

typedef OnPosition = Function(
  String chartId,
  double y,
  double x,
  int xFactor,
  double value,
  TouchStatus status,
);

class PositionNotifier extends ChangeNotifier {
  String _chartId;
  double _y;
  double _x;
  int _xFactor;
  double _value;
  TouchStatus _status;

  TouchStatus get status => _status;

  ObserverList<OnPosition> _listeners = ObserverList<OnPosition>();

  void addPositionListener(OnPosition listener) => _listeners.add(listener);

  void removeRangeListener(OnPosition listener) => _listeners.remove(listener);

  void updatePosition({
    String chartId,
    double y,
    double x,
    int xFactor,
    double value,
    TouchStatus status,
  }) {
    _chartId = chartId ?? _chartId;
    _y = y ?? _y;
    _x = x ?? _x;
    _xFactor = xFactor ?? _xFactor;
    _value = value ?? _value;
    _status = status ?? _status;
    notifyRangeListeners();
  }

  @override
  void dispose() {
    _listeners = null;
    super.dispose();
  }

  void notifyRangeListeners() {
    if (_listeners != null) {
      final List<OnPosition> localListeners = List<OnPosition>.from(_listeners);
      for (final OnPosition listener in localListeners) {
        try {
          if (_listeners.contains(listener))
            listener(_chartId, _y, _x, _xFactor, _value, _status);
        } catch (exception, stack) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: exception,
            stack: stack,
          ));
        }
      }
    }
  }
}

class TouchInfo {
  TouchInfo({
    this.chartId,
    this.x,
    this.y,
    this.xFactor,
    this.value,
    this.status = TouchStatus.none,
  });

  final String chartId;
  final double y;
  final double x;
  final int xFactor;
  final double value;
  final TouchStatus status;
}

enum TouchStatus {
  none,
  tapDown,
  tapUp,
  longPressDown,
  logPressUp,
}
