import 'package:flutter_financial_chart/flutter_financial_chart.dart';

abstract class XFactorDecider<T extends BaseEntry> {
  int getXFactor(IndexedData<T> t);
  int getXFactorDelta(IndexedData<T> t1, IndexedData<T> t2);
}
