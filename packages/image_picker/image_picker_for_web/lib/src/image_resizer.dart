// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:math';
import 'dart:ui';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'image_resizer_utils.dart';

/// Helper class that resizes images.
class ImageResizer {
  /// Resizes the image if needed.
  ///
  /// (Does not support gif images)
  Future<XFile> resizeImageIfNeeded(
    XFile file,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  ) async {
    if (!imageResizeNeeded(maxWidth, maxHeight, imageQuality) ||
        file.mimeType == 'image/gif') {
      // Implement maxWidth and maxHeight for image/gif
      return file;
    }
    try {
      final web.HTMLImageElement imageElement = await loadImage(file.path);
      final web.HTMLCanvasElement canvas =
          resizeImageElement(imageElement, maxWidth, maxHeight);
      final XFile resizedImage =
          await writeCanvasToFile(file, canvas, imageQuality);
      web.URL.revokeObjectURL(file.path);
      return resizedImage;
    } catch (e) {
      return file;
    }
  }

  /// Loads the `blobUrl` into a [web.HTMLImageElement].
  Future<web.HTMLImageElement> loadImage(String blobUrl) {
    final Completer<web.HTMLImageElement> imageLoadCompleter =
        Completer<web.HTMLImageElement>();
    final web.HTMLImageElement imageElement = web.HTMLImageElement();
    imageElement
      ..src = blobUrl
      ..onLoad.listen((web.Event event) {
        imageLoadCompleter.complete(imageElement);
      })
      ..onError.listen((web.Event event) {
        const String exception = 'Error while loading image.';
        imageElement.remove();
        imageLoadCompleter.completeError(exception);
      });
    return imageLoadCompleter.future;
  }

  /// Resizing the image in a canvas to fit the [maxWidth], [maxHeight] constraints.
  web.HTMLCanvasElement resizeImageElement(
    web.HTMLImageElement source,
    double? maxWidth,
    double? maxHeight,
  ) {
    final Size newImageSize = calculateSizeOfDownScaledImage(
        Size(source.width.toDouble(), source.height.toDouble()),
        maxWidth,
        maxHeight);
    final web.HTMLCanvasElement canvas = web.HTMLCanvasElement()
      ..width = newImageSize.width.toInt()
      ..height = newImageSize.height.toInt();
    final web.CanvasRenderingContext2D context = canvas.context2D;
    if (maxHeight == null && maxWidth == null) {
      context.drawImage(source, 0, 0);
    } else {
      context.drawImageScaled(
          source, 0, 0, canvas.width.toDouble(), canvas.height.toDouble());
    }
    return canvas;
  }

  /// Converts a canvas element to [XFile].
  ///
  /// [imageQuality] is only supported for jpeg and webp images.
  Future<XFile> writeCanvasToFile(
    XFile originalFile,
    web.HTMLCanvasElement canvas,
    int? imageQuality,
  ) async {
    final double calculatedImageQuality =
        (min(imageQuality ?? 100, 100)) / 100.0;
    final Completer<XFile> completer = Completer<XFile>();
    final web.BlobCallback blobCallback = (web.Blob blob) {
      completer.complete(XFile(web.URL.createObjectURL(blob),
          mimeType: originalFile.mimeType,
          name: 'scaled_${originalFile.name}',
          lastModified: DateTime.now(),
          length: blob.size));
    }.toJS;
    canvas.toBlob(
        blobCallback, originalFile.mimeType ?? '', calculatedImageQuality.toJS);
    return completer.future;
  }
}
