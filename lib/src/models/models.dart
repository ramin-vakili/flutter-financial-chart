/// Base entry model class for the chart.
///
/// Every data entry given to the chart has got at least a date (epoch) and value
abstract class BaseEntry {
  BaseEntry(this.epoch, this.value);

  final int epoch;
  final double value;
}

/// A simple tick data entry
class TickEntry extends BaseEntry {
  TickEntry(int epoch, double price) : super(epoch, price);
}

/// OHLC data entry date is based on epoch
class OHLCEntry extends BaseEntry {
  OHLCEntry({
    int epoch,
    double value,
    this.open,
    this.close,
    this.high,
    this.low,
    int intervalInSec,
  })  : interval = intervalInSec * 1000,
        super(epoch, value);

  final double open, close, high, low;
  final int interval;
}

class DateTimeTick extends TickEntry {
  DateTimeTick(
    DateTime date,
    double price,
  ) : super(date.millisecondsSinceEpoch, price);
}

class DateTimeOHLC extends OHLCEntry {
  DateTimeOHLC({
    this.date,
    this.open,
    this.close,
    this.high,
    this.low,
    this.intervalInSec,
  }) : super(
          epoch: date.millisecondsSinceEpoch,
          open: open,
          close: close,
          high: high,
          low: low,
          value: close,
          intervalInSec: intervalInSec,
        );

  final DateTime date;
  final double open;
  final double close;
  final double high;
  final double low;
  final int intervalInSec;
}
