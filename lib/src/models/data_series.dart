import 'dart:collection';

typedef Item<E, T> = T Function(IndexedData<E> e);

class DataSeries<E> with IterableMixin<IndexedData<E>> {
  DataSeries() : _indexedEntries = <IndexedData<E>>[];

  DataSeries.fromIndexedList(List<IndexedData<E>> list)
      : _indexedEntries = list;

  DataSeries.fromList(List<E> es):_indexedEntries = <IndexedData<E>>[] {
    addAll(es);
  }

  final List<IndexedData<E>> _indexedEntries;

  List<IndexedData<E>> get entries => _indexedEntries;

  int _endIndex = -1;
  int _startIndex = 0;

  void add(E e) => _indexedEntries.add(IndexedData(++_endIndex, e));

  void addAll(List<E> es) {
    for (final e in es) {
      add(e);
    }
  }

  void prepend(E e) => _indexedEntries.insert(0, IndexedData(--_startIndex, e));

  void prependAll(List<E> es) {
    // TODO: Improve later
    for (int i = es.length - 1; i >= 0; i--) {
      prepend(es[i]);
    }
  }

  bool get isEmpty => _indexedEntries.isEmpty; //_startIndex > _endIndex;

  bool get isNotEmpty => !isEmpty;

  int get length => _indexedEntries.length;

  IndexedData get(int i) => _indexedEntries[i];

  DataSeries<E> sublist(int startIndex, int endIndex) =>
      DataSeries.fromIndexedList(_indexedEntries.sublist(startIndex, endIndex));

  Iterable<T> map<T>(Item<E, T> item) =>
      _indexedEntries.map((IndexedData<E> e) => item(e));

  IndexedData<E> removeLast() {
    _endIndex--;
    return _indexedEntries.removeLast();
  }

  DataSeries<E> clone() {
    final clonedSeries = DataSeries.fromIndexedList(_indexedEntries.toList());
    clonedSeries._startIndex = this._startIndex;
    clonedSeries._endIndex = this._endIndex;
    return clonedSeries;
  }

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
