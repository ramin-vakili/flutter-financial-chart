import '../../flutter_financial_chart.dart';

class MacdPoints {
  final DataSeries<TickEntry> macdValues = DataSeries<TickEntry>();
  final DataSeries<TickEntry> signalValues = DataSeries<TickEntry>();
  final DataSeries<TickEntry> divergenceValues = DataSeries<TickEntry>();

  void addPoint(TickEntry macd, TickEntry signal, TickEntry divergence) {
    macdValues.add(macd);
    signalValues.add(signal);
    divergenceValues.add(divergence);
  }
}
