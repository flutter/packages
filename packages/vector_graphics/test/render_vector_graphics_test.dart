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
    );
    final RenderVectorGraphic renderVectorGraphicB = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
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
    );
    final RenderVectorGraphic renderVectorGraphicB = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
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
    );
    final RenderVectorGraphic renderVectorGraphicB = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
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

  test('Changing color filter does re-rasterize', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    final ui.Image firstImage = context.canvas.lastImage!;

    renderVectorGraphic.colorFilter =
        const ui.ColorFilter.mode(Colors.red, ui.BlendMode.colorBurn);
    renderVectorGraphic.paint(context, Offset.zero);

    expect(firstImage.debugDisposed, true);

    renderVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastImage, isNot(firstImage));
  });

  test('Changing device pixel ratio does re-rasterize and dispose old raster',
      () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
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
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    final ui.Image firstImage = context.canvas.lastImage!;

    context.canvas.scale(2.0, 2.0);
    renderVectorGraphic.paint(context, Offset.zero);

    expect(firstImage.debugDisposed, true);

    renderVectorGraphic.paint(context, Offset.zero);

    expect(context.canvas.lastImage!.debugDisposed, false);
  });

  test('The raster size is increased by the canvas scale', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    context.canvas.scale(2.0, 2.0);
    renderVectorGraphic.paint(context, Offset.zero);

    // Dst rect is always size of RO.
    expect(context.canvas.lastDst, const Rect.fromLTWH(0, 0, 50, 50));
    expect(
        context.canvas.lastSrc, const Rect.fromLTWH(0, 0, 50 * 2.0, 50 * 2.0));
  });

  test('The raster size is increased by the device pixel ratio', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      2.0,
      null,
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
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    context.canvas.scale(2.0, 2.0);
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
    );
    renderVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderVectorGraphic.paint(context, Offset.zero);

    // opaque is used to generate raster cache.
    expect(context.canvas.lastPaint?.color, const Color.fromRGBO(0, 0, 0, 1.0));
  });

  test('Disposing render object disposes picture', () async {
    final RenderVectorGraphic renderVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'test',
      null,
      1.0,
      null,
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
    final Paint paint = Paint();
    final RasterData data =
        RasterData(image, 1, RasterKey('test', 1, 1, paint));

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

  testWidgets('Changing offset does not re-rasterize in auto strategy',
      (WidgetTester tester) async {
    final RenderVectorGraphic renderAutoVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'testOffset',
      null,
      1.0,
      null,
    );
    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();

    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    final ui.Image? oldImage = context.canvas.lastImage;

    renderAutoVectorGraphic.paint(context, const Offset(20, 30));
    expect(context.canvas.lastImage, isNotNull);
    expect(context.canvas.lastImage, equals(oldImage));

    renderAutoVectorGraphic.dispose();
  });

  testWidgets('RenderAutoVectorGraphic re-rasterizes when opacity changes',
      (WidgetTester tester) async {
    final FixedOpacityAnimation opacity = FixedOpacityAnimation(0.2);
    final RenderVectorGraphic renderAutoVectorGraphic = RenderVectorGraphic(
      pictureInfo,
      'testOpacity',
      null,
      1.0,
      opacity,
    );

    renderAutoVectorGraphic.layout(BoxConstraints.tight(const Size(50, 50)));
    final FakePaintingContext context = FakePaintingContext();
    renderAutoVectorGraphic.paint(context, Offset.zero);

    final ui.Image? oldImage = context.canvas.lastImage;

    opacity.value = 0.5;
    opacity.notifyListeners();

    // Changing opacity requires painting.
    expect(renderAutoVectorGraphic.debugNeedsPaint, true);

    // Changing opacity need create new raster cache.
    renderAutoVectorGraphic.paint(context, Offset.zero);
    expect(context.canvas.lastImage, isNotNull);

    expect(context.canvas.lastImage, isNot(oldImage));

    renderAutoVectorGraphic.dispose();
  });

  testWidgets(
      'Identical widgets reuse raster cache when available in auto startegy',
      (WidgetTester tester) async {
    final RenderVectorGraphic renderAutoVectorGraphic1 = RenderVectorGraphic(
      pictureInfo,
      'testOffset',
      null,
      1.0,
      null,
    );
    final RenderVectorGraphic renderAutoVectorGraphic2 = RenderVectorGraphic(
      pictureInfo,
      'testOffset',
      null,
      1.0,
      null,
    );
    renderAutoVectorGraphic1.layout(BoxConstraints.tight(const Size(50, 50)));
    renderAutoVectorGraphic2.layout(BoxConstraints.tight(const Size(50, 50)));

    final FakePaintingContext context = FakePaintingContext();

    renderAutoVectorGraphic1.paint(context, Offset.zero);

    final ui.Image? image1 = context.canvas.lastImage;

    renderAutoVectorGraphic2.paint(context, Offset.zero);

    final ui.Image? image2 = context.canvas.lastImage;

    expect(image1, isNotNull);
    expect(image2, isNotNull);

    expect(image1, equals(image2));

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
}

class FakeHistoryCanvas extends Fake implements Canvas {
  final List<ui.Image> images = <ui.Image>[];

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {
    images.add(image);
  }

  @override
  Float64List getTransform() {
    return Float64List.fromList(
        <double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
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
