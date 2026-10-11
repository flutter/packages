// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

/// A decoded picture and whether its filters depend on the requested scale.
typedef VectorImagePicture = ({Picture picture, bool requiresRasterResolution, int replayCost});

/// An image resource retained by the decoder until playback has been recorded.
class VectorImage {
  /// Wraps an owned raster handle.
  VectorImage.raster(Image image)
    : _image = image,
      _picture = null,
      size = Size(image.width.toDouble(), image.height.toDouble());

  /// Wraps an owned vector picture and its intrinsic viewport.
  VectorImage.vector(Picture picture, this.size) : _image = null, _picture = picture;

  /// Prepares vector resources eagerly, but renders filters at their placement scale.
  VectorImage.deferred(
    this.size, {
    required VectorImagePicture Function(double scale) render,
    required void Function() dispose,
  }) : _image = null,
       _picture = null,
       _render = render,
       _dispose = dispose;

  final Image? _image;
  final Picture? _picture;
  VectorImagePicture Function(double)? _render;
  void Function()? _dispose;
  final Map<double, VectorImagePicture> _pictures = {};

  /// Expanded picture cost of the most recent draw, including nested filters.
  int get replayCost => _replayCost;
  int _replayCost = 1;

  /// Borrowed native raster for filter sampling; ownership stays with this object.
  Image? get raster => _image;

  /// The intrinsic dimensions used when positioning this resource.
  final Size size;
  bool _disposed = false;

  /// Draws into a destination rectangle, preserving vectors until final playback.
  /// Returns whether any nested filter depends on [filterRasterScale].
  bool draw(
    Canvas canvas,
    Rect destination, {
    FilterQuality filterQuality = FilterQuality.none,
    bool clipSource = true,
    double filterRasterScale = 1,
  }) {
    if (_disposed) {
      throw StateError('Image resource has been disposed');
    }
    if (size.isEmpty || destination.isEmpty) {
      return false;
    }
    if (_image != null) {
      canvas.drawImageRect(
        _image,
        Offset.zero & size,
        destination,
        Paint()..filterQuality = filterQuality,
      );
      return false;
    }
    Picture? picture = _picture;
    var requiresRasterResolution = false;
    if (picture == null) {
      final double scale =
          filterRasterScale *
          math.max(destination.width / size.width, destination.height / size.height);
      final VectorImagePicture result;
      if (_pictures.isNotEmpty && !_pictures.values.first.requiresRasterResolution) {
        result = _pictures.values.first;
      } else {
        result = _pictures.putIfAbsent(scale, () => _render!(scale));
      }
      picture = result.picture;
      requiresRasterResolution = result.requiresRasterResolution;
      _replayCost = result.replayCost;
    }
    canvas.save();
    canvas.translate(destination.left, destination.top);
    canvas.scale(destination.width / size.width, destination.height / size.height);
    if (clipSource) {
      canvas.clipRect(Offset.zero & size);
    }
    canvas.drawPicture(picture);
    canvas.restore();
    return requiresRasterResolution;
  }

  /// Releases owned Dart handles; recorded display lists retain native references.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _image?.dispose();
    _picture?.dispose();
    for (final VectorImagePicture result in _pictures.values) {
      result.picture.dispose();
    }
    _pictures.clear();
    _dispose?.call();
    _dispose = null;
    _render = null;
  }
}
