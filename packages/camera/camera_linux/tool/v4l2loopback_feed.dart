// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

// Feeds synthetic frames into a v4l2loopback device, for testing without a
// webcam.
//
//   sudo modprobe v4l2loopback video_nr=42 card_label=camera_linux_test exclusive_caps=1
//   dart run tool/v4l2loopback_feed.dart /dev/video42 --text hello --format yuyv
//
// Then `CAMERA_LINUX_DEVICE=/dev/video42 flutter test`, or run an app that
// uses camera_linux. Each frame shows a QR code of --text plus a moving bar so
// that frames differ. --format mjpeg writes JPEG frames; --strip-dht removes
// their Huffman tables, which is what many UVC cameras do and what the library
// repairs.
//
// Writing to a regular file instead of a device is allowed (the format ioctl
// is skipped), which is handy for checking the encoders.

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

const String _usage = '''
Usage: dart run tool/v4l2loopback_feed.dart <device> [options]

  --text <s>      QR code contents (default "camera_linux test")
  --format <f>    yuyv (default), rgb24, bgr24, grey or mjpeg
  --width <n>     frame width (default 640)
  --height <n>    frame height (default 480)
  --fps <n>       frames per second (default 10)
  --strip-dht     with --format mjpeg: omit the Huffman tables
  --frames <n>    stop after n frames (default 0: run until interrupted)
''';

const Map<String, String> _fourcc = <String, String>{
  'yuyv': 'YUYV',
  'rgb24': 'RGB3',
  'bgr24': 'BGR3',
  'grey': 'GREY',
  'mjpeg': 'MJPG',
};

const Map<String, int> _bytesPerPixel = <String, int>{
  'yuyv': 2,
  'rgb24': 3,
  'bgr24': 3,
  'grey': 1,
  'mjpeg': 0,
};

class _Options {
  _Options(this.device);

  final String device;
  String text = 'camera_linux test';
  String format = 'yuyv';
  int width = 640;
  int height = 480;
  double fps = 10;
  bool stripDht = false;
  int frames = 0;

  static _Options? parse(List<String> args) {
    if (args.isEmpty || args.first.startsWith('--')) {
      return null;
    }
    final options = _Options(args.first);
    for (var i = 1; i < args.length; i++) {
      final String arg = args[i];
      String value() {
        if (i + 1 >= args.length) {
          throw FormatException('$arg needs a value');
        }
        return args[++i];
      }

      switch (arg) {
        case '--text':
          options.text = value();
        case '--format':
          options.format = value();
          if (!_fourcc.containsKey(options.format)) {
            throw FormatException('unknown format ${options.format}');
          }
        case '--width':
          options.width = int.parse(value());
        case '--height':
          options.height = int.parse(value());
        case '--fps':
          options.fps = double.parse(value());
        case '--strip-dht':
          options.stripDht = true;
        case '--frames':
          options.frames = int.parse(value());
        default:
          throw FormatException('unknown option $arg');
      }
    }
    if (options.width <= 0 || options.height <= 0 || options.fps <= 0) {
      throw const FormatException('width, height and fps must be positive');
    }
    return options;
  }
}

// libc, through the process's own symbols.
final DynamicLibrary _libc = DynamicLibrary.process();

final int Function(Pointer<Utf8> path, int flags, int mode) _open = _libc
    .lookupFunction<
      Int Function(Pointer<Utf8>, Int, VarArgs<(Int,)>),
      int Function(Pointer<Utf8>, int, int)
    >('open');

final int Function(int fd, int request, Pointer<Void> arg) _ioctl = _libc
    .lookupFunction<
      Int Function(Int, UnsignedLong, VarArgs<(Pointer<Void>,)>),
      int Function(int, int, Pointer<Void>)
    >('ioctl');

final int Function(int fd, Pointer<Uint8> buf, int count) _write = _libc
    .lookupFunction<
      IntPtr Function(Int, Pointer<Uint8>, Size),
      int Function(int, Pointer<Uint8>, int)
    >('write');

final int Function(int fd) _close = _libc.lookupFunction<Int Function(Int), int Function(int)>(
  'close',
);

final Pointer<Int32> Function() _errnoLocation = _libc
    .lookupFunction<Pointer<Int32> Function(), Pointer<Int32> Function()>('__errno_location');

final Pointer<Utf8> Function(int errnum) _strerror = _libc
    .lookupFunction<Pointer<Utf8> Function(Int), Pointer<Utf8> Function(int)>('strerror');

int get _errno => _errnoLocation().value;

String _errnoString() => _strerror(_errno).toDartString();

// O_WRONLY | O_CREAT | O_TRUNC, so a regular file works too; device nodes exist already.
const int _openFlags = 1 | 64 | 512;
const int _createMode = 420; // 0644
const int _enotty = 25;

// _IOWR('V', 5, struct v4l2_format); the struct is 208 bytes on 64-bit.
const int _vidiocSFmt = 0xC0D05605;
const int _v4l2FormatSize = 208;
const int _v4l2BufTypeVideoOutput = 2;
const int _v4l2FieldNone = 1;

int _fourccCode(String code) {
  final List<int> c = code.codeUnits;
  return c[0] | (c[1] << 8) | (c[2] << 16) | (c[3] << 24);
}

/// Tells the loopback device what we are about to write. Returns false when
/// [fd] is not a V4L2 device (writing to a plain file still works).
bool _setOutputFormat(int fd, int width, int height, String format) {
  final int bpp = _bytesPerPixel[format]!;
  final int bytesPerLine = width * bpp;
  final int sizeImage = bpp > 0 ? bytesPerLine * height : width * height * 2;
  final Pointer<Uint8> buf = calloc<Uint8>(_v4l2FormatSize);
  try {
    final ByteData data = buf.asTypedList(_v4l2FormatSize).buffer.asByteData();
    data.setUint32(0, _v4l2BufTypeVideoOutput, Endian.host);
    // struct v4l2_pix_format starts at offset 8 (the union is 8-byte aligned).
    final pix = <int>[
      width,
      height,
      _fourccCode(_fourcc[format]!),
      _v4l2FieldNone,
      bytesPerLine,
      sizeImage,
      // colorspace, priv, flags, ycbcr_enc, quantization, xfer_func: 0.
    ];
    for (var i = 0; i < pix.length; i++) {
      data.setUint32(8 + i * 4, pix[i], Endian.host);
    }
    if (_ioctl(fd, _vidiocSFmt, buf.cast()) == 0) {
      return true;
    }
    if (_errno == _enotty) {
      return false;
    }
    throw StateError('VIDIOC_S_FMT failed: ${_errnoString()}');
  } finally {
    calloc.free(buf);
  }
}

img.Image _baseImage(int width, int height, String text) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(235, 235, 235));

  final code = QrImage(QrCode(payload: QrPayload.fromString(text)));
  const quietZone = 2;
  final int modules = code.moduleCount + 2 * quietZone;
  final int size = (width < height ? width : height) * 3 ~/ 4;
  final int cell = size ~/ modules;
  if (cell < 1) {
    throw StateError('frame too small for a ${code.moduleCount}-module QR code');
  }
  final int drawn = cell * modules;
  final int x0 = (width - drawn) ~/ 2;
  final int y0 = (height - drawn) ~/ 2;
  img.fillRect(
    image,
    x1: x0,
    y1: y0,
    x2: x0 + drawn - 1,
    y2: y0 + drawn - 1,
    color: img.ColorRgb8(255, 255, 255),
  );
  final img.Color black = img.ColorRgb8(0, 0, 0);
  for (var row = 0; row < code.moduleCount; row++) {
    for (var col = 0; col < code.moduleCount; col++) {
      if (!code.isDark(row, col)) {
        continue;
      }
      final int x = x0 + (col + quietZone) * cell;
      final int y = y0 + (row + quietZone) * cell;
      img.fillRect(image, x1: x, y1: y, x2: x + cell - 1, y2: y + cell - 1, color: black);
    }
  }
  return image;
}

int _clamp(double v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v.round());

/// BT.601 limited range, which is what the library expects from webcams.
Uint8List _toYuyv(img.Image image) {
  final out = Uint8List(image.width * image.height * 2);
  var o = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x += 2) {
      final img.Pixel a = image.getPixel(x, y);
      final img.Pixel b = image.getPixel(x + 1 < image.width ? x + 1 : x, y);
      final double r = a.r.toDouble(), g = a.g.toDouble(), bl = a.b.toDouble();
      out[o++] = _clamp(16 + 0.257 * r + 0.504 * g + 0.098 * bl, 16, 235);
      out[o++] = _clamp(128 - 0.148 * r - 0.291 * g + 0.439 * bl, 16, 240);
      out[o++] = _clamp(16 + 0.257 * b.r + 0.504 * b.g + 0.098 * b.b, 16, 235);
      out[o++] = _clamp(128 + 0.439 * r - 0.368 * g - 0.071 * bl, 16, 240);
    }
  }
  return out;
}

Uint8List _toGrey(img.Image image) {
  final out = Uint8List(image.width * image.height);
  var o = 0;
  for (final p in image) {
    out[o++] = _clamp(img.getLuminanceRgb(p.r, p.g, p.b).toDouble(), 0, 255);
  }
  return out;
}

/// Removes the DHT segments (marker 0xC4) from a baseline JPEG.
Uint8List _stripDht(Uint8List jpeg) {
  final out = BytesBuilder(copy: false)..add(jpeg.sublist(0, 2));
  var pos = 2;
  while (pos + 4 <= jpeg.length) {
    final int marker = jpeg[pos + 1];
    if (marker == 0xDA) {
      out.add(jpeg.sublist(pos));
      return out.takeBytes();
    }
    final int segmentLength = (jpeg[pos + 2] << 8) | jpeg[pos + 3];
    if (marker != 0xC4) {
      out.add(jpeg.sublist(pos, pos + 2 + segmentLength));
    }
    pos += 2 + segmentLength;
  }
  throw const FormatException('no scan in JPEG');
}

Uint8List _encode(img.Image frame, String format, bool stripDht) {
  switch (format) {
    case 'yuyv':
      return _toYuyv(frame);
    case 'rgb24':
      return frame.getBytes(order: img.ChannelOrder.rgb);
    case 'bgr24':
      return frame.getBytes(order: img.ChannelOrder.bgr);
    case 'grey':
      return _toGrey(frame);
    case 'mjpeg':
      final Uint8List jpeg = img.encodeJpg(frame, quality: 85);
      return stripDht ? _stripDht(jpeg) : jpeg;
  }
  throw ArgumentError.value(format, 'format');
}

Future<int> _run(_Options options) async {
  final img.Image base = _baseImage(options.width, options.height, options.text);

  final Pointer<Utf8> path = options.device.toNativeUtf8();
  final int fd;
  try {
    fd = _open(path, _openFlags, _createMode);
  } finally {
    calloc.free(path);
  }
  if (fd < 0) {
    stderr.writeln('cannot open ${options.device}: ${_errnoString()}');
    return 1;
  }

  Pointer<Uint8> buffer = nullptr;
  var bufferSize = 0;
  try {
    final bool isDevice = _setOutputFormat(fd, options.width, options.height, options.format);
    stderr.writeln(
      'writing ${options.format} ${options.width}x${options.height} to ${options.device}'
      '${isDevice ? '' : ' (not a V4L2 device, format ioctl skipped)'}',
    );
    final period = Duration(microseconds: (1e6 / options.fps).round());
    final img.Color bar = img.ColorRgb8(200, 30, 30);
    var n = 0;
    while (options.frames == 0 || n < options.frames) {
      final img.Image frame = base.clone();
      final int barX = (n * 7) % options.width;
      img.fillRect(frame, x1: barX, y1: 0, x2: barX + 6, y2: 12, color: bar);
      final Uint8List bytes = _encode(frame, options.format, options.stripDht);

      if (bytes.length > bufferSize) {
        if (buffer != nullptr) {
          calloc.free(buffer);
        }
        bufferSize = bytes.length;
        buffer = calloc<Uint8>(bufferSize);
      }
      buffer.asTypedList(bufferSize).setRange(0, bytes.length, bytes);
      final int written = _write(fd, buffer, bytes.length);
      if (written != bytes.length) {
        stderr.writeln(
          written < 0
              ? 'write failed: ${_errnoString()}'
              : 'short write: $written of ${bytes.length} bytes',
        );
        return 1;
      }
      n++;
      await Future<void>.delayed(period);
    }
    return 0;
  } finally {
    if (buffer != nullptr) {
      calloc.free(buffer);
    }
    _close(fd);
  }
}

Future<void> main(List<String> args) async {
  final _Options? options;
  try {
    options = _Options.parse(args);
  } on FormatException catch (e) {
    stderr.writeln('${e.message}\n\n$_usage');
    exit(2);
  }
  if (options == null) {
    stderr.write(_usage);
    exit(2);
  }
  exit(await _run(options));
}
