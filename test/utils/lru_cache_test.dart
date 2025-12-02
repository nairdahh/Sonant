// test/utils/lru_cache_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sonant/utils/lru_cache.dart';

void main() {
  group('LRUCache', () {
    test('should store and retrieve values', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      expect(cache.get('a'), 1);
      expect(cache.get('b'), 2);
      expect(cache.get('c'), 3);
      expect(cache.length, 3);
    });

    test('should evict least recently used item when full', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      // Cache is full (3/3), adding 'd' should evict 'a' (least recently used)
      cache.put('d', 4);

      expect(cache.get('a'), isNull); // 'a' was evicted
      expect(cache.get('b'), 2);
      expect(cache.get('c'), 3);
      expect(cache.get('d'), 4);
      expect(cache.length, 3);
    });

    test('should update access order on get', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      // Access 'a' to make it most recently used
      cache.get('a');

      // Add 'd' - should evict 'b' (now least recently used)
      cache.put('d', 4);

      expect(cache.get('a'), 1); // 'a' still exists
      expect(cache.get('b'), isNull); // 'b' was evicted
      expect(cache.get('c'), 3);
      expect(cache.get('d'), 4);
    });

    test('should update value if key already exists', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);
      cache.put('a', 100); // Update value

      expect(cache.get('a'), 100);
      expect(cache.length, 1); // Still only 1 item
    });

    test('should support bracket notation for get', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);

      expect(cache['a'], 1);
      expect(cache['missing'], isNull);
    });

    test('should support bracket notation for put', () {
      final cache = LRUCache<String, int>(3);

      cache['a'] = 1;
      cache['b'] = 2;

      expect(cache['a'], 1);
      expect(cache['b'], 2);
      expect(cache.length, 2);
    });

    test('should check if key exists', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);

      expect(cache.containsKey('a'), isTrue);
      expect(cache.containsKey('missing'), isFalse);
    });

    test('should remove specific key', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);
      cache.put('b', 2);

      final removed = cache.remove('a');

      expect(removed, 1);
      expect(cache.get('a'), isNull);
      expect(cache.length, 1);
    });

    test('should clear entire cache', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      cache.clear();

      expect(cache.isEmpty, isTrue);
      expect(cache.length, 0);
      expect(cache.get('a'), isNull);
    });

    test('should report if full', () {
      final cache = LRUCache<String, int>(2);

      expect(cache.isFull, isFalse);

      cache.put('a', 1);
      expect(cache.isFull, isFalse);

      cache.put('b', 2);
      expect(cache.isFull, isTrue);
    });

    test('should return keys in access order', () {
      final cache = LRUCache<String, int>(3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      expect(cache.keys, ['a', 'b', 'c']);

      // Access 'a' to move it to end
      cache.get('a');

      expect(cache.keys, ['b', 'c', 'a']);
    });

    test('should handle complex eviction scenarios', () {
      final cache = LRUCache<int, String>(3);

      // Fill cache
      cache[1] = 'one';
      cache[2] = 'two';
      cache[3] = 'three';

      // Access pattern: 1, 2 (making 3 least recently used)
      cache[1];
      cache[2];

      // Add new item - should evict 3
      cache[4] = 'four';

      expect(cache[3], isNull);
      expect(cache[1], 'one');
      expect(cache[2], 'two');
      expect(cache[4], 'four');
    });

    test('should work with size 1', () {
      final cache = LRUCache<String, int>(1);

      cache['a'] = 1;
      expect(cache['a'], 1);

      cache['b'] = 2; // Should evict 'a'
      expect(cache['a'], isNull);
      expect(cache['b'], 2);
      expect(cache.length, 1);
    });

    test('should assert on invalid maxSize', () {
      expect(() => LRUCache<String, int>(0), throwsAssertionError);
      expect(() => LRUCache<String, int>(-1), throwsAssertionError);
    });
  });
}
