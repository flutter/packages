// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'
    show
        SynchronousFuture,
        describeIdentity,
        immutable,
        objectRuntimeType,
        visibleForTesting;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'src/messages.g.dart';

class _FutureImageStreamCompleter extends ImageStreamCompleter {
  _FutureImageStreamCompleter({
    required Future<ui.Codec> codec,
    required this.futureScale,
  }) {
    codec.then<void>(_onCodecReady, onError: (Object error, StackTrace stack) {
      reportError(
        context: ErrorDescription('resolving a single-frame image stream'),
        exception: error,
        stack: stack,
        silent: true,
      );
    });
  }

  final Future<double> futureScale;

  Future<void> _onCodecReady(ui.Codec codec) async {
    try {
      final ui.FrameInfo nextFrame = await codec.getNextFrame();
      final double scale = await futureScale;
      setImage(ImageInfo(image: nextFrame.image, scale: scale));
    } catch (exception, stack) {
      reportError(
        context: ErrorDescription('resolving an image frame'),
        exception: exception,
        stack: stack,
        silent: true,
      );
    }
  }
}

/// Performs exactly like a [MemoryImage] but instead of taking in bytes it takes
/// in a future that represents bytes.
@immutable
class _FutureMemoryImage extends ImageProvider<_FutureMemoryImage> {
  /// Constructor for FutureMemoryImage.  [_futureBytes] is the bytes that will
  /// be loaded into an image and [_futureScale] is the scale that will be applied to
  /// that image to account for high-resolution images.
  const _FutureMemoryImage(this._futureBytes, this._futureScale);

  final Future<Uint8List> _futureBytes;
  final Future<double> _futureScale;

  /// See [ImageProvider.obtainKey].
  @override
  Future<_FutureMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_FutureMemoryImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _FutureMemoryImage key,
    ImageDecoderCallback decode,
  ) {
    return _FutureImageStreamCompleter(
      codec: _loadAsync(key, decode),
      futureScale: _futureScale,
    );
  }

  Future<ui.Codec> _loadAsync(
    _FutureMemoryImage key,
    ImageDecoderCallback decode,
  ) {
    assert(key == this);
    return _futureBytes.then(ui.ImmutableBuffer.fromUint8List).then(decode);
  }

  /// See [ImageProvider.operator==].
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _FutureMemoryImage &&
        _futureBytes == other._futureBytes &&
        _futureScale == other._futureScale;
  }

  /// See [ImageProvider.hashCode].
  @override
  int get hashCode => Object.hash(_futureBytes.hashCode, _futureScale);

  /// See [ImageProvider.toString].
  @override
  String toString() => '${objectRuntimeType(this, '_FutureMemoryImage')}'
      '(${describeIdentity(_futureBytes)}, scale: $_futureScale)';
}

PlatformImagesApi _hostApi = PlatformImagesApi();

/// Sets the [PlatformImagesApi] instance used to implement the static methods
/// of [IosPlatformImages].
///
/// This exists only for unit tests.
@visibleForTesting
void setPlatformImageHostApi(PlatformImagesApi api) {
  _hostApi = api;
}

// ignore: avoid_classes_with_only_static_members
/// Class to help loading of iOS platform images into Flutter.
///
/// For example, loading an image that is in `Assets.xcassts`.
class IosPlatformImages {
  /// Loads an image from asset catalogs.  The equivalent would be:
  /// `[UIImage imageNamed:name]`.
  ///
  /// Throws an exception if the image can't be found.
  ///
  /// See [https://developer.apple.com/documentation/uikit/uiimage/1624146-imagenamed?language=objc]
  static ImageProvider load(String name) {
    final Future<PlatformImageData?> imageData = _hostApi.loadImage(name);
    final Completer<Uint8List> bytesCompleter = Completer<Uint8List>();
    final Completer<double> scaleCompleter = Completer<double>();
    imageData.then((PlatformImageData? image) {
      if (image == null) {
        scaleCompleter.completeError(
          Exception("Scale couldn't be found to load image: $name"),
        );
        bytesCompleter.completeError(
          Exception("Image couldn't be found: $name"),
        );
        return;
      }
      scaleCompleter.complete(image.scale);
      bytesCompleter.complete(image.data);
    });
    return _FutureMemoryImage(bytesCompleter.future, scaleCompleter.future);
  }

  /// Resolves an URL for a resource.  The equivalent would be:
  /// `[[NSBundle mainBundle] URLForResource:name withExtension:ext]`.
  ///
  /// Returns null if the resource can't be found.
  ///
  /// See [https://developer.apple.com/documentation/foundation/nsbundle/1411540-urlforresource?language=objc]
  static Future<String?> resolveURL(String name, {String? extension}) {
    return _hostApi.resolveUrl(name, extension);
  }
}
