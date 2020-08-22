import 'package:flutter_financial_chart/flutter_financial_chart.dart';

import 'macd_points.dart';

/// A class to calculate Moving Average, RSI, MACD indicators
class MovingAverage {
  final int length;
  int circIndex = -1;
  bool filled = false;
  double current = double.nan;
  double oneOverLength;
  List<BaseEntry> circularBuffer;
  double total = 0;

  MovingAverage(this.length) {
    this.oneOverLength = 1.0 / length;
    this.circularBuffer = new List<BaseEntry>(length);
  }

  MovingAverage update(BaseEntry entry) {
    BaseEntry lostValue = circularBuffer[circIndex];
    circularBuffer[circIndex] = entry;

    // Maintain totals for Push function
    total += entry.value;
    total -= lostValue.value;

    // If not yet filled, just return. Current value should be double.NaN
    if (!filled) {
      current = double.nan;
      return this;
    }

    // Compute the average
    double average = 0.0;
    for (BaseEntry aCircularBuffer in circularBuffer) {
      average += aCircularBuffer.value;
    }

    current = average * oneOverLength;

    return this;
  }

  MovingAverage push(BaseEntry entry) {
    // Apply the circular buffer
    if (++circIndex == length) {
      circIndex = 0;
    }

    double lostValue = circularBuffer[circIndex]?.value ?? 0;
    circularBuffer[circIndex] = entry;

    // Compute the average
    total += entry.value;
    total -= lostValue;

    // If not yet filled, just return. Current value should be double.NaN
    if (!filled && circIndex != length - 1) {
      current = double.nan;
      return this;
    } else {
      // Set a flag to indicate this is the first time the buffer has been filled
      filled = true;
    }

    current = total * oneOverLength;

    return this;
  }

  double getCurrent() {
    return current;
  }

  static DataSeries<TickEntry> movingAverage(
    DataSeries<BaseEntry> input, {
    int period = 10,
  }) {
    final MovingAverage ma = new MovingAverage(period);

    final DataSeries<TickEntry> output =
        DataSeries<TickEntry>(/*input.length*/);

    for (int i = 0; i < input.length; i++) {
      ma.push(input[i].e);
      output.add(TickEntry(input[i].e.epoch, ma.getCurrent()));
    }

    return output;
  }

  static DataSeries<TickEntry> rsi(
    DataSeries<BaseEntry> input, {
    int period = 14,
  }) {
    final MovingAverage averageGain = new MovingAverage(period);
    final MovingAverage averageLoss = new MovingAverage(period);

    final DataSeries<TickEntry> output =
        DataSeries<TickEntry>(/*input.length*/);

    // skip first point
    BaseEntry previousBar = input.first.e;
    output.add(TickEntry(previousBar.epoch, double.nan));

    for (int i = 1, size = input.length; i < size; i++) {
      final BaseEntry priceBar = input[i].e;

      final double gain = priceBar.value > previousBar.value
          ? priceBar.value - previousBar.value
          : 0.0;
      final double loss = previousBar.value > priceBar.value
          ? previousBar.value - priceBar.value
          : 0.0;

      averageGain.push(TickEntry(priceBar.epoch, gain));
      averageLoss.push(TickEntry(priceBar.epoch, loss));

      final double relativeStrength =
          averageGain.getCurrent().isNaN || averageLoss.getCurrent().isNaN
              ? double.nan
              : averageGain.getCurrent() / averageLoss.getCurrent();

      output.add(TickEntry(
          priceBar.epoch, 100.0 - (100.0 / (1.0 + relativeStrength))));

      previousBar = priceBar;
    }

    return output;
  }

  static MacdPoints macd(
    DataSeries<BaseEntry> input, {
    int slow = 7,
    int fast = 20,
    int signal = 4,
  }) {
    final MovingAverage maSlow = new MovingAverage(slow);
    final MovingAverage maFast = new MovingAverage(fast);
    final MovingAverage maSignal = new MovingAverage(signal);

    final MacdPoints output = new MacdPoints();

    for (int i = 0; i < input.length; i++) {
      final item = input[i].e;
      final double macd =
          maSlow.push(item).getCurrent() - maFast.push(item).getCurrent();
      final double signalLine = macd.isNaN
          ? double.nan
          : maSignal.push((TickEntry(item.epoch, macd))).getCurrent();
      final double divergence =
          macd.isNaN || signalLine.isNaN ? double.nan : macd - signalLine;

      output.addPoint(TickEntry(item.epoch, macd),
          TickEntry(item.epoch, signalLine), TickEntry(item.epoch, divergence));
    }

    return output;
  }
}
