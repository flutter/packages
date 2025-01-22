// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

/// Image formats supported by Flutter.
enum ImageFormat {
  /// A Portable Network Graphics format image.
  png,

  /// A JPEG format image.
  ///
  /// This library does not support JPEG 2000.
  jpeg,

  /// A WebP format image.
  webp,

  /// A Graphics Interchange Format image.
  gif,

  /// A Windows Bitmap format image.
  bmp,
}

/// Provides details about image format information for raw compressed bytes
/// of an image.
abstract class ImageSizeData {
  /// Allows subclasses to be const.
  const ImageSizeData({
    required this.format,
    required this.width,
    required this.height,
  })  : assert(width >= 0),
        assert(height >= 0);

  /// Creates an appropriate [ImageSizeData] for the source `bytes`, if possible.
  ///
  /// Only supports image formats supported by Flutter.
  factory ImageSizeData.fromBytes(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw ArgumentError('bytes was empty');
    }
    if (PngImageSizeData.matches(bytes)) {
      return PngImageSizeData._(bytes.buffer.asByteData());
    }
    if (GifImageSizeData.matches(bytes)) {
      return GifImageSizeData._(bytes.buffer.asByteData());
    }
    if (JpegImageSizeData.matches(bytes)) {
      return JpegImageSizeData._fromBytes(bytes.buffer.asByteData());
    }
    if (WebPImageSizeData.matches(bytes)) {
      return WebPImageSizeData._(bytes.buffer.asByteData());
    }
    if (BmpImageSizeData.matches(bytes)) {
      return BmpImageSizeData._(bytes.buffer.asByteData());
    }
    throw ArgumentError('unknown image type');
  }

  /// The [ImageFormat] this instance represents.
  final ImageFormat format;

  /// The width, in pixels, of the image.
  ///
  /// If the image is multi-frame, this is the width of the first frame.
  final int width;

  /// The height, in pixels, of the image.
  ///
  /// If the image is multi-frame, this is the height of the first frame.
  final int height;

  /// The esimated size of the image in bytes.
  ///
  /// The `withMipmapping` parameter controls whether to account for mipmapping
  /// when decompressing the image. Flutter will use this when possible, at the
  /// cost of slightly more memory usage.
  int decodedSizeInBytes({bool withMipmapping = true}) {
    if (withMipmapping) {
      return (width * height * 4.3).ceil();
    }
    return width * height * 4;
  }
}

/// The [ImageSizeData] for a PNG image.
class PngImageSizeData extends ImageSizeData {
  PngImageSizeData._(ByteData data)
      : super(
          format: ImageFormat.png,
          width: data.getUint32(16),
          height: data.getUint32(20),
        );

  /// Returns true if `bytes` starts with the expected header for a PNG image.
  static bool matches(Uint8List bytes) {
    return bytes.lengthInBytes > 20 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
  }
}

/// The [ImageSizeData] for a GIF image.
class GifImageSizeData extends ImageSizeData {
  GifImageSizeData._(ByteData data)
      : super(
          format: ImageFormat.gif,
          width: data.getUint16(6, Endian.little),
          height: data.getUint16(8, Endian.little),
        );

  /// Returns true if `bytes` starts with the expected header for a GIF image.
  static bool matches(Uint8List bytes) {
    return bytes.lengthInBytes > 8 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38 &&
        (bytes[4] == 0x37 || bytes[4] == 0x39) // 7 or 9
        &&
        bytes[5] == 0x61;
  }
}

/// The [ImageSizeData] for a JPEG image.
///
/// This library does not support JPEG2000 images.
class JpegImageSizeData extends ImageSizeData {
  JpegImageSizeData._({required super.width, required super.height})
      : super(
          format: ImageFormat.jpeg,
        );

  factory JpegImageSizeData._fromBytes(ByteData data) {
    int index = 4; // Skip the first header bytes (already validated).
    index += data.getUint16(index);
    while (index < data.lengthInBytes) {
      if (data.getUint8(index) != 0xFF) {
        // Start of block
        throw StateError('Invalid JPEG file');
      }
      if (const <int>[0xC0, 0xC1, 0xC2].contains(data.getUint8(index + 1))) {
        // Start of frame 0
        return JpegImageSizeData._(
          height: data.getUint16(index + 5),
          width: data.getUint16(index + 7),
        );
      }
      index += 2;
      index += data.getUint16(index);
    }
    throw StateError('Invalid JPEG');
  }

  /// Returns true if `bytes` starts with the expected header for a JPEG image.
  static bool matches(Uint8List bytes) {
    return bytes.lengthInBytes > 12 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
  }
}

/// The [ImageSizeData] for a WebP image.
class WebPImageSizeData extends ImageSizeData {
  WebPImageSizeData._(ByteData data)
      : super(
          format: ImageFormat.webp,
          width: data.getUint16(26, Endian.little),
          height: data.getUint16(28, Endian.little),
        );

  /// Returns true if `bytes` starts with the expected header for a WebP image.
  static bool matches(Uint8List bytes) {
    return bytes.lengthInBytes > 28 &&
        bytes[0] == 0x52 // R
        &&
        bytes[1] == 0x49 // I
        &&
        bytes[2] == 0x46 // F
        &&
        bytes[3] == 0x46 // F
        &&
        bytes[8] == 0x57 // W
        &&
        bytes[9] == 0x45 // E
        &&
        bytes[10] == 0x42 // B
        &&
        bytes[11] == 0x50; // P
  }
}

/// The [ImageSizeData] for a BMP image.
class BmpImageSizeData extends ImageSizeData {
  BmpImageSizeData._(ByteData data)
      : super(
            format: ImageFormat.bmp,
            width: data.getInt32(18, Endian.little),
            height: data.getInt32(22, Endian.little));

  /// Returns true if `bytes` starts with the expected header for a WebP image.
  static bool matches(Uint8List bytes) {
    return bytes.lengthInBytes > 22 && bytes[0] == 0x42 && bytes[1] == 0x4D;
  }
}
