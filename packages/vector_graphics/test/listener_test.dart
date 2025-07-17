// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show base64;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const String svgString = '''
<svg width="10" height="10">
  <rect x="0" y="0" height="15" width="15" fill="black" />
</svg>
''';

  const String bluePngPixel =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPj/HwADBwIAMCbHYQAAAABJRU5ErkJggg==';

  late ByteData vectorGraphicBuffer;

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

  test('decode without clip', () async {
    final PictureInfo info = await decodeVectorGraphics(
      vectorGraphicBuffer,
      locale: ui.PlatformDispatcher.instance.locale,
      textDirection: ui.TextDirection.ltr,
      clipViewbox: true,
      loader: const AssetBytesLoader('test'),
    );
    final ui.Image image = info.picture.toImageSync(15, 15);
    final Uint32List imageBytes =
        (await image.toByteData())!.buffer.asUint32List();
    expect(imageBytes.first, 0xFF000000);
    expect(imageBytes.last, 0x00000000);
  }, skip: kIsWeb);

  test('decode with clip', () async {
    final PictureInfo info = await decodeVectorGraphics(
      vectorGraphicBuffer,
      locale: ui.PlatformDispatcher.instance.locale,
      textDirection: ui.TextDirection.ltr,
      clipViewbox: false,
      loader: const AssetBytesLoader('test'),
    );
    final ui.Image image = info.picture.toImageSync(15, 15);
    final Uint32List imageBytes =
        (await image.toByteData())!.buffer.asUint32List();
    expect(imageBytes.first, 0xFF000000);
    expect(imageBytes.last, 0xFF000000);
  }, skip: kIsWeb);

  test('Scales image correctly', () async {
    final TestPictureFactory factory = TestPictureFactory();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener(
      pictureFactory: factory,
    );
    listener.onImage(0, 0, base64.decode(bluePngPixel));
    await listener.waitForImageDecode();
    listener.onDrawImage(0, 10, 10, 30, 30, null);
    final Invocation drawRect = factory.fakeCanvases.first.invocations.single;
    expect(drawRect.isMethod, true);
    expect(drawRect.memberName, #drawImageRect);
    expect(
      drawRect.positionalArguments[1],
      const ui.Rect.fromLTRB(0, 0, 1, 1),
    );
    expect(
      drawRect.positionalArguments[2],
      const ui.Rect.fromLTRB(10, 10, 40, 40),
    );
  });

  test('Pattern start clips the new canvas', () async {
    final TestPictureFactory factory = TestPictureFactory();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener(
      pictureFactory: factory,
    );
    listener.onPatternStart(0, 0, 0, 100, 100, Matrix4.identity().storage);
    final Invocation clipRect = factory.fakeCanvases.last.invocations.single;
    expect(clipRect.isMethod, true);
    expect(clipRect.memberName, #clipRect);
    expect(
      clipRect.positionalArguments.single,
      const ui.Rect.fromLTRB(0, 0, 100, 100),
    );
  });

  test('Text position is respected', () async {
    final TestPictureFactory factory = TestPictureFactory();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener(
      pictureFactory: factory,
    );
    listener.onPaintObject(
      color: const ui.Color(0xff000000).value,
      strokeCap: null,
      strokeJoin: null,
      blendMode: BlendMode.srcIn.index,
      strokeMiterLimit: null,
      strokeWidth: null,
      paintStyle: ui.PaintingStyle.fill.index,
      id: 0,
      shaderId: null,
    );
    listener.onTextPosition(0, 10, 10, null, null, true, null);
    listener.onUpdateTextPosition(0);
    listener.onTextConfig('foo', null, 0, 0, 16, 0, 0, 0, 0);
    await listener.onDrawText(0, 0, null, null);
    await listener.onDrawText(0, 0, null, null);

    final Invocation drawParagraph0 = factory.fakeCanvases.last.invocations[0];
    final Invocation drawParagraph1 = factory.fakeCanvases.last.invocations[1];

    expect(drawParagraph0.memberName, #drawParagraph);
    // Only checking the X because Y seems to vary a bit by platform within
    // acceptable range. X is what gets managed by the listener anyway.
    expect((drawParagraph0.positionalArguments[1] as Offset).dx, 10);

    expect(drawParagraph1.memberName, #drawParagraph);
    expect((drawParagraph1.positionalArguments[1] as Offset).dx, 58);
  });

  test('should assert when imageId is invalid', () async {
    final TestPictureFactory factory = TestPictureFactory();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener(
      pictureFactory: factory,
    );
    listener.onImage(0, 0, base64.decode(bluePngPixel));
    await listener.waitForImageDecode();
    expect(() => listener.onDrawImage(2, 10, 10, 100, 100, null),
        throwsAssertionError);
  });
}

class TestPictureFactory implements PictureFactory {
  final List<FakeCanvas> fakeCanvases = <FakeCanvas>[];
  @override
  ui.Canvas createCanvas(ui.PictureRecorder recorder) {
    fakeCanvases.add(FakeCanvas());
    return fakeCanvases.last;
  }

  @override
  ui.PictureRecorder createPictureRecorder() => FakePictureRecorder();
}

class FakePictureRecorder extends Fake implements ui.PictureRecorder {}

class FakeCanvas implements ui.Canvas {
  final List<Invocation> invocations = <Invocation>[];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    invocations.add(invocation);
  }
}
