// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

/// An image resource retained by the decoder until playback has been recorded.
class VectorImage {
  /// Wraps an owned raster handle.
  VectorImage.raster(Image image)
    : _image = image,
      _picture = null,
      size = Size(image.width.toDouble(), image.height.toDouble());

  /// Wraps an owned vector picture and its intrinsic viewport.
  VectorImage.vector(Picture picture, this.size) : _image = null, _picture = picture;

  final Image? _image;
  final Picture? _picture;

  /// Borrowed native raster for filter sampling; ownership stays with this object.
  Image? get raster => _image;

  /// The intrinsic dimensions used when positioning this resource.
  final Size size;
  bool _disposed = false;

  /// Draws into a destination rectangle, preserving vectors until final playback.
  void draw(
    Canvas canvas,
    Rect destination, {
    FilterQuality filterQuality = FilterQuality.none,
    bool clipSource = true,
  }) {
    if (_disposed) {
      throw StateError('Image resource has been disposed');
    }
    if (size.isEmpty || destination.isEmpty) {
      return;
    }
    if (_image != null) {
      canvas.drawImageRect(
        _image,
        Offset.zero & size,
        destination,
        Paint()..filterQuality = filterQuality,
      );
      return;
    }
    canvas.save();
    canvas.translate(destination.left, destination.top);
    canvas.scale(destination.width / size.width, destination.height / size.height);
    if (clipSource) {
      canvas.clipRect(Offset.zero & size);
    }
    canvas.drawPicture(_picture!);
    canvas.restore();
  }

  /// Releases owned Dart handles; recorded display lists retain native references.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _image?.dispose();
    _picture?.dispose();
  }
}
