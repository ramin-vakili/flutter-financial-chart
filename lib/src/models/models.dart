abstract class BaseEntry {
  BaseEntry(this.epoch, this.value);

  final int epoch;
  final double value;
}

class TickEntry extends BaseEntry {
  TickEntry(int epoch, double price) : super(epoch, price);
}

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
