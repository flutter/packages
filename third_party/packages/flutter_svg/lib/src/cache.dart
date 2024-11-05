import 'package:flutter/foundation.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

/// The cache for decoded SVGs.
class Cache {
  final Map<Object, Future<ByteData>> _pending = <Object, Future<ByteData>>{};
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

  /// Evicts all entries from the cache.
  ///
  /// This is useful if, for instance, the root asset bundle has been updated
  /// and therefore new images must be obtained.
  void clear() {
    _cache.clear();
  }

  /// Evicts a single entry from the cache, returning true if successful.
  bool evict(Object key) {
    return _cache.remove(key) != null;
  }

  /// Evicts a single entry from the cache if the `oldData` and `newData` are
  /// incompatible.
  ///
  /// For example, if the theme has changed the current color and the picture
  /// uses current color, [evict] will be called.
  bool maybeEvict(Object key, SvgTheme oldData, SvgTheme newData) {
    return evict(key);
  }

  /// Returns the previously cached [PictureStream] for the given key, if available;
  /// if not, calls the given callback to obtain it first. In either case, the
  /// key is moved to the "most recently used" position.
  ///
  /// The arguments must not be null. The `loader` cannot return null.
  Future<ByteData> putIfAbsent(
    Object key,
    Future<ByteData> Function() loader,
  ) {
    assert(key != null); // ignore: unnecessary_null_comparison
    assert(loader != null); // ignore: unnecessary_null_comparison
    Future<ByteData>? pendingResult = _pending[key];
    if (pendingResult != null) {
      return pendingResult;
    }

    ByteData? result = _cache[key];
    if (result != null) {
      // Remove the provider from the list so that we can put it back in below
      // and thus move it to the end of the list.
      _cache.remove(key);
    } else {
      pendingResult = loader();
      _pending[key] = pendingResult;
      pendingResult.then((ByteData data) {
        _pending.remove(key);
        _add(key, data);
        result = data; // in case it was a synchronous future.
      });
    }
    if (result != null) {
      _add(key, result!);
      return SynchronousFuture<ByteData>(result!);
    }
    assert(_cache.length <= maximumSize);
    return pendingResult!;
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
