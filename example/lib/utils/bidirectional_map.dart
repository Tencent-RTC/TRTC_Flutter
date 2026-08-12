class BidirectionalMap<K, V> {
  final Map<K, V> _forward = {};
  final Map<V, K> _reverse = {};

  void add(K key, V value) {
    if (_forward.containsKey(key)) {
      final oldValue = _forward[key]!;
      _reverse.remove(oldValue);
    }
    if (_reverse.containsKey(value)) {
      final oldKey = _reverse[value]!;
      _forward.remove(oldKey);
    }
    _forward[key] = value;
    _reverse[value] = key;
  }

  V? getValue(K key) => _forward[key];

  K? getKey(V value) => _reverse[value];

  void remove(K key) {
    final value = _forward.remove(key);
    if (value != null) {
      _reverse.remove(value);
    }
  }

  void removeByValue(V value) {
    final key = _reverse.remove(value);
    if (key != null) {
      _forward.remove(key);
    }
  }

  bool containsKey(K key) => _forward.containsKey(key);

  bool containsValue(V value) => _reverse.containsKey(value);

  Set<K> get keys => _forward.keys.toSet();

  Set<V> get values => _reverse.keys.toSet();

  int get length => _forward.length;

  void clear() {
    _forward.clear();
    _reverse.clear();
  }

  Map<K, V> get entries => Map.from(_forward);

  bool get isEmpty => _forward.isEmpty;

  bool get isNotEmpty => _forward.isNotEmpty;
}
