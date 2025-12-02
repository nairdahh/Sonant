// lib/utils/lru_cache.dart - LRU Cache Implementation

/// A Least Recently Used (LRU) cache with a maximum size limit.
/// When the cache exceeds maxSize, the least recently accessed item is evicted.
///
/// This prevents unbounded memory growth in caches while maintaining
/// frequently accessed items in memory for performance.
class LRUCache<K, V> {
  /// Maximum number of items to keep in cache
  final int maxSize;

  /// Internal storage for cached items
  final Map<K, V> _cache = {};

  /// Tracks access order - most recent at the end
  final List<K> _accessOrder = [];

  LRUCache(this.maxSize) : assert(maxSize > 0, 'maxSize must be positive');

  /// Get value from cache
  /// Returns null if key not found
  /// Updates access order when item is accessed
  V? get(K key) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    // Update access order: move to end (most recently used)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return _cache[key];
  }

  /// Put value in cache
  /// If cache is full, evicts the least recently used item
  /// If key already exists, updates value and access order
  void put(K key, V value) {
    // If key already exists, remove from old position
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
    } else if (_cache.length >= maxSize) {
      // Cache is full - evict least recently used (first in list)
      final oldestKey = _accessOrder.removeAt(0);
      _cache.remove(oldestKey);
    }

    // Add to cache and mark as most recently used
    _cache[key] = value;
    _accessOrder.add(key);
  }

  /// Check if key exists in cache
  bool containsKey(K key) => _cache.containsKey(key);

  /// Remove specific key from cache
  V? remove(K key) {
    _accessOrder.remove(key);
    return _cache.remove(key);
  }

  /// Clear entire cache
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// Current number of items in cache
  int get length => _cache.length;

  /// Check if cache is empty
  bool get isEmpty => _cache.isEmpty;

  /// Check if cache is at capacity
  bool get isFull => _cache.length >= maxSize;

  /// Get all keys in cache (in access order, oldest first)
  List<K> get keys => List.unmodifiable(_accessOrder);

  /// Get all values in cache
  Iterable<V> get values => _cache.values;

  /// Operator overload for bracket notation read access
  /// Equivalent to calling get(key)
  V? operator [](K key) => get(key);

  /// Operator overload for bracket notation write access
  /// Equivalent to calling put(key, value)
  void operator []=(K key, V value) => put(key, value);
}