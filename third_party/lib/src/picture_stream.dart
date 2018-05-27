// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' show Picture, Rect, hashValues;

import 'package:flutter/foundation.dart';

@immutable
class PictureInfo {
  const PictureInfo({@required this.picture, @required this.viewBox})
      : assert(picture != null),
        assert(viewBox != null);

  /// The raw picture.
  ///
  /// This is the object to pass to the [Canvas.drawPicture] when painting.
  final Picture picture;

  /// The viewBox enclosing the coordinates used in the picture.
  final Rect viewBox;

  @override
  String toString() => '$picture $viewBox';

  @override
  int get hashCode => hashValues(picture, viewBox);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final PictureInfo typedOther = other;
    return typedOther.picture == picture && typedOther.viewBox == viewBox;
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
typedef void PictureListener(PictureInfo image, bool synchronousCall);

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
class PictureStream extends Diagnosticable {
  /// Create an initially unbound image stream.
  ///
  /// Once an [PictureStreamCompleter] is available, call [setCompleter].
  PictureStream();

  /// The completer that has been assigned to this image stream.
  ///
  /// Generally there is no need to deal with the completer directly.
  PictureStreamCompleter get completer => _completer;
  PictureStreamCompleter _completer;

  List<PictureListener> _listeners;

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
      final List<PictureListener> initialListeners = _listeners;
      _listeners = null;
      initialListeners.forEach(_completer.addListener);
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
  void addListener(PictureListener listener) {
    if (_completer != null) {
      return _completer.addListener(listener);
    }
    _listeners ??= <PictureListener>[];
    _listeners.add(listener);
  }

  /// Stop listening for new concrete [ImageInfo] objects.
  void removeListener(PictureListener listener) {
    if (_completer != null) {
      return _completer.removeListener(listener);
    }
    assert(_listeners != null);
    _listeners.remove(listener);
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
    properties.add(new ObjectFlagProperty<PictureStreamCompleter>(
      'completer',
      _completer,
      ifPresent: _completer?.toStringShort(),
      ifNull: 'unresolved',
    ));
    properties.add(new ObjectFlagProperty<List<PictureListener>>(
      'listeners',
      _listeners,
      ifPresent:
          '${_listeners?.length} listener${_listeners?.length == 1 ? "" : "s" }',
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
abstract class PictureStreamCompleter extends Diagnosticable {
  final List<PictureListener> _listeners = <PictureListener>[];
  PictureInfo _current;

  /// Adds a listener callback that is called whenever a new concrete [ImageInfo]
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
  void addListener(PictureListener listener) {
    _listeners.add(listener);
    if (_current != null) {
      try {
        listener(_current, true);
      } catch (exception, stack) {
        _handleImageError(
            'by a synchronously-called image listener', exception, stack);
      }
    }
  }

  /// Stop listening for new concrete [ImageInfo] objects.
  void removeListener(PictureListener listener) {
    _listeners.remove(listener);
  }

  /// Calls all the registered listeners to notify them of a new image.
  @protected
  void setImage(PictureInfo image) {
    _current = image;
    if (_listeners.isEmpty) {
      return;
    }
    final List<PictureListener> localListeners =
        new List<PictureListener>.from(_listeners);
    for (PictureListener listener in localListeners) {
      try {
        listener(image, false);
      } catch (exception, stack) {
        _handleImageError('by an image listener', exception, stack);
      }
    }
  }

  void _handleImageError(String context, dynamic exception, dynamic stack) {
    FlutterError.reportError(new FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'image resource service',
        context: context));
  }

  /// Accumulates a list of strings describing the object's state. Subclasses
  /// should override this to have their information included in [toString].
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new DiagnosticsProperty<PictureInfo>('current', _current,
        ifNull: 'unresolved', showName: false));
    description.add(new ObjectFlagProperty<List<PictureListener>>(
      'listeners',
      _listeners,
      ifPresent:
          '${_listeners?.length} listener${_listeners?.length == 1 ? "" : "s" }',
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
    picture.then<void>(setImage, onError: (dynamic error, StackTrace stack) {
      FlutterError.reportError(new FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'SVG',
        context: 'resolving a single-frame picture stream',
        informationCollector: informationCollector,
        silent: true,
      ));
    });
  }
}
