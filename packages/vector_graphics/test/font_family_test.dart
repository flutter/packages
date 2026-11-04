// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Reads a font from the Flutter SDK cache with dart:io.
@TestOn('!chrome')
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  setUpAll(() async {
    // Relies on the tool caching the material fonts before running tests.
    final roboto = File(
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
    );
    final bytes = Future<ByteData>.value(ByteData.sublistView(roboto.readAsBytesSync()));
    await (FontLoader('Roboto')..addFont(bytes)).load();
  });

  Future<Uint8List> renderText(String fontFamily) async {
    final Uint8List bytes = encodeSvg(
      xml:
          '''
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="40">
  <text x="0" y="30" font-size="28" font-family="$fontFamily">Hello</text>
</svg>
''',
      debugName: 'font-family',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    final PictureInfo info = await decodeVectorGraphics(
      bytes.buffer.asByteData(),
      locale: ui.PlatformDispatcher.instance.locale,
      textDirection: ui.TextDirection.ltr,
      clipViewbox: true,
      loader: const AssetBytesLoader('font-family'),
    );
    final ui.Image image = info.picture.toImageSync(200, 40);
    final Uint8List pixels = (await image.toByteData())!.buffer.asUint8List();
    image.dispose();
    info.picture.dispose();
    return pixels;
  }

  test('the loaded font renders differently from an unknown font', () async {
    expect(await renderText('Roboto'), isNot(await renderText('NoSuchFont')));
  });

  test('a font-family list uses its first family', () async {
    final Uint8List roboto = await renderText('Roboto');

    expect(await renderText('Roboto, sans-serif'), roboto);
    expect(await renderText("'Roboto', sans-serif"), roboto);
    expect(await renderText(' &quot;Roboto&quot; ,serif'), roboto);
  });
}
