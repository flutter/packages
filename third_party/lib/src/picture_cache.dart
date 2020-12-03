import 'picture_stream.dart';

const int _kDefaultSize = 1000;

/// A cache for [Picture] objects.
// TODO(dnfield): Implement memory based limiting, once `approximateByteCount` is exposed in engine
class PictureCache {
  final Map<Object, PictureStreamCompleter> _cache =
      <Object, PictureStreamCompleter>{};

  /// Maximum number of entries to store in the cache.
  ///
  /// Once this many entries have been cached, the least-recently-used entry is
  /// evicted when adding a new entry.
  int get maximumSize => _maximumSize;
  int _maximumSize = _kDefaultSize;

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
      _cache.clear();
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
  // TODO(ianh): Provide a way to target individual images. This is currently non-trivial
  // because by the time we get to the imageCache, the keys we're using are opaque.
  void clear() {
    _cache.clear();
  }

  /// Returns the previously cached [PictureStream] for the given key, if available;
  /// if not, calls the given callback to obtain it first. In either case, the
  /// key is moved to the "most recently used" position.
  ///
  /// The arguments must not be null. The `loader` cannot return null.
  PictureStreamCompleter putIfAbsent(
      Object key, PictureStreamCompleter loader()) {
    assert(key != null); // ignore: unnecessary_null_comparison
    assert(loader != null); // ignore: unnecessary_null_comparison
    PictureStreamCompleter? result = _cache[key];
    if (result != null) {
      // Remove the provider from the list so that we can put it back in below
      // and thus move it to the end of the list.
      _cache.remove(key);
    } else {
      if (_cache.length == maximumSize && maximumSize > 0)
        _cache.remove(_cache.keys.first);
      result = loader();
    }
    if (maximumSize > 0) {
      assert(_cache.length < maximumSize);
      _cache[key] = result;
    }
    assert(_cache.length <= maximumSize);
    return result;
  }

  /// The number of entries in the cache.
  int get count => _cache.length;
}
