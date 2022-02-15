// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' show Picture, Rect, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The signature of a method that listens for errors on picture stream resolution.
typedef PictureErrorListener = void Function(
  Object exception,
  StackTrace stackTrace,
);

@immutable
class _PictureListenerPair {
  const _PictureListenerPair(this.listener, this.errorListener);
  final PictureListener listener;
  final PictureErrorListener? errorListener;
}

/// Represents information about a ui.Picture to be drawn on a canvas.
class PictureInfo {
  /// Creates a new PictureInfo object.
  PictureInfo({
    required Picture picture,
    required this.viewport,
    this.size = Size.infinite,
    required this.compatibilityTester,
  })  : assert(picture != null), // ignore: unnecessary_null_comparison
        assert(viewport != null), // ignore: unnecessary_null_comparison
        assert(size != null), // ignore: unnecessary_null_comparison
        _picture = picture;

  /// The raw picture.
  ///
  /// This picture's lifecycle will be managed by the provider. It will be
  /// reused as long as the picture does not change, and disposed when the
  /// provider loses all of its listeners or it is unset. Once it has been
  /// disposed, it will return null.
  Picture? get picture => _picture;
  Picture? _picture;

  /// The viewport enclosing the coordinates used in the picture.
  final Rect viewport;

  /// The requested size for this picture, which may be different than the
  /// [viewport.size].
  final Size size;

  /// A tester for whether ambienty property changes should invalidate the cache
  /// for the [Picture].
  final CacheCompatibilityTester compatibilityTester;

  /// Creates a [PictureLayer] that will suitably manage the lifecycle of the
  /// [picture].
  ///
  /// This must not be called if all created handles have been disposed.
  PictureLayer createLayer() {
    assert(picture != null);
    return _NonOwningComplexPictureLayer(this);
  }

  final Set<int> _handles = <int>{};

  /// Creates a [PictureHandle] that keeps the [picture] from being disposed.
  ///
  /// Once all created handles are disposed, the underlying [picture] must not
  /// be used again.
  PictureHandle createHandle() {
    final PictureHandle handle = PictureHandle._(this);
    _handles.add(handle._id);
    return handle;
  }

  void _disposeHandle(PictureHandle handle) {
    assert(_handles.isNotEmpty);
    assert(_picture != null);
    final bool removed = _handles.remove(handle._id);
    assert(removed);
    if (_handles.isEmpty) {
      _picture!.dispose();
      _picture = null;
    }
  }
}

/// An opaque handle used by [PictureInfo] to track the lifecycle of a
/// [Picture].
///
/// Create handles using [PictureInfo.createHandle]. Dispose of them using
/// [dispose].
@immutable
class PictureHandle {
  PictureHandle._(this._owner);

  static int _counter = 1;
  final int _id = _counter++;

  final PictureInfo _owner;

  /// Disposes of this handle. Must not be called more than once.
  void dispose() {
    _owner._disposeHandle(this);
  }

  @override
  int get hashCode => _id;

  @override
  bool operator ==(Object other) {
    return other is PictureHandle && other._id == _id;
  }
}

/// Signature for callbacks reporting that an image is available.
///
/// Used by [PictureStream].
///
/// The `synchronousCall` argument is true if the listener is being invoked
/// during the call to addListener. This can be useful if, for example,
/// [PictureStream.addListener] is invoked during a frame, so that a new rendering
/// frame is requested if the call was asynchronous (after the current frame)
/// and no rendering frame is requested if the call was synchronous (within the
/// same stack frame as the call to [PictureStream.addListener]).
typedef PictureListener = Function(PictureInfo? image, bool synchronousCall);

/// A handle to an image resource.
///
/// PictureStream represents a handle to a [dart:ui.Image] object and its scale
/// (together represented by an [ImageInfo] object). The underlying image object
/// might change over time, either because the image is animating or because the
/// underlying image resource was mutated.
///
/// PictureStream objects can also represent an image that hasn't finished
/// loading.
///
/// PictureStream objects are backed by [PictureStreamCompleter] objects.
///
/// See also:
///
///  * [PictureProvider], which has an example that includes the use of an
///    [PictureStream] in a [Widget].
class PictureStream with Diagnosticable {
  /// Create an initially unbound image stream.
  ///
  /// Once an [PictureStreamCompleter] is available, call [setCompleter].
  PictureStream();

  /// The completer that has been assigned to this image stream.
  ///
  /// Generally there is no need to deal with the completer directly.
  PictureStreamCompleter? get completer => _completer;
  PictureStreamCompleter? _completer;

  List<_PictureListenerPair>? _listeners;

  /// Assigns a particular [PictureStreamCompleter] to this [PictureStream].
  ///
  /// This is usually done automatically by the [PictureProvider] that created the
  /// [PictureStream].
  ///
  /// This method can only be called once per stream. To have an [PictureStream]
  /// represent multiple images over time, assign it a completer that
  /// completes several images in succession.
  void setCompleter(PictureStreamCompleter value) {
    assert(_completer == null);
    _completer = value;
    if (_listeners != null) {
      final List<_PictureListenerPair> initialListeners = _listeners!;
      _listeners = null;
      for (_PictureListenerPair pair in initialListeners) {
        _completer!.addListener(pair.listener, onError: pair.errorListener);
      }
    }
  }

  /// Adds a listener callback that is called whenever a new concrete [ImageInfo]
  /// object is available. If a concrete image is already available, this object
  /// will call the listener synchronously.
  ///
  /// If the assigned [completer] completes multiple images over its lifetime,
  /// this listener will fire multiple times.
  ///
  /// The listener will be passed a flag indicating whether a synchronous call
  /// occurred. If the listener is added within a render object paint function,
  /// then use this flag to avoid calling [RenderObject.markNeedsPaint] during
  /// a paint.
  void addListener(PictureListener listener, {PictureErrorListener? onError}) {
    if (_completer != null) {
      return _completer!.addListener(listener, onError: onError);
    }
    _listeners ??= <_PictureListenerPair>[];
    _listeners!.add(_PictureListenerPair(listener, onError));
  }

  /// Stop listening for new concrete [PictureInfo] objects.
  void removeListener(PictureListener listener) {
    if (_completer != null) {
      return _completer!.removeListener(listener);
    }
    assert(_listeners != null);
    _listeners!.removeWhere(
      (_PictureListenerPair pair) => pair.listener == listener,
    );
  }

  /// Returns an object which can be used with `==` to determine if this
  /// [PictureStream] shares the same listeners list as another [PictureStream].
  ///
  /// This can be used to avoid unregistering and reregistering listeners after
  /// calling [PictureProvider.resolve] on a new, but possibly equivalent,
  /// [PictureProvider].
  ///
  /// The key may change once in the lifetime of the object. When it changes, it
  /// will go from being different than other [PictureStream]'s keys to
  /// potentially being the same as others'. No notification is sent when this
  /// happens.
  Object? get key => _completer != null ? _completer : this;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<PictureStreamCompleter>(
      'completer',
      _completer,
      ifPresent: _completer?.toStringShort(),
      ifNull: 'unresolved',
    ));
    properties.add(ObjectFlagProperty<List<_PictureListenerPair>>(
      'listeners',
      _listeners,
      ifPresent:
          '${_listeners?.length} listener${_listeners?.length == 1 ? "" : "s"}',
      ifNull: 'no listeners',
      level: _completer != null ? DiagnosticLevel.hidden : DiagnosticLevel.info,
    ));
    _completer?.debugFillProperties(properties);
  }
}

/// Base class for those that manage the loading of [dart:ui.Picture] objects for
/// [PictureStream]s.
///
/// [PictureStreamListener] objects are rarely constructed directly. Generally, an
/// [PictureProvider] subclass will return an [PictureStream] and automatically
/// configure it with the right [PictureStreamCompleter] when possible.
abstract class PictureStreamCompleter with Diagnosticable {
  final List<_PictureListenerPair> _listeners = <_PictureListenerPair>[];
  PictureInfo? _current;
  PictureHandle? _handle;

  bool _cached = false;

  /// Whether or not this completer is in the [PictureCache].
  bool get cached => _cached;
  set cached(bool value) {
    if (value == _cached) {
      return;
    }
    if (!value && _listeners.isEmpty) {
      _handle?.dispose();
      _handle = null;
      _current = null;
    }
    _cached = value;
  }

  /// Adds a listener callback that is called whenever a new concrete [PictureInfo]
  /// object is available. If a concrete image is already available, this object
  /// will call the listener synchronously.
  ///
  /// If the [PictureStreamCompleter] completes multiple images over its lifetime,
  /// this listener will fire multiple times.
  ///
  /// The listener will be passed a flag indicating whether a synchronous call
  /// occurred. If the listener is added within a render object paint function,
  /// then use this flag to avoid calling [RenderObject.markNeedsPaint] during
  /// a paint.
  void addListener(PictureListener listener, {PictureErrorListener? onError}) {
    _listeners.add(_PictureListenerPair(listener, onError));
    if (_current != null) {
      try {
        listener(_current, true);
      } catch (exception, stack) {
        _handleImageError(
          ErrorDescription('by a synchronously-called image listener'),
          exception,
          stack,
        );
      }
    }
  }

  /// Stop listening for new concrete [PictureInfo] objects.
  void removeListener(PictureListener listener) {
    _listeners.removeWhere(
      (_PictureListenerPair pair) => pair.listener == listener,
    );
    if (_listeners.isEmpty && !cached) {
      _handle?.dispose();
      _current = null;
      _handle = null;
    }
  }

  /// Tests whether the currently set [PictureInfo], if any, is compatible for
  /// the given theme change.
  bool isCompatible(SvgTheme oldData, SvgTheme newData) {
    return _current?.compatibilityTester.isCompatible(oldData, newData) ?? true;
  }

  /// Calls all the registered listeners to notify them of a new picture.
  @protected
  void setPicture(PictureInfo? picture) {
    _handle?.dispose();
    _current = picture;
    _handle = _current?.createHandle();
    if (_listeners.isEmpty) {
      return;
    }
    final List<_PictureListenerPair> localListeners =
        List<_PictureListenerPair>.from(_listeners);
    for (_PictureListenerPair listenerPair in localListeners) {
      try {
        listenerPair.listener(picture, false);
      } catch (exception, stack) {
        if (listenerPair.errorListener != null) {
          listenerPair.errorListener!(exception, stack);
        } else {
          _handleImageError(
            ErrorDescription('by a picture listener'),
            exception,
            stack,
          );
        }
      }
    }
  }

  void _handleImageError(
    DiagnosticsNode context,
    Object exception,
    dynamic stack,
  ) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: exception,
      stack: stack as StackTrace,
      library: 'SVG',
      context: context,
    ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PictureInfo>('current', _current,
        ifNull: 'unresolved', showName: false));
    properties.add(ObjectFlagProperty<List<_PictureListenerPair>>(
      'listeners',
      _listeners,
      ifPresent:
          '${_listeners.length} listener${_listeners.length == 1 ? "" : "s"}',
    ));
    properties.add(FlagProperty('cached', value: cached, ifTrue: 'cached'));
  }
}

/// Manages the loading of [dart:ui.Picture] objects for static [PictureStream]s (those
/// with only one frame).
class OneFramePictureStreamCompleter extends PictureStreamCompleter {
  /// Creates a manager for one-frame [PictureStream]s.
  ///
  /// The image resource awaits the given [Future]. When the future resolves,
  /// it notifies the [PictureListener]s that have been registered with
  /// [addListener].
  ///
  /// The [InformationCollector], if provided, is invoked if the given [Future]
  /// resolves with an error, and can be used to supplement the reported error
  /// message (for example, giving the image's URL).
  ///
  /// Errors are reported using [FlutterError.reportError] with the `silent`
  /// argument on [FlutterErrorDetails] set to true, meaning that by default the
  /// message is only dumped to the console in debug mode (see [new
  /// FlutterErrorDetails]).
  OneFramePictureStreamCompleter(
    Future<PictureInfo?> picture, {
    InformationCollector? informationCollector,
    // ignore: unnecessary_null_comparison
  }) : assert(picture != null) {
    picture.then<void>(setPicture, onError: (Object error, StackTrace stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'SVG',
        context: ErrorDescription('resolving a single-frame picture stream'),
        informationCollector: informationCollector,
        silent: true,
      ));
    });
  }
}

class _NonOwningComplexPictureLayer extends PictureLayer {
  _NonOwningComplexPictureLayer(this._owner)
      : _handle = _owner.createHandle(),
        super(_owner.viewport);

  final PictureInfo _owner;
  PictureHandle? _handle;

  @override
  bool get isComplexHint => true;

  @override
  Picture? get picture => _owner.picture;

  @override
  set picture(Picture? picture) {
    // Should only get called from dispose.
    assert(picture == null);
    assert(_handle != null);
    if (picture != null) {
      markNeedsAddToScene();
    } else {
      _handle?.dispose();
      _handle = null;
    }
  }
}
