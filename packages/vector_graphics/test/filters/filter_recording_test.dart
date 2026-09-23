// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final scale in <double>[.5, 1, 4]) {
    test('unclipped single-draw picture survives translated playback at $scale', () async {
      final Uint8List bytes = encodeSvg(
        xml: '<svg width="16" height="8"><rect x="-8" width="16" height="8" fill="red"/></svg>',
        debugName: 'unclipped vector recording',
        enableClippingOptimizer: false,
        enableMaskingOptimizer: false,
        enableOverdrawOptimizer: false,
      );
      final PictureInfo info = await decodeVectorGraphics(
        bytes.buffer.asByteData(),
        locale: null,
        textDirection: ui.TextDirection.ltr,
        clipViewbox: false,
        loader: const AssetBytesLoader('unclipped vector recording'),
      );
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.save();
      canvas.translate(40, 24);
      canvas.scale(scale);
      canvas.drawPicture(info.picture);
      canvas.restore();
      final ui.Picture picture = recorder.endRecording();
      info.picture.dispose();
      final ui.Image image = await picture.toImage(128, 128);
      picture.dispose();
      final Uint8List data = await pixels(image);
      image.dispose();
      for (var y = 0; y < 128; y++) {
        for (var x = 0; x < 128; x++) {
          final bool inside =
              x >= 40 - 8 * scale && x < 40 + 8 * scale && y >= 24 && y < 24 + 8 * scale;
          expect(data[(y * 128 + x) * 4 + 3], inside ? 255 : 0, reason: '$x,$y');
        }
      }
    });
  }
}
