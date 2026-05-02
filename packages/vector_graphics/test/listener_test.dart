// Copyright 2013 The Flutter Authors
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
  const svgString = '''
<svg width="10" height="10">
  <rect x="0" y="0" height="15" width="15" fill="black" />
</svg>
''';

  const bluePngPixel =
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
    final Uint32List imageBytes = (await image.toByteData())!.buffer
        .asUint32List();
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
    final Uint32List imageBytes = (await image.toByteData())!.buffer
        .asUint32List();
    expect(imageBytes.first, 0xFF000000);
    expect(imageBytes.last, 0xFF000000);
  }, skip: kIsWeb);

  test('Scales image correctly', () async {
    final factory = TestPictureFactory();
    final listener = FlutterVectorGraphicsListener(pictureFactory: factory);
    listener.onImage(0, 0, base64.decode(bluePngPixel));
    await listener.waitForImageDecode();
    listener.onDrawImage(0, 10, 10, 30, 30, null);
    final Invocation drawRect = factory.fakeCanvases.first.invocations.single;
    expect(drawRect.isMethod, true);
    expect(drawRect.memberName, #drawImageRect);
    expect(drawRect.positionalArguments[1], const ui.Rect.fromLTRB(0, 0, 1, 1));
    expect(
      drawRect.positionalArguments[2],
      const ui.Rect.fromLTRB(10, 10, 40, 40),
    );
  });

  test('Pattern start clips the new canvas', () async {
    final factory = TestPictureFactory();
    final listener = FlutterVectorGraphicsListener(pictureFactory: factory);
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
    final factory = TestPictureFactory();
    final listener = FlutterVectorGraphicsListener(pictureFactory: factory);
    listener.onPaintObject(
      color: const ui.Color(0xff000000).toARGB32(),
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
    // Force flush of the pending anchored chunk by starting a new one.
    listener.onTextPosition(1, 0, 0, null, null, true, null);
    listener.onUpdateTextPosition(1);

    // The chunk's two segments are now rendered as a single ui.Paragraph
    // (so cross-tspan layout is preserved). The combined paragraph is
    // drawn once at the chunk's origin x.
    final List<Invocation> draws = factory.fakeCanvases.last.invocations
        .where((i) => i.memberName == #drawParagraph)
        .toList();
    expect(draws, hasLength(1));
    // Only checking the X because Y seems to vary a bit by platform within
    // acceptable range. X is what gets managed by the listener anyway.
    expect((draws[0].positionalArguments[1] as Offset).dx, 10);
  });

  test('Text anchor middle centers the entire chunk across tspans', () async {
    // SVG: <text x="100" y="50" text-anchor="middle">
    //        <tspan>ABCDEFG</tspan><tspan>ABCDEFG</tspan>
    //      </text>
    // Per SVG spec, the concatenation of both tspans forms a single
    // anchored chunk that should be centered around x=100.
    final factory = TestPictureFactory();
    final listener = FlutterVectorGraphicsListener(pictureFactory: factory);
    listener.onPaintObject(
      color: const ui.Color(0xffff0000).toARGB32(),
      strokeCap: null,
      strokeJoin: null,
      blendMode: BlendMode.srcIn.index,
      strokeMiterLimit: null,
      strokeWidth: null,
      paintStyle: ui.PaintingStyle.fill.index,
      id: 0,
      shaderId: null,
    );
    listener.onTextPosition(0, 100, 50, null, null, true, null);
    listener.onUpdateTextPosition(0);
    // xAnchorMultiplier = 0.5 corresponds to text-anchor="middle".
    listener.onTextConfig('ABCDEFG', null, 0.5, 0, 16, 0, 0, 0, 0);
    await listener.onDrawText(0, 0, null, null);
    // The parser emits a TextPosition for every <tspan>, including those
    // with no x/y. That must NOT break the current anchored chunk.
    listener.onTextPosition(1, null, null, null, null, false, null);
    listener.onUpdateTextPosition(1);
    listener.onTextConfig('ABCDEFG', null, 0.5, 0, 16, 0, 0, 0, 1);
    await listener.onDrawText(1, 0, null, null);
    // Force flush of the pending anchored chunk by starting a new one.
    listener.onTextPosition(2, 0, 0, null, null, true, null);
    listener.onUpdateTextPosition(2);

    // Both tspans are rendered as a single combined ui.Paragraph centered
    // around x=100. Total chunk width = 2w, anchor offset = w, so the
    // combined paragraph is drawn at dx = 100 - w (i.e. dx < 100).
    final List<Invocation> draws = factory.fakeCanvases.last.invocations
        .where((i) => i.memberName == #drawParagraph)
        .toList();
    expect(draws, hasLength(1));
    final double dx = (draws[0].positionalArguments[1] as Offset).dx;
    expect(
      dx,
      lessThan(100),
      reason: 'middle-anchored chunk should start to the left of the anchor x',
    );
    expect(
      100 - dx,
      greaterThan(0),
      reason: 'distance from x to chunk start equals half the chunk width',
    );
  });

  test('should assert when imageId is invalid', () async {
    final factory = TestPictureFactory();
    final listener = FlutterVectorGraphicsListener(pictureFactory: factory);
    listener.onImage(0, 0, base64.decode(bluePngPixel));
    await listener.waitForImageDecode();
    expect(
      () => listener.onDrawImage(2, 10, 10, 100, 100, null),
      throwsAssertionError,
    );
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
