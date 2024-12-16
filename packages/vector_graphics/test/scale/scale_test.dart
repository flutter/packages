// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import '../vector_graphics_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final ByteData vectorGraphicBuffer;
  const String svgString = '''
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M18 21H7V8L14 1L15.25 2.25C15.3667 2.36667 15.4625 2.525 15.5375 2.725C15.6125 2.925 15.65 3.11667 15.65 3.3V3.65L14.55 8H21C21.5333 8 22 8.2 22.4 8.6C22.8 9 23 9.46667 23 10V12C23 12.1167 22.9833 12.2417 22.95 12.375C22.9167 12.5083 22.8833 12.6333 22.85 12.75L19.85 19.8C19.7 20.1333 19.45 20.4167 19.1 20.65C18.75 20.8833 18.3833 21 18 21ZM9 19H18L21 12V10H12L13.35 4.5L9 8.85V19ZM7 8V10H4V19H7V21H2V8H7Z" fill="#0066FF"/>
          </svg>
        ''';

  setUpAll(() async {
    final Uint8List bytes = encodeSvg(
      xml: svgString,
      debugName: 'test',
      enableClippingOptimizer: false,
      enableMaskingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    vectorGraphicBuffer = bytes.buffer.asByteData();
  });

  setUp(() {
    imageCache.clear();
    imageCache.clearLiveImages();
  });

  Future<ui.Image> decode({
    required Size target,
  }) async {
    final PictureInfo info = await decodeVectorGraphics(
      vectorGraphicBuffer,
      locale: ui.PlatformDispatcher.instance.locale,
      textDirection: ui.TextDirection.ltr,
      clipViewbox: true,
      loader: TestBytesLoader(vectorGraphicBuffer),
      targetSize: target,
    );
    return info.picture.toImageSync(
      target.width.toInt(),
      target.height.toInt(),
    );
  }

  testWidgets('resizes to the same size', (_) async {
    final ui.Image image = await decode(
      target: const Size(24, 24),
    );

    await expectLater(
      image,
      matchesGoldenFile('thumb_up_24px.png'),
    );
  });

  testWidgets('resizes to larger size', (_) async {
    final ui.Image image = await decode(
      target: const Size(64, 64),
    );

    await expectLater(
      image,
      matchesGoldenFile('thumb_up_64px.png'),
    );
  });

  testWidgets('resizes to smaller size', (_) async {
    final ui.Image image = await decode(
      target: const Size(16, 16),
    );

    await expectLater(
      image,
      matchesGoldenFile('thumb_up_16px.png'),
    );
  });
}
