import 'package:flutter/foundation.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

// Eviction can be followed by another request that reuses the same Future.
// Track request identity separately so obsolete callbacks are ignored.
class _PendingLoad {
  _PendingLoad(this.future);

  final Future<ByteData> future;
}

/// The cache for decoded SVGs.
class Cache {
  final Map<Object, _PendingLoad> _pending = <Object, _PendingLoad>{};
  final Map<Object, ByteData> _cache = <Object, ByteData>{};
  int _currentByteSize = 0;

  /// Maximum number of entries to store in the cache.
  ///
  /// Once this many entries have been cached, the least-recently-used entry is
  /// evicted when adding a new entry.
  int get maximumSize => _maximumSize;
  int _maximumSize = 100;

  /// Maximum number of compiled SVG bytes to retain. Defaults to 32 MiB.
  ///
  /// The limit applies to completed cache entries; an in-flight decode and
  /// any widget currently painting the SVG may use additional memory.
  int get maximumByteSize => _maximumByteSize;
  int _maximumByteSize = 32 * 1024 * 1024;

  /// Sets the completed-entry byte budget and immediately evicts LRU entries
  /// if necessary. Zero disables caching without preventing SVG rendering.
  set maximumByteSize(int value) {
    assert(value >= 0);
    if (value == maximumByteSize) {
      return;
    }
    _maximumByteSize = value;
    if (value == 0) {
      clear();
    } else {
      _trim();
    }
  }

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
      _trim();
    }
  }

  /// Evicts all completed entries and invalidates pending loads.
  ///
  /// This is useful if, for instance, the root asset bundle has been updated
  /// and therefore new images must be obtained.
  void clear() {
    _pending.clear();
    _cache.clear();
    _currentByteSize = 0;
  }

  /// Evicts a completed entry or invalidates its pending load, returning true if found.
  bool evict(Object key) {
    final hadPending = _pending.remove(key) != null;
    final hadCached = _remove(key) != null;
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

    final ByteData? cached = _remove(key);
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

  ByteData? _remove(Object key) {
    final ByteData? value = _cache.remove(key);
    if (value != null) {
      _currentByteSize -= value.lengthInBytes;
    }
    return value;
  }

  void _trim() {
    while (_cache.isNotEmpty &&
        (_cache.length > maximumSize || _currentByteSize > maximumByteSize)) {
      _remove(_cache.keys.first);
    }
  }

  void _add(Object key, ByteData result) {
    // Return oversized decodes to their callers, but do not retain them.
    if (maximumSize > 0 && maximumByteSize > 0 && result.lengthInBytes <= maximumByteSize) {
      _remove(key);
      _cache[key] = result;
      _currentByteSize += result.lengthInBytes;
      _trim();
    }
    assert(_cache.length <= maximumSize);
    assert(_currentByteSize <= maximumByteSize);
  }

  /// Number of bytes retained by completed cache entries.
  int get currentByteSize => _currentByteSize;

  /// The number of entries in the cache.
  int get count => _cache.length;
}
