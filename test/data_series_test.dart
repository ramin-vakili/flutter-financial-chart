import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DataSeries<String> dataSeries;

  setUp(() {
    dataSeries = DataSeries<String>();
  });

  group('description', () {
    test('Is empty before first append', () {
      expect(dataSeries.isEmpty, true);
      expect(dataSeries.isNotEmpty, false);

      dataSeries.add('First');

      expect(dataSeries.isEmpty, false);
      expect(dataSeries.isNotEmpty, true);
    });

    test('endIndex be right', () {
      dataSeries.add('A');
      dataSeries.prepend('B');
      dataSeries.prepend('C');
      dataSeries.add('D');
    });
  });
}
