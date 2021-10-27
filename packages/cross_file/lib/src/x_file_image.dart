import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui show Codec;

/// Decodes the given [XFile] object as an image, associating it with the given
/// scale.
///
/// The provider does not monitor the file for changes. If you expect the
/// underlying data to change, you should call the [evict] method.
@immutable
class XFileImage extends ImageProvider<XFileImage> {
  const XFileImage(this.xFile, {this.scale = 1.0});

  /// The file to decode into an image.
  final XFile xFile;

  /// The scale to place in the [ImageInfo] object of the image.
  ///
  /// See also:
  ///
  ///  * [ImageInfo.scale], which gives more information on how this scale is
  ///    applied.
  final double scale;

  @override
  Future<XFileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<XFileImage>(this);
  }

  @override
  ImageStreamCompleter load(XFileImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: 'XFileImage(${describeIdentity(key.xFile)})',
    );
  }

  Future<ui.Codec> _loadAsync(XFileImage key, DecoderCallback decode) async {
    assert(key == this);
    return decode(await xFile.readAsBytes());
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is XFileImage && other.xFile == xFile && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(xFile.hashCode, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'XFileImage')}(${describeIdentity(xFile)}, scale: $scale)';
}
