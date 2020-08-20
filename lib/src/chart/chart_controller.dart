import 'package:flutter/material.dart';
import 'package:flutter_financial_chart/src/models/models.dart';

/// Not being used yet
typedef OnNewEntry = Function(BaseEntry entry);

class ChartController extends ChangeNotifier {
  OnNewEntry _onNewEntry;

  void addNewDataListener(OnNewEntry onNewData) => _onNewEntry = onNewData;

  void addNewEntry(TickEntry entry) => _onNewEntry?.call(entry);
}
