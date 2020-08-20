import 'package:flutter_financial_chart/src/chart/x_factor_decider.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

/// Binary search to find closest entry to [xFactor] inside [entries]
IndexedData<T> searchClosesEntry<T extends BaseEntry>(
  int xFactor,
  DataSeries<T> entries,
  XFactorDecider xFactorDecider,
) {
  if (xFactor < xFactorDecider.getXFactor(entries[0])) {
    return entries[0];
  }
  if (xFactor > xFactorDecider.getXFactor(entries[entries.length - 1])) {
    return entries[entries.length - 1];
  }

  int lo = 0;
  int hi = entries.length - 1;

  while (lo <= hi) {
    int mid = (hi + lo) ~/ 2;

    if (xFactor < xFactorDecider.getXFactor(entries[mid])) {
      hi = mid - 1;
    } else if (xFactor > xFactorDecider.getXFactor(entries[mid])) {
      lo = mid + 1;
    } else {
      return entries[mid];
    }
  }

  // lo == hi + 1
  return (xFactorDecider.getXFactor(entries[lo]) - xFactor) <
          (xFactor - xFactorDecider.getXFactor(entries[hi]))
      ? entries[lo]
      : entries[hi];
}
