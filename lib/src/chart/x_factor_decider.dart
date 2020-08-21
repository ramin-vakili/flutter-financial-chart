import 'package:flutter_financial_chart/flutter_financial_chart.dart';

/// Specifies which xFactor of [IndexedData] should be used,
/// whether its [IndexedData.index] or its element [BaseEntry.epoch]
abstract class XFactorDecider<T extends BaseEntry> {
  /// Returns the xFactor of [t] which is currently being used, index of epoch
  int getXFactor(IndexedData<T> t);

  /// Returns xFactor difference between to [IndexedData]
  int getXFactorDelta(IndexedData<T> t1, IndexedData<T> t2);
}
