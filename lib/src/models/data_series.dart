import 'dart:collection';

typedef Item<E, T> = T Function(IndexedData<E> e);

/// A data structure to handle indices of data entries.
///
/// Suitable for sorted list of data entries.
///
/// Sorted lis of [T] can be added to the start or to the end of the [DataSeries]
class DataSeries<E> with IterableMixin<IndexedData<E>> {
  DataSeries() : _indexedEntries = <IndexedData<E>>[];

  /// Initializes a [DataSeries] from an already created list of [IndexedData].
  DataSeries.fromIndexedList(List<IndexedData<E>> list)
      : _indexedEntries = list;

  /// Initializes a [DataSeries] from a list.
  DataSeries.fromList(List<E> es) : _indexedEntries = <IndexedData<E>>[] {
    addAll(es);
  }

  final List<IndexedData<E>> _indexedEntries;

  List<IndexedData<E>> get entries => _indexedEntries;

  int _endIndex = -1;
  int _startIndex = 0;

  /// Adds the element [e] to the end of the data series.
  void add(E e) => _indexedEntries.add(IndexedData(++_endIndex, e));

  /// Adds a list of [E] elements to the end of the data series.
  void addAll(List<E> es) {
    for (final e in es) {
      add(e);
    }
  }

  /// Adds the element [e] to the beginning of the data series.
  void prepend(E e) => _indexedEntries.insert(0, IndexedData(--_startIndex, e));

  /// Adds a list of [E] elements to the beginning of the data series.
  void prependAll(List<E> es) {
    // TODO: Improve later
    for (int i = es.length - 1; i >= 0; i--) {
      prepend(es[i]);
    }
  }

  bool get isEmpty => _indexedEntries.isEmpty;

  bool get isNotEmpty => !isEmpty;

  int get length => _indexedEntries.length;

  IndexedData get(int i) => _indexedEntries[i];

  DataSeries<E> sublist(int startIndex, int endIndex) =>
      DataSeries.fromIndexedList(_indexedEntries.sublist(startIndex, endIndex));

  /// Exposes map functionality of List<[T]>.
  Iterable<T> map<T>(Item<E, T> item) =>
      _indexedEntries.map((IndexedData<E> e) => item(e));

  IndexedData<E> removeLast() {
    _endIndex--;
    return _indexedEntries.removeLast();
  }

  /// Creates a copy of this data series.
  DataSeries<E> clone() {
    final clonedSeries = DataSeries.fromIndexedList(_indexedEntries.toList());
    clonedSeries._startIndex = this._startIndex;
    clonedSeries._endIndex = this._endIndex;
    return clonedSeries;
  }

  /// Overridden by this class so the [IndexedData] items can be accessed using [index] operator.
  IndexedData<E> operator [](int index) => _indexedEntries[index];

  @override
  Iterator<IndexedData<E>> get iterator => _indexedEntries.iterator;
}

class IndexedData<E> {
  IndexedData(int index, this.e) : _index = 1000000 * index;

  final int _index;

  int get index => _index;

  final E e;
}
