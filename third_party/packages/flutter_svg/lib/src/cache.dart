import 'package:flutter/foundation.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

/// An in-flight load and its identity, independent of the returned Future.
///
/// Distinct requests can return the same Future after an eviction. The identity
/// prevents an earlier request from populating the cache for a later one.
class _PendingLoad {
  _PendingLoad(this.future);

  final Future<ByteData> future;
}

/// The cache for decoded SVGs.
class Cache {
  final Map<Object, _PendingLoad> _pending = <Object, _PendingLoad>{};
  final Map<Object, ByteData> _cache = <Object, ByteData>{};

  /// Maximum number of entries to store in the cache.
  ///
  /// Once this many entries have been cached, the least-recently-used entry is
  /// evicted when adding a new entry.
  int get maximumSize => _maximumSize;
  int _maximumSize = 100;

  /// Changes the maximum cache size.
  ///
  /// If the new size is smaller than the current number of elements, the
  /// extraneous elements are evicted immediately. Setting this to zero and then
  /// returning it to its original value will therefore immediately clear the
  /// cache.
  set maximumSize(int value) {
    assert(value != null); // ignore: unnecessary_null_comparison
    assert(value >= 0);
    if (value == maximumSize) {
      return;
    }
    _maximumSize = value;
    if (maximumSize == 0) {
      clear();
    } else {
      while (_cache.length > maximumSize) {
        _cache.remove(_cache.keys.first);
      }
    }
  }

  /// Evicts all completed entries and invalidates pending loads.
  ///
  /// This is useful if, for instance, the root asset bundle has been updated
  /// and therefore new images must be obtained.
  void clear() {
    _pending.clear();
    _cache.clear();
  }

  /// Evicts a completed entry or invalidates its pending load, returning true if found.
  bool evict(Object key) {
    final hadPending = _pending.remove(key) != null;
    final hadCached = _cache.remove(key) != null;
    return hadPending || hadCached;
  }

  /// Evicts a single entry from the cache if the `oldData` and `newData` are
  /// incompatible.
  ///
  /// For example, if the theme has changed the current color and the picture
  /// uses current color, [evict] will be called.
  bool maybeEvict(Object key, SvgTheme oldData, SvgTheme newData) {
    return evict(key);
  }

  /// Returns the previously cached [ByteData] for the given key, if available;
  /// if not, calls the given callback to obtain it first. In either case, the
  /// key is moved to the "most recently used" position.
  ///
  /// The arguments must not be null. The `loader` cannot return null.
  Future<ByteData> putIfAbsent(Object key, Future<ByteData> Function() loader) {
    assert(key != null); // ignore: unnecessary_null_comparison
    assert(loader != null); // ignore: unnecessary_null_comparison

    final _PendingLoad? pending = _pending[key];
    if (pending != null) {
      return pending.future;
    }

    final ByteData? cached = _cache.remove(key);
    if (cached != null) {
      _add(key, cached); // Update the LRU order.
      return SynchronousFuture<ByteData>(cached);
    }

    final Future<ByteData> future = loader();
    final request = _PendingLoad(future);
    _pending[key] = request;
    // Observe both outcomes without changing the Future returned to callers.
    // An error must not poison subsequent loads or create an unhandled error
    // from the otherwise ignored Future returned by then().
    future.then<void>(
      (ByteData data) {
        if (identical(_pending[key], request)) {
          _pending.remove(key);
          _add(key, data);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_pending[key], request)) {
          _pending.remove(key);
        }
      },
    );
    assert(_cache.length <= maximumSize);
    return future;
  }

  void _add(Object key, ByteData result) {
    if (maximumSize > 0) {
      if (_cache.containsKey(key)) {
        _cache.remove(key); // update LRU.
      } else if (_cache.length == maximumSize && maximumSize > 0) {
        _cache.remove(_cache.keys.first);
      }
      assert(_cache.length < maximumSize);
      _cache[key] = result;
    }
    assert(_cache.length <= maximumSize);
  }

  /// The number of entries in the cache.
  int get count => _cache.length;
}
