// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:camera_linux/src/v4l2_camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

// Bindings for the exported helpers that the Dart API does not expose.
const String _asset = 'package:camera_linux/src/bindings.dart';

@Native<Int32 Function(Pointer<Uint8>, Int32, Uint32, Int32, Int32, Int32, Pointer<Uint8>)>(
  symbol: 'camera_linux_frame_to_rgb',
  assetId: _asset,
)
external int _frameToRgb(
  Pointer<Uint8> src,
  int srcLen,
  int fourcc,
  int width,
  int height,
  int bytesPerLine,
  Pointer<Uint8> dst,
);

@Native<Pointer<Uint8> Function(Pointer<Uint8>, Int32, Int32, Int32, Int32, Pointer<Int32>)>(
  symbol: 'camera_linux_encode_jpeg',
  assetId: _asset,
)
external Pointer<Uint8> _encodeJpeg(
  Pointer<Uint8> pixels,
  int width,
  int height,
  int comp,
  int quality,
  Pointer<Int32> length,
);

@Native<Pointer<Uint8> Function(Pointer<Uint8>, Int32, Pointer<Int32>)>(
  symbol: 'camera_linux_fix_mjpeg',
  assetId: _asset,
)
external Pointer<Uint8> _fixMjpeg(Pointer<Uint8> src, int srcLen, Pointer<Int32> length);

@Native<Void Function(Pointer<Void>)>(symbol: 'camera_linux_free', assetId: _asset)
external void _free(Pointer<Void> ptr);

int _fourcc(String s) =>
    s.codeUnitAt(0) | (s.codeUnitAt(1) << 8) | (s.codeUnitAt(2) << 16) | (s.codeUnitAt(3) << 24);

Uint8List? _toRgb(List<int> src, String fourcc, int width, int height, {int stride = 0}) {
  final Pointer<Uint8> srcPtr = calloc<Uint8>(src.length);
  final Pointer<Uint8> dst = calloc<Uint8>(width * height * 3);
  try {
    srcPtr.asTypedList(src.length).setAll(0, src);
    final int rc = _frameToRgb(srcPtr, src.length, _fourcc(fourcc), width, height, stride, dst);
    if (rc != 0) {
      return null;
    }
    return Uint8List.fromList(dst.asTypedList(width * height * 3));
  } finally {
    calloc.free(srcPtr);
    calloc.free(dst);
  }
}

Uint8List? _encode(Uint8List pixels, int width, int height, int comp) {
  final Pointer<Uint8> src = calloc<Uint8>(pixels.length);
  final Pointer<Int32> length = calloc<Int32>();
  try {
    src.asTypedList(pixels.length).setAll(0, pixels);
    final Pointer<Uint8> out = _encodeJpeg(src, width, height, comp, 90, length);
    if (out == nullptr) {
      return null;
    }
    try {
      return Uint8List.fromList(out.asTypedList(length.value));
    } finally {
      _free(out.cast());
    }
  } finally {
    calloc.free(src);
    calloc.free(length);
  }
}

Uint8List? _fix(List<int> jpeg) {
  final Pointer<Uint8> src = calloc<Uint8>(jpeg.length);
  final Pointer<Int32> length = calloc<Int32>();
  try {
    src.asTypedList(jpeg.length).setAll(0, jpeg);
    final Pointer<Uint8> out = _fixMjpeg(src, jpeg.length, length);
    if (out == nullptr) {
      return null;
    }
    try {
      return Uint8List.fromList(out.asTypedList(length.value));
    } finally {
      _free(out.cast());
    }
  } finally {
    calloc.free(src);
    calloc.free(length);
  }
}

/// Removes every DHT (0xFFC4) segment from a JPEG, which is what MJPEG
/// frames from many UVC cameras look like.
Uint8List _stripDht(Uint8List jpeg) {
  final out = BytesBuilder();
  out.add(jpeg.sublist(0, 2));
  var pos = 2;
  while (pos + 4 <= jpeg.length) {
    expect(jpeg[pos], 0xff);
    final int marker = jpeg[pos + 1];
    if (marker == 0xda) {
      out.add(jpeg.sublist(pos));
      return out.toBytes();
    }
    final int segLen = (jpeg[pos + 2] << 8) | jpeg[pos + 3];
    if (marker != 0xc4) {
      out.add(jpeg.sublist(pos, pos + 2 + segLen));
    }
    pos += 2 + segLen;
  }
  fail('no scan in JPEG');
}

bool _hasDht(Uint8List jpeg) {
  var pos = 2;
  while (pos + 4 <= jpeg.length) {
    final int marker = jpeg[pos + 1];
    if (marker == 0xc4) {
      return true;
    }
    if (marker == 0xda) {
      return false;
    }
    pos += 2 + ((jpeg[pos + 2] << 8) | jpeg[pos + 3]);
  }
  return false;
}

Matcher _closeToRgb(int r, int g, int b, {int tolerance = 4}) => predicate(
  (List<num> p) =>
      (p[0] - r).abs() <= tolerance &&
      (p[1] - g).abs() <= tolerance &&
      (p[2] - b).abs() <= tolerance,
  'is close to ($r, $g, $b)',
);

void main() {
  group('frame_to_rgb', () {
    // BT.601 limited range: Y 81, Cb 90, Cr 240 is red.
    const yRed = 81, uRed = 90, vRed = 240;

    test('YUYV', () {
      final Uint8List rgb = _toRgb(<int>[yRed, uRed, yRed, vRed], 'YUYV', 2, 1)!;
      expect(rgb.sublist(0, 3), _closeToRgb(255, 0, 0));
      expect(rgb.sublist(3, 6), _closeToRgb(255, 0, 0));
    });

    test('UYVY, YVYU and VYUY agree with YUYV', () {
      final Uint8List? expected = _toRgb(<int>[yRed, uRed, 235, vRed], 'YUYV', 2, 1);
      expect(_toRgb(<int>[uRed, yRed, vRed, 235], 'UYVY', 2, 1), expected);
      expect(_toRgb(<int>[yRed, vRed, 235, uRed], 'YVYU', 2, 1), expected);
      expect(_toRgb(<int>[vRed, yRed, uRed, 235], 'VYUY', 2, 1), expected);
    });

    test('YUYV honours bytes_per_line and odd widths', () {
      // 3 pixels wide, stride 12 (padding after the 8 payload bytes).
      final row = <int>[yRed, uRed, yRed, vRed, 235, 128, 0, 128, 0, 0, 0, 0];
      final Uint8List rgb = _toRgb(<int>[...row, ...row], 'YUYV', 3, 2, stride: 12)!;
      expect(rgb.length, 18);
      expect(rgb.sublist(0, 3), _closeToRgb(255, 0, 0));
      expect(rgb.sublist(6, 9), _closeToRgb(255, 255, 255));
      expect(rgb.sublist(9, 12), _closeToRgb(255, 0, 0));
    });

    test('NV12 and NV21', () {
      // 2x2 image, all pixels share one chroma sample.
      final y = <int>[yRed, yRed, yRed, yRed];
      final Uint8List nv12 = _toRgb(<int>[...y, uRed, vRed], 'NV12', 2, 2)!;
      final Uint8List? nv21 = _toRgb(<int>[...y, vRed, uRed], 'NV21', 2, 2);
      for (var i = 0; i < 4; i++) {
        expect(nv12.sublist(i * 3, i * 3 + 3), _closeToRgb(255, 0, 0));
      }
      expect(nv21, nv12);
    });

    test('NV12 with an odd width needs only 2 * ceil(w / 2) chroma bytes', () {
      // 3x1: 3 luma bytes, then one chroma row of 4 bytes.
      expect(_toRgb(<int>[81, 81, 81, 90, 240, 0, 0], 'NV12', 3, 1), isNotNull);
      expect(_toRgb(<int>[81, 81, 81, 90, 240, 0], 'NV12', 3, 1), isNull);
    });

    test('YU12 and YV12', () {
      final y = <int>[yRed, yRed, yRed, yRed];
      final Uint8List yu12 = _toRgb(<int>[...y, uRed, vRed], 'YU12', 2, 2)!;
      final Uint8List? yv12 = _toRgb(<int>[...y, vRed, uRed], 'YV12', 2, 2);
      expect(yu12.sublist(0, 3), _closeToRgb(255, 0, 0));
      expect(yv12, yu12);
    });

    test('RGB24, BGR24 and GREY', () {
      expect(_toRgb(<int>[1, 2, 3, 4, 5, 6], 'RGB3', 2, 1), <int>[1, 2, 3, 4, 5, 6]);
      expect(_toRgb(<int>[1, 2, 3, 4, 5, 6], 'BGR3', 2, 1), <int>[3, 2, 1, 6, 5, 4]);
      expect(_toRgb(<int>[7, 200], 'GREY', 2, 1), <int>[7, 7, 7, 200, 200, 200]);
    });

    test('rejects absurd dimensions', () {
      expect(_toRgb(List<int>.filled(16, 0), 'YUYV', 0x40000000, 1), isNull);
      expect(_toRgb(List<int>.filled(16, 0), 'GREY', 1, 0x7fffffff), isNull);
      expect(_encode(Uint8List(16), 0x40000000, 1, 1), isNull);
    });

    test('rejects short buffers and unknown formats', () {
      expect(_toRgb(<int>[yRed, uRed, yRed], 'YUYV', 2, 1), isNull);
      expect(_toRgb(<int>[0, 0, 0, 0], 'YUYV', 2, 2), isNull);
      expect(_toRgb(List<int>.filled(16, 0), 'ABCD', 2, 2), isNull);
      expect(_toRgb(List<int>.filled(5, 0), 'NV12', 2, 2), isNull);
    });
  });

  group('encode_jpeg', () {
    test('produces a JPEG that package:image decodes', () {
      const w = 64, h = 48;
      final pixels = Uint8List(w * h * 3);
      for (var y = 0; y < h; y++) {
        for (var x = 0; x < w; x++) {
          final int i = (y * w + x) * 3;
          pixels[i] = x < w ~/ 2 ? 255 : 0; // left half red
          pixels[i + 1] = 0;
          pixels[i + 2] = x < w ~/ 2 ? 0 : 255; // right half blue
        }
      }
      final Uint8List jpeg = _encode(pixels, w, h, 3)!;
      expect(jpeg.sublist(0, 2), <int>[0xff, 0xd8]);
      expect(_hasDht(jpeg), isTrue);
      final img.Image decoded = img.decodeJpg(jpeg)!;
      expect(decoded.width, w);
      expect(decoded.height, h);
      final img.Pixel left = decoded.getPixel(8, 24);
      final img.Pixel right = decoded.getPixel(56, 24);
      expect(<num>[left.r, left.g, left.b], _closeToRgb(255, 0, 0, tolerance: 12));
      expect(<num>[right.r, right.g, right.b], _closeToRgb(0, 0, 255, tolerance: 12));
    });

    test('encodes grey frames', () {
      final pixels = Uint8List.fromList(List<int>.generate(32 * 32, (int i) => i % 256));
      final img.Image decoded = img.decodeJpg(_encode(pixels, 32, 32, 1)!)!;
      expect(decoded.width, 32);
      expect(decoded.height, 32);
      final img.Pixel p = decoded.getPixel(5, 0);
      expect(<num>[p.r, p.g, p.b], _closeToRgb(5, 5, 5, tolerance: 6));
    });

    test('rejects bad arguments', () {
      expect(_encode(Uint8List(12), 2, 2, 2), isNull);
      expect(_encode(Uint8List(12), 0, 2, 3), isNull);
    });
  });

  group('fix_mjpeg', () {
    late Uint8List withDht;
    late Uint8List withoutDht;

    setUpAll(() {
      final pixels = Uint8List(16 * 16 * 3);
      for (var i = 0; i < pixels.length; i += 3) {
        pixels[i + 1] = 200;
      }
      withDht = _encode(pixels, 16, 16, 3)!;
      withoutDht = _stripDht(withDht);
      expect(_hasDht(withoutDht), isFalse);
      expect(withoutDht.length, withDht.length - 420);
    });

    test('leaves a JPEG with tables untouched', () {
      expect(_fix(withDht), withDht);
    });

    test('inserts the standard tables when they are missing', () {
      final Uint8List fixed = _fix(withoutDht)!;
      expect(_hasDht(fixed), isTrue);
      expect(fixed.length, withoutDht.length + 420);
      // stb emits the same standard tables as one 418-byte DHT segment, so
      // the repaired frame must equal the original byte for byte.
      expect(fixed, withDht);
      final img.Pixel p = img.decodeJpg(fixed)!.getPixel(8, 8);
      expect(<num>[p.r, p.g, p.b], _closeToRgb(0, 200, 0, tolerance: 12));
    });

    test('rejects data that is not a JPEG', () {
      expect(_fix(<int>[0, 1, 2, 3, 4, 5]), isNull);
      expect(_fix(<int>[0xff, 0xd8]), isNull);
    });
  });

  group('V4l2Camera', () {
    test('availableDevices returns a list', () {
      final List<V4l2Device> devices = V4l2Camera.availableDevices();
      for (final d in devices) {
        expect(d.path, startsWith('/dev/video'));
        expect(d.pixelFormat, hasLength(4));
      }
    });

    test('reports why a device cannot be opened', () {
      expect(
        () => V4l2Camera.open(devicePath: '/dev/null'),
        throwsA(
          isA<CameraException>().having(
            (CameraException e) => e.description,
            'description',
            contains('not a V4L2 device'),
          ),
        ),
      );
      expect(
        () => V4l2Camera.open(devicePath: '/dev/does-not-exist'),
        throwsA(
          isA<CameraException>().having(
            (CameraException e) => e.description,
            'description',
            contains('No such file'),
          ),
        ),
      );
    });

    test(
      'streams from the first real camera',
      () async {
        final V4l2Camera camera = V4l2Camera.open();
        addTearDown(camera.close);
        expect(camera.isRunning, isTrue);
        expect(camera.devicePath, startsWith('/dev/video'));
        expect(camera.width, greaterThan(0));
        Uint8List? jpeg;
        for (var i = 0; i < 100 && jpeg == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          jpeg = camera.readJpeg();
        }
        expect(jpeg, isNotNull, reason: 'no frame within 5 s');
        final img.Image decoded = img.decodeJpg(jpeg!)!;
        expect(decoded.width, camera.width);
        expect(decoded.height, camera.height);
        camera.close();
        expect(camera.isRunning, isFalse);
        expect(camera.readJpeg, throwsA(isA<CameraException>()));
        // A second close is harmless.
        camera.close();
      },
      skip: V4l2Camera.availableDevices().isEmpty
          ? 'no V4L2 capture device on this machine'
          : false,
    );
  });
}
