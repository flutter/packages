// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'test_files.dart';

int _fixtureId = 0;

/// Loads the complete compiler/codec/runtime pipeline and renders transparent pixels.
Future<ui.Image> renderSvg(
  String svg, {
  int size = 128,
  double scale = 1,
  double? filterRasterScale,
}) async {
  final Uint8List bytes = encodeSvg(
    xml: svg,
    debugName: 'filter test',
    warningsAsErrors: true,
    enableClippingOptimizer: false,
    enableMaskingOptimizer: false,
    enableOverdrawOptimizer: false,
  );
  final PictureInfo info = await decodeVectorGraphics(
    bytes.buffer.asByteData(),
    locale: null,
    textDirection: ui.TextDirection.ltr,
    clipViewbox: true,
    loader: AssetBytesLoader('filter-test-${_fixtureId++}.svg'),
    filterRasterScale: filterRasterScale ?? scale,
  );
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)
    ..scale(scale * size / info.size.width, scale * size / info.size.height);
  canvas.drawPicture(info.picture);
  final ui.Picture picture = recorder.endRecording();
  info.picture.dispose();
  try {
    return await picture.toImage((size * scale).round(), (size * scale).round());
  } finally {
    picture.dispose();
  }
}

/// Reads straight RGBA bytes to make assertions independent of premultiplication.
Future<Uint8List> pixels(ui.Image image) async =>
    (await image.toByteData(format: ui.ImageByteFormat.rawStraightRgba))!.buffer.asUint8List();

final Map<String, dynamic> _referenceSources =
    jsonDecode(readTestString('test/filters/reference/sources.json')) as Map<String, dynamic>;

/// Identifies whether a test uses the original SVG, an equivalent, or scalar math.
String referenceDescription(String name) {
  final source = _referenceSources[name] as Map<String, dynamic>?;
  if (source == null) {
    throw StateError('Missing reference provenance for $name; run tool/reference_sources.mjs');
  }
  return '${source['kind']} reference: $name';
}

/// Compares against an independent reference with explicit provenance.
Future<void> expectBrowserReference(
  String name, {
  double meanTolerance = 1,
  double badPixelFraction = 0.005,
  int? maxChannelTolerance,
  bool allowOnePixelClipRounding = false,
}) async {
  final ui.Image image = await renderSvg(readTestString('test/filters/fixtures/$name.svg'));
  final ui.Codec codec = await ui.instantiateImageCodec(
    readTestBytes('test/filters/reference/$name.png'),
  );
  final ui.Image reference = (await codec.getNextFrame()).image;
  codec.dispose();
  try {
    expect(image.width, reference.width);
    expect(image.height, reference.height);
    // Compare premultiplied RGB: straight RGB at alpha=1/255 can differ greatly
    // while making less than one display-level contribution to the image.
    Future<Uint8List> premultiplied(ui.Image image) async {
      // Web-decoded PNGs can use the DOM image path, while pictures use a GPU
      // surface. Request straight pixels explicitly and normalize both paths.
      final Uint8List result = await pixels(image);
      for (var i = 0; i < result.length; i += 4) {
        for (var channel = 0; channel < 3; channel++) {
          result[i + channel] = (result[i + channel] * result[i + 3] / 255).round();
        }
      }
      return result;
    }

    final Uint8List actual = await premultiplied(image);
    final Uint8List expected = await premultiplied(reference);
    var total = 0;
    var bad = 0;
    var maximum = 0;
    for (var p = 0; p < actual.length; p += 4) {
      // Browser filter surfaces round fractional bounds outward. Canvas clips
      // retain vector coordinates and round at playback. Only explicitly opted
      // in fixtures may differ at an opaque/transparent boundary by one pixel.
      if (allowOnePixelClipRounding && actual[p + 3] != expected[p + 3]) {
        final int x = (p ~/ 4) % image.width;
        final int y = (p ~/ 4) ~/ image.width;
        var matchesBoundary = false;
        var touchesTransparent = false;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            final int nx = x + dx;
            final int ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= image.width || ny >= image.height) {
              continue;
            }
            final int q = (ny * image.width + nx) * 4;
            touchesTransparent |= actual[q + 3] == 0 || expected[q + 3] == 0;
            final bool match = actual[p + 3] < expected[p + 3]
                ? List<bool>.generate(
                    4,
                    (int c) => (actual[q + c] - expected[p + c]).abs() <= 2,
                  ).every((bool v) => v)
                : List<bool>.generate(
                    4,
                    (int c) => (expected[q + c] - actual[p + c]).abs() <= 2,
                  ).every((bool v) => v);
            matchesBoundary |= match;
          }
        }
        if (actual[p + 3] != 0 && expected[p + 3] != 0) {
          // Partial edge coverage may differ, but its straight color must not.
          for (var c = 0; c < 3; c++) {
            matchesBoundary &=
                (actual[p + c] * 255 / actual[p + 3] - expected[p + c] * 255 / expected[p + 3])
                    .abs() <=
                2;
          }
          matchesBoundary &= touchesTransparent;
        }
        if (matchesBoundary) {
          continue;
        }
      }
      var largest = 0;
      for (var c = 0; c < 4; c++) {
        // RGB in completely transparent pixels has no visible meaning.
        final int difference = c < 3 && actual[p + 3] == 0 && expected[p + 3] == 0
            ? 0
            : (actual[p + c] - expected[p + c]).abs();
        total += difference;
        if (difference > largest) {
          largest = difference;
        }
      }
      if (largest > 20) {
        bad++;
      }
      if (largest > maximum) {
        maximum = largest;
      }
    }
    final double mean = total / actual.length;
    final double fraction = bad / (actual.length / 4);
    if (mean > meanTolerance ||
        fraction > badPixelFraction ||
        (maxChannelTolerance != null && maximum > maxChannelTolerance)) {
      writeFailureImage(
        name,
        (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List(),
      );
    }
    expect(
      mean,
      lessThanOrEqualTo(meanTolerance),
      reason: '${referenceDescription(name)} mean channel error',
    );
    expect(
      fraction,
      lessThanOrEqualTo(badPixelFraction),
      reason: '${referenceDescription(name)} fraction of pixels differing by >20',
    );
    if (maxChannelTolerance != null) {
      expect(
        maximum,
        lessThanOrEqualTo(maxChannelTolerance),
        reason: '${referenceDescription(name)} maximum channel error',
      );
    }
  } finally {
    image.dispose();
    reference.dispose();
  }
}

/// Builds a filter around a rectangle with aligned edges for exact pixel checks.
String filterSvg(
  String primitives, {
  String attributes = '',
  String shape = '<rect x="32" y="32" width="32" height="32" fill="#ff0000"/>',
}) =>
    '''
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128">
<defs><filter id="f" filterUnits="userSpaceOnUse" x="0" y="0" width="128" height="128" color-interpolation-filters="sRGB" $attributes>$primitives</filter></defs>
<g filter="url(#f)">$shape</g></svg>''';
