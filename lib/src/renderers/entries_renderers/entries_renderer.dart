import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';

import '../../models/models.dart';
import '../base_renderer.dart';
import 'entries_renderable.dart';

/// Hold's the information of a data series, Updates and paint's [rendererable]
/// When the chart requires update
abstract class EntriesRenderer<T extends BaseEntry> extends BaseRenderer {
  EntriesRenderer(this.entries, this.id);

  EntriesRendererable<T> rendererable;

  final String id;

  final DataSeries<T> entries;

  /// Its consumed by the [rendererable] to handle it's new tick transition
  /// from last tick to the tick
  IndexedData<T> prevLastEntry;

  set prevLast(IndexedData<T> entry) => prevLastEntry = entry;

  double _minValueInFrame;
  double _maxValueInFrame;

  double get minValue => _minValueInFrame ?? null;

  double get maxValue => _maxValueInFrame ?? null;

  int xToXFactor(double x) => rendererable?.xToXFactor(x);

  double yToValue(double y) => rendererable?.yToValue(y);

  /// Updates visible entries for this renderer
  DataSeries<T> update({
    @required int leftXFactor,
    @required int rightXFactor,
    TouchInfo touchInfo,
    bool isIndependentChart,
  }) {
    assert(leftXFactor < rightXFactor);

    int startIndex = _searchLowerIndex(leftXFactor);
    int endIndex = _searchUpperIndex(rightXFactor);

    final DataSeries<T> visibleEntries = startIndex == -1 || endIndex == -1
        ? DataSeries()
        : entries.sublist(startIndex, endIndex);

    _setMinMaxValues(visibleEntries);

    updateRenderable(
      visibleEntries,
      leftXFactor,
      rightXFactor,
      touchInfo,
      isIndependentChart,
    );

    return visibleEntries;
  }

  void _setMinMaxValues(DataSeries visibleEntries) {
    final List<double> minMaxValues = getMinMaxValue(visibleEntries.entries);

    if (minMaxValues == null) {
      _calculateMinMax(visibleEntries);
    } else {
      _minValueInFrame = minMaxValues[0];
      _maxValueInFrame = minMaxValues[1];
    }
  }

  List<double> getMinMaxValue(List<IndexedData<T>> visibleEntries);

  void _calculateMinMax(DataSeries visibleEntries) {
    final Iterable<double> valuesInAction = visibleEntries.entries
        .where((indexedData) => !indexedData.e.value.isNaN)
        .map((indexedData) => indexedData.e.value);

    if (valuesInAction.isEmpty) {
      _minValueInFrame = null;
      _maxValueInFrame = null;
    } else {
      _minValueInFrame = valuesInAction.reduce(min);
      _maxValueInFrame = valuesInAction.reduce(max);
    }
  }

  int _searchLowerIndex(int leftXFactor) {
    if (leftXFactor < xFactorDecider.getXFactor(entries.get(0))) {
      return 0;
    }
    if (leftXFactor >
        xFactorDecider.getXFactor(entries.get(entries.length - 1))) {
      return -1;
    }

    int lo = 0;
    int hi = entries.length - 1;

    while (lo <= hi) {
      int mid = (hi + lo) ~/ 2;

      if (leftXFactor < xFactorDecider.getXFactor(entries.get(mid))) {
        hi = mid - 1;
      } else if (leftXFactor > xFactorDecider.getXFactor(entries.get(mid))) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    // lo == hi + 1
    final closest = (xFactorDecider.getXFactor(entries.get(lo)) - leftXFactor) <
            (leftXFactor - xFactorDecider.getXFactor(entries.get(hi)))
        ? lo
        : hi;
    final index = closest <= leftXFactor
        ? closest
        : closest - 1 < 0 ? closest : closest - 1;
    return index - 1 < 0 ? index : index - 1;
  }

  int _searchUpperIndex(int rightXFactor) {
    if (rightXFactor < xFactorDecider.getXFactor(entries.get(0))) {
      return -1;
    }
    if (rightXFactor >
        xFactorDecider.getXFactor(entries.get(entries.length - 1))) {
      return entries.length;
    }

    int lo = 0;
    int hi = entries.length - 1;

    while (lo <= hi) {
      int mid = (hi + lo) ~/ 2;

      if (rightXFactor < xFactorDecider.getXFactor(entries.get(mid))) {
        hi = mid - 1;
      } else if (rightXFactor > xFactorDecider.getXFactor(entries.get(mid))) {
        lo = mid + 1;
      } else {
        return mid;
      }
    }

    // lo == hi + 1
    final closest =
        (xFactorDecider.getXFactor(entries.get(lo)) - rightXFactor) <
                (rightXFactor - xFactorDecider.getXFactor(entries.get(hi)))
            ? lo
            : hi;

    int index = closest >= rightXFactor
        ? closest
        : (closest + 1 > entries.length ? closest : closest + 1);
    return index == entries.length ? index : index + 1;
  }

  /// Updates [rendererable] with the new [visibleEntries] and XFactor boundaries
  void updateRenderable(
    DataSeries<T> visibleEntries,
    int leftXFactor,
    int rightXFactor,
    TouchInfo touchInfo,
    bool isIndependentChart,
  );

  /// Paints [rendererable]'s data on the [canvas]
  /// Will get called after [updateRenderable] method
  void paint(
    Canvas canvas,
    Size size,
    AnimationsInfo animationsInfo,
    double animatingMinValue,
    double animatingMaxValue,
  ) =>
      rendererable?.paint(
        canvas: canvas,
        size: size,
        animationsInfo: animationsInfo,
        animatingMinValue: animatingMinValue,
        animatingMaxValue: animatingMaxValue,
        prevLastEntry: prevLastEntry,
      );
}
