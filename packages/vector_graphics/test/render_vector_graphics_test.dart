// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This Render Object is not used by the HTML renderer.
@TestOn('!chrome')
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/src/render_vector_graphic.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

void main() {
  late PictureInfo pictureInfo;

  tearDown(() {
    // Since we don't always explicitly dispose render objects in unit tests, manually clear
    // the rasters.
    debugClearRasteCaches();
  });

  setUpAll(() async {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    const VectorGraphicsCodec().writeSize(buffer, 50, 50);
    TestWidgetsFlutterBinding.ensureInitialized();

    pictureInfo = await decodeVectorGraphics(
      buffer.done(),
      locale: const Locale('fr', 'CH'),
      textDirection: TextDirection.ltr,
      clipViewbox: true,
      loader: TestBytesLoader(Uint8List(0).buffer.asByteData()),
    );
  });

  test('Rasterizes a picture to a draw image call', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    // When the rasterization is finished, it marks self as needing paint.
    expect(renderVectorGraphic.debugNeedsPaint, true);

    renderVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastImage, isNotNull);
  });

  test('Multiple render objects with the same scale share a raster', () async {
    final RenderVectorGraphic renderVectorGraphicA = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    final RenderVectorGraphic renderVectorGraphicB = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphicA.layout(BoxConstraints.tight(const Size(50, 50)));
    renderVectorGraphicB.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakeHistoryPaintingContext context = FakeHistoryPaintingContext();

    renderVectorGraphicA.paint(context, Offset.zero);
    renderVectorGraphicB.paint(context, Offset.zero);

    // Same image is recycled.
    expect(context.canvas.images, hasLength(2));
    expect(identical(context.canvas.images[0], context.canvas.images[1]), true);
  });

  test('disposing render object release raster', () async {
    final RenderVectorGraphic renderVectorGraphicA = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    final RenderVectorGraphic renderVectorGraphicB = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphicA.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakeHistoryPaintingContext context = FakeHistoryPaintingContext();

    renderVectorGraphicA.paint(context, Offset.zero);

    expect(context.canvas.images, hasLength(1));
    renderVectorGraphicA.dispose();

    renderVectorGraphicB.layout(BoxConstraints.tight(const Size(50, 50)));

    renderVectorGraphicB.paint(context, Offset.zero);
    expect(context.canvas.images, hasLength(2));
    expect(
        identical(context.canvas.images[0], context.canvas.images[1]), false);
  });

  test(
      'Multiple render objects with the same scale share a raster, different load order',
      () async {
    final RenderVectorGraphic renderVectorGraphicA = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    final RenderVectorGraphic renderVectorGraphicB = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphicA.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakeHistoryPaintingContext context = FakeHistoryPaintingContext();

    renderVectorGraphicA.paint(context, Offset.zero);

    expect(context.canvas.images, hasLength(1));

    // Second rasterization immediately paints image.
    renderVectorGraphicB.layout(BoxConstraints.tight(const Size(50, 50)));
    renderVectorGraphicB.paint(context, Offset.zero);

    expect(context.canvas.images, hasLength(2));
    expect(identical(context.canvas.images[0], context.canvas.images[1]), true);
  });

  test('Changing color filter does not re-rasterize', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    final ui.Image firstImage = context.canvas.lastImage!;

    renderVectorGraphic.colorFilter =
        const ui.ColorFilter.mode(Colors.red, ui.BlendMode.colorBurn);
    renderVectorGraphic.paint(context, Offset.zero);

    expect(firstImage.debugDisposed, false);

    renderVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastImage, equals(firstImage));
  });

  test('Changing device pixel ratio does re-rasterize and dispose old raster',
      () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    final ui.Image firstImage = context.canvas.lastImage!;

    renderVectorGraphic.devicePixelRatio = 2.0;
    renderVectorGraphic.paint(context, Offset.zero);

    expect(firstImage.debugDisposed, true);

    renderVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastImage!.debugDisposed, false);
  });

  test('Changing scale does re-rasterize and dispose old raster', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    final ui.Image firstImage = context.canvas.lastImage!;

    renderVectorGraphic.scale = 2.0;
    renderVectorGraphic.paint(context, Offset.zero);

    expect(firstImage.debugDisposed, true);

    renderVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastImage!.debugDisposed, false);
  });

  test('The raster size is increased by the inverse picture scale', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      0.5, // twice as many pixels
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    // Dst rect is always size of RO.
    expect(context.canvas.lastDst, const Rect.fromLTWH(0, 0, 50, 50));
    expect(
        context.canvas.lastSrc, const Rect.fromLTWH(0, 0, 50 / 0.5, 50 / 0.5));
  });

  test('The raster size is increased by the device pixel ratio', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      2.0,
      null,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    // Dst rect is always size of RO.
    expect(context.canvas.lastDst, const Rect.fromLTWH(0, 0, 50, 50));
    expect(context.canvas.lastSrc, const Rect.fromLTWH(0, 0, 100, 100));
  });

  test('The raster size is increased by the device pixel ratio and ratio',
      () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      2.0,
      null,
      0.5,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    // Dst rect is always size of RO.
    expect(context.canvas.lastDst, const Rect.fromLTWH(0, 0, 50, 50));
    expect(context.canvas.lastSrc, const Rect.fromLTWH(0, 0, 200, 200));
  });

  test('Changing size asserts if it is different from the picture size',
      () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    // change size.
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(1000, 1000)));

    expect(() => renderVectorGraphic.paint(context, Offset.zero),
        throwsAssertionError);
  });

  test('Does not rasterize a picture when fully transparent', () async {
    final FixedOpacityAnimation opacity = FixedOpacityAnimation(0.0);
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      opacity,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    opacity.value = 1.0;
    opacity.notifyListeners();

    // Changing opacity requires painting.
    expect(renderVectorGraphic.debugNeedsPaint, true);

    renderVectorGraphic.paint(context, Offset.zero);

    // Rasterization is now complete.
    expect(context.canvas.lastImage, isNotNull);
  });

  test('paints partially opaque picture', () async {
    final FixedOpacityAnimation opacity = FixedOpacityAnimation(0.5);
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      opacity,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastPaint?.color, const Color.fromRGBO(0, 0, 0, 0.5));
  });

  test('Disposing render object disposes picture', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
      1.0,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    final ui.Image lastImage = context.canvas.lastImage!;

    renderVectorGraphic.dispose();

    expect(lastImage.debugDisposed, true);
  });

  test('Removes listeners on detach, dispose, adds then on attach', () async {
    final FixedOpacityAnimation opacity = FixedOpacityAnimation(0.5);
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      opacity,
      1.0,
    );
    final PipelineOwner pipelineOwner = PipelineOwner();
    expect(opacity._listeners, hasLength(1));

    renderVectorGraphic.attach(pipelineOwner);
    expect(opacity._listeners, hasLength(1));

    renderVectorGraphic.detach();
    expect(opacity._listeners, hasLength(0));

    renderVectorGraphic.attach(pipelineOwner);
    expect(opacity._listeners, hasLength(1));

    renderVectorGraphic.dispose();
    expect(opacity._listeners, hasLength(0));
  });

  test('RasterData.dispose is safe to call multiple times', () async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final ui.Image image = await recorder.endRecording().toImage(1, 1);
    final RasterData data = RasterData(image, 1, const RasterKey('test', 1, 1));

    data.dispose();

    expect(data.dispose, returnsNormally);
  });

  test('Color filter applies clip', () async {
    final RenderPictureVectorGraphic render = RenderPictureVectorGraphic(
      pictureInfo,
      const ui.ColorFilter.mode(Colors.green, ui.BlendMode.difference),
      null,
    );
    render.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    render.paint(context, Offset.zero);

    expect(context.canvas.lastClipRect,
        equals(const ui.Rect.fromLTRB(0, 0, 50, 50)));
    expect(context.canvas.saveCount, 0);
    expect(context.canvas.totalSaves, 1);
    expect(context.canvas.totalSaveLayers, 1);
  });

  test('RenderAutoVectorGraphic paints picture correctly with default settings',
      () async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testAutoPicture',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderAutoVectorGraphic.paint(context, Offset.zero);

    // When the rasterization is finished, it marks self as needing paint.
    expect(renderAutoVectorGraphic.debugNeedsPaint, true);

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    // change offset
    renderAutoVectorGraphic.paint(context, const Offset(20, 30));

    expect(context.canvas.saveCount, 0);
    expect(context.canvas.totalSaves, 1);
    expect(context.canvas.totalSaveLayers, 0);

    expect(context.canvas.lastImage, isNull);
    renderAutoVectorGraphic.dispose();
  });

  test('RenderAutoVectorGraphic attaches and detaches listeners correctly',
      () async {
    final FixedOpacityAnimation opacity = FixedOpacityAnimation(0.5);
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testAutoPictureListener',
      null,
      1.0,
      opacity,
      1.0,
    );
    final PipelineOwner pipelineOwner = PipelineOwner();
    expect(opacity._listeners, hasLength(1));

    renderAutoVectorGraphic.attach(pipelineOwner);
    expect(opacity._listeners, hasLength(1));

    renderAutoVectorGraphic.detach();
    expect(opacity._listeners, hasLength(0));

    renderAutoVectorGraphic.attach(pipelineOwner);
    expect(opacity._listeners, hasLength(1));

    renderAutoVectorGraphic.dispose();
    expect(opacity._listeners, hasLength(0));
  });

  test('RasterDataWithPaint.dispose is safe to call multiple times', () async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final ui.Image image = await recorder.endRecording().toImage(1, 1);
    final RasterDataWithPaint data = RasterDataWithPaint(
        image, 1, RasterKeyWithPaint('test', 1, 1, Paint()));

    data.dispose();

    expect(data.dispose, returnsNormally);
  });

  test('RenderAutoVectorGraphic applies color filter with clip correctly',
      () async {
    final FixedOpacityAnimation opacity = FixedOpacityAnimation(0.5);
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      opacity,
      1.0,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderAutoVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastClipRect,
        equals(const ui.Rect.fromLTRB(0, 0, 50, 50)));
    expect(context.canvas.saveCount, 0);
    expect(context.canvas.totalSaves, 1);
    expect(context.canvas.totalSaveLayers, 1);

    renderAutoVectorGraphic.dispose();
  });

  testWidgets('Auto strategy triggers reater cache creation correctly',
      (WidgetTester tester) async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testAuto',
      null,
      1.0,
      null,
      1.0,
    );

    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));

    final FakePaintingContext context = FakePaintingContext();
    renderAutoVectorGraphic.paint(context, Offset.zero);

    // When the rasterization is finished, it marks self as needing paint.
    expect(renderAutoVectorGraphic.debugNeedsPaint, true);
    expect(context.canvas.lastImage, isNull);

    await tester.pump();
    // a new paint will delay the raster cache creating.
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    await tester.pump();
    // a new paint will delay the raster cache creating.
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    // two additional frame will create the raster cache.
    await tester.pump();
    await tester.pump();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    renderAutoVectorGraphic.dispose();
  });

  testWidgets(
      'Multiple RenderAutoVectorGraphics create raster cache sequentially',
      (WidgetTester tester) async {
    final List<RenderAutoVectorGraphic> renderAutoVectorGraphic =
        List<RenderAutoVectorGraphic>.generate(
      3,
      (int index) => RenderAutoVectorGraphic(
        pictureInfo,
        'test_$index',
        null,
        1.0,
        null,
        1.0,
      ),
    );

    final FakePaintingContext context = FakePaintingContext();

    for (final RenderAutoVectorGraphic renderVectorGraphic
        in renderAutoVectorGraphic) {
      renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    }

    // all image don't have raster cache
    for (int i = 0; i < renderAutoVectorGraphic.length; i++) {
      renderAutoVectorGraphic[i].paint(context, Offset.zero);
      expect(context.canvas.lastImage, isNull);
      context.canvas.resetImage();
    }

    await tester.pump();

    // 2st frame:
    await tester.pump();
    for (int i = 0; i < renderAutoVectorGraphic.length; i++) {
      renderAutoVectorGraphic[i].paint(context, Offset.zero);
      if (i == 0) {
        expect(context.canvas.lastImage, isNotNull);
      } else {
        expect(context.canvas.lastImage, isNull);
      }
      context.canvas.resetImage();
    }
    await tester.pump();

    // 3st frame:
    await tester.pump();

    for (int i = 0; i < renderAutoVectorGraphic.length; i++) {
      renderAutoVectorGraphic[i].paint(context, Offset.zero);
      if (i <= 1) {
        expect(context.canvas.lastImage, isNotNull);
      } else {
        expect(context.canvas.lastImage, isNull);
      }
      context.canvas.resetImage();
    }
    await tester.pump();

    await tester.pump();
    // 4st frame
    for (int i = 0; i < renderAutoVectorGraphic.length; i++) {
      renderAutoVectorGraphic[i].paint(context, Offset.zero);
      expect(context.canvas.lastImage, isNotNull);
      context.canvas.resetImage();
      renderAutoVectorGraphic[i].dispose();
    }

    // now new widget will get a reset delay time:
    final RenderAutoVectorGraphic renderAutoVectorGraphicEnd =
        RenderAutoVectorGraphic(
      pictureInfo,
      'test_end',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphicEnd.layout(BoxConstraints.tight(const Size(50, 50)));
    expect(context.canvas.lastImage, isNull);

    renderAutoVectorGraphicEnd.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    await tester.pump();
    await tester.pump();
    renderAutoVectorGraphicEnd.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    renderAutoVectorGraphicEnd.dispose();
  });

  testWidgets(
      'The raster size is increased by the device pixel ratio in auto startegy',
      (WidgetTester tester) async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testPixelRatio',
      null,
      2.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderAutoVectorGraphic.paint(context, Offset.zero);

    await tester.pump();
    await tester.pump();
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    expect(context.canvas.lastDst, const Rect.fromLTWH(0, 0, 50, 50));
    expect(context.canvas.lastSrc, const Rect.fromLTWH(0, 0, 100, 100));
    context.canvas.resetImage();

    renderAutoVectorGraphic.devicePixelRatio = 3.0;

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    await tester.pump();
    await tester.pump();
    renderAutoVectorGraphic.paint(context, Offset.zero);

    // devicePixelRatio change, raster cache will be a new one.
    expect(context.canvas.lastDst, const Rect.fromLTWH(0, 0, 50, 50));
    expect(context.canvas.lastSrc, const Rect.fromLTWH(0, 0, 150, 150));

    renderAutoVectorGraphic.dispose();
  });

  testWidgets('Raster size scales when canvas is transformed',
      (WidgetTester tester) async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testScaled',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    await tester.pump();
    await tester.pump();
    expect(context.canvas.lastImage, isNull);

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastSrc, const Rect.fromLTWH(0, 0, 50, 50));
    expect(context.canvas.lastImage, isNotNull);

    context.canvas.scale(2.0, 2.0);
    renderAutoVectorGraphic.paint(context, Offset.zero);
    await tester.pump();
    await tester.pump();
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastSrc, const Rect.fromLTWH(0, 0, 100, 100));
    expect(context.canvas.lastImage, isNotNull);

    renderAutoVectorGraphic.dispose();
  });

  testWidgets('Auto strategy reuses cache when creating image',
      (WidgetTester tester) async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testCache',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    await tester.pump();
    await tester.pump();
    expect(context.canvas.lastImage, isNull);

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    final ui.Image? oldImage = context.canvas.lastImage;
    context.canvas.resetImage();

    final RenderAutoVectorGraphic renderAutoVectorGraphic2 =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testCache',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic2.layout(BoxConstraints.tight(const Size(50, 50)));
    renderAutoVectorGraphic2.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);
    expect(context.canvas.lastImage, equals(oldImage));

    renderAutoVectorGraphic.dispose();
    renderAutoVectorGraphic2.dispose();
  });

  testWidgets('Changing color filter does re-rasterize in auto strategy',
      (WidgetTester tester) async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testColorFilter',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    await tester.pump();
    await tester.pump();
    expect(context.canvas.lastImage, isNull);

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    final ui.Image? oldImage = context.canvas.lastImage;
    context.canvas.resetImage();

    renderAutoVectorGraphic.colorFilter =
        const ui.ColorFilter.mode(Colors.red, ui.BlendMode.colorBurn);
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    await tester.pump();
    await tester.pump();
    renderAutoVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastImage, isNotNull);
    expect(context.canvas.lastImage, isNot(oldImage));

    renderAutoVectorGraphic.dispose();
  });

  testWidgets('Changing offset does not re-rasterize in auto strategy',
      (WidgetTester tester) async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testOffset',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    await tester.pump();
    await tester.pump();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    final ui.Image? oldImage = context.canvas.lastImage;
    context.canvas.resetImage();

    renderAutoVectorGraphic.paint(context, const Offset(20, 30));
    expect(context.canvas.lastImage, isNotNull);
    expect(context.canvas.lastImage, equals(oldImage));

    renderAutoVectorGraphic.dispose();
  });

  testWidgets('RenderAutoVectorGraphic disposal during rasterization is safe',
      (WidgetTester tester) async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testDispose',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);
    await tester.pump();

    renderAutoVectorGraphic.dispose();
    await tester.pump();
    await tester.pump();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);
  });

  testWidgets('RenderAutoVectorGraphic re-rasterizes when opacity changes',
      (WidgetTester tester) async {
    final FixedOpacityAnimation opacity = FixedOpacityAnimation(0.0);
    final RenderAutoVectorGraphic renderAutoVectorGraphic =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testOpacity',
      null,
      1.0,
      opacity,
      1.0,
    );

    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    // full transparent means no raster cache.
    await tester.pump();
    await tester.pump();
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    opacity.value = 0.5;
    opacity.notifyListeners();

    // Changing opacity requires painting.
    expect(renderAutoVectorGraphic.debugNeedsPaint, true);

    // Changing opacity need create new raster cache.
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    await tester.pump();
    await tester.pump();
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    renderAutoVectorGraphic.dispose();
  });

  testWidgets(
      'Identical widgets reuse raster cache when available in auto startegy',
      (WidgetTester tester) async {
    final RenderAutoVectorGraphic renderAutoVectorGraphic1 =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testOffset',
      null,
      1.0,
      null,
      1.0,
    );
    final RenderAutoVectorGraphic renderAutoVectorGraphic2 =
        RenderAutoVectorGraphic(
      pictureInfo,
      'testOffset',
      null,
      1.0,
      null,
      1.0,
    );
    renderAutoVectorGraphic1.layout(BoxConstraints.tight(const Size(50, 50)));
    renderAutoVectorGraphic2.layout(BoxConstraints.tight(const Size(50, 50)));

    final FakePaintingContext context = FakePaintingContext();

    renderAutoVectorGraphic1.paint(context, Offset.zero);
    renderAutoVectorGraphic2.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNull);

    await tester.pump();
    await tester.pump();

    renderAutoVectorGraphic1.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);
    final ui.Image? oldImage = context.canvas.lastImage;

    context.canvas.resetImage();

    renderAutoVectorGraphic2.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);
    expect(context.canvas.lastImage, equals(oldImage));

    renderAutoVectorGraphic1.dispose();
    renderAutoVectorGraphic2.dispose();
  });
}

class FakeCanvas extends Fake implements Canvas {
  ui.Image? lastImage;
  Rect? lastSrc;
  Rect? lastDst;
  Paint? lastPaint;
  Rect? lastClipRect;
  int saveCount = 0;
  int totalSaves = 0;
  int totalSaveLayers = 0;
  double scaleX = 1.0;
  double scaleY = 1.0;

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {
    lastImage = image;
    lastSrc = src;
    lastDst = dst;
    lastPaint = paint;
  }

  @override
  void drawPicture(ui.Picture picture) {}

  @override
  int getSaveCount() {
    return saveCount;
  }

  @override
  void restoreToCount(int count) {
    saveCount = count;
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    saveCount++;
    totalSaveLayers++;
  }

  @override
  void save() {
    saveCount++;
    totalSaves++;
  }

  @override
  void restore() {
    saveCount--;
  }

  @override
  void clipRect(ui.Rect rect,
      {ui.ClipOp clipOp = ui.ClipOp.intersect, bool doAntiAlias = true}) {
    lastClipRect = rect;
  }

  @override
  void scale(double sx, [double? sy]) {
    scaleX = sx;
    scaleY = sx;
    if (sy != null) {
      scaleY = sy;
    }
  }

  @override
  void translate(double dx, double dy) {}

  @override
  Float64List getTransform() {
    return Float64List.fromList(
        <double>[scaleX, 0, 0, 0, 0, scaleY, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
  }

  void resetImage() {
    lastImage = null;
  }
}

class FakeHistoryCanvas extends Fake implements Canvas {
  final List<ui.Image> images = <ui.Image>[];

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {
    images.add(image);
  }
}

class FakePaintingContext extends Fake implements PaintingContext {
  @override
  final FakeCanvas canvas = FakeCanvas();
}

class FakeHistoryPaintingContext extends Fake implements PaintingContext {
  @override
  final FakeHistoryCanvas canvas = FakeHistoryCanvas();
}

class FixedOpacityAnimation extends Animation<double> {
  FixedOpacityAnimation(this.value);

  final Set<ui.VoidCallback> _listeners = <ui.VoidCallback>{};

  @override
  void addListener(ui.VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    throw UnsupportedError('addStatusListener');
  }

  @override
  void removeListener(ui.VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    throw UnsupportedError('removeStatusListener');
  }

  @override
  AnimationStatus get status => AnimationStatus.forward;

  @override
  double value = 1.0;

  void notifyListeners() {
    for (final ui.VoidCallback listener in _listeners) {
      listener();
    }
  }
}

class TestBytesLoader extends BytesLoader {
  const TestBytesLoader(this.data);

  final ByteData data;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    return data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) {
    return other is TestBytesLoader && other.data == data;
  }
}
