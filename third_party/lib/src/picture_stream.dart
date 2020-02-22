// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' show Picture, Rect, hashValues, Size;

import 'package:flutter/foundation.dart';

/// The signature of a method that listens for errors on picture stream resolution.
typedef PictureErrorListener = void Function(
    dynamic exception, StackTrace stackTrace);

@immutable
class _PictureListenerPair {
  const _PictureListenerPair(this.listener, this.errorListener);
  final PictureListener listener;
  final PictureErrorListener errorListener;
}

/// Represents information about a ui.Picture to be drawn on a canvas.
@immutable
class PictureInfo {
  /// Creates a new PictureInfo object.
  const PictureInfo({
    @required this.picture,
    @required this.viewport,
    this.size = Size.infinite,
  })  : assert(picture != null),
        assert(viewport != null),
        assert(size != null);

  /// The raw picture.
  ///
  /// This is the object to pass to the [Canvas.drawPicture] when painting.
  final Picture picture;

  /// The viewport enclosing the coordinates used in the picture.
  final Rect viewport;

  /// The requested size for this picture, which may be different than the
  /// [viewport.size].
  final Size size;

  @override
  int get hashCode => hashValues(picture, viewport, size);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PictureInfo &&
        other.picture == picture &&
        other.viewport == viewport &&
        other.size == size;
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
typedef PictureListener = Function(PictureInfo image, bool synchronousCall);

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
class PictureStream with DiagnosticableMixin {
  /// Create an initially unbound image stream.
  ///
  /// Once an [PictureStreamCompleter] is available, call [setCompleter].
  PictureStream();

  /// The completer that has been assigned to this image stream.
  ///
  /// Generally there is no need to deal with the completer directly.
  PictureStreamCompleter get completer => _completer;
  PictureStreamCompleter _completer;

  List<_PictureListenerPair> _listeners;

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
      final List<_PictureListenerPair> initialListeners = _listeners;
      _listeners = null;
      for (_PictureListenerPair pair in initialListeners) {
        _completer.addListener(pair.listener, onError: pair.errorListener);
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
  void addListener(PictureListener listener, {PictureErrorListener onError}) {
    if (_completer != null) {
      return _completer.addListener(listener, onError: onError);
    }
    _listeners ??= <_PictureListenerPair>[];
    _listeners.add(_PictureListenerPair(listener, onError));
  }

  /// Stop listening for new concrete [PictureInfo] objects.
  void removeListener(PictureListener listener) {
    if (_completer != null) {
      return _completer.removeListener(listener);
    }
    assert(_listeners != null);
    _listeners.removeWhere(
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
  Object get key => _completer != null ? _completer : this;

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
abstract class PictureStreamCompleter with DiagnosticableMixin {
  final List<_PictureListenerPair> _listeners = <_PictureListenerPair>[];
  PictureInfo _current;

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
  void addListener(PictureListener listener, {PictureErrorListener onError}) {
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
  }

  /// Calls all the registered listeners to notify them of a new picture.
  @protected
  void setPicture(PictureInfo picture) {
    _current = picture;
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
          listenerPair.errorListener(exception, stack);
        } else {
          _handleImageError(
              ErrorDescription('by a picture listener'), exception, stack);
        }
      }
    }
  }

  void _handleImageError(
      DiagnosticsNode context, dynamic exception, dynamic stack) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: exception,
      stack: stack as StackTrace,
      library: 'SVG',
      context: context,
    ));
  }

  /// Accumulates a list of strings describing the object's state. Subclasses
  /// should override this to have their information included in [toString].
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<PictureInfo>('current', _current,
        ifNull: 'unresolved', showName: false));
    description.add(ObjectFlagProperty<List<_PictureListenerPair>>(
      'listeners',
      _listeners,
      ifPresent:
          '${_listeners?.length} listener${_listeners?.length == 1 ? "" : "s"}',
    ));
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
  OneFramePictureStreamCompleter(Future<PictureInfo> picture,
      {InformationCollector informationCollector})
      : assert(picture != null) {
    picture.then<void>(setPicture, onError: (dynamic error, StackTrace stack) {
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
