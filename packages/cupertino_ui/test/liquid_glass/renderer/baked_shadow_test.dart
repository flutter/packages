import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_layer.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_settings.dart';
import 'package:liquid_glass_widgets/src/engine/rendering/liquid_glass_render_object.dart';

// The light-mode shadow under premium glass is drawn with a saveLayer and a
// blur. While the geometry holds still, the layer draws it once into an image
// and then only draws that image, so a resting surface doesn't pay for the
// blur on every frame the backdrop moves. The image must look the same as the
// shadow drawn live.

const _dpr = 2.0;
const _bounds = Rect.fromLTWH(0, 0, 60, 40);
const _offset = Offset(30, 30);
const _size = Size(120, 110);

RenderLiquidGlassLayer _layer(List<BoxShadow> shadows) =>
    RenderLiquidGlassLayer(
      renderShader: null,
      devicePixelRatio: _dpr,
      settings: const LiquidGlassSettings(),
      shadows: shadows,
      link: GeometryRenderLink(),
    );

/// A stand-in for the geometry matte: an opaque rounded rectangle.
ui.Image _matte() {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 120, 80),
      const Radius.circular(40),
    ),
    Paint()..color = const Color(0xFFFFFFFF),
  );
  final picture = recorder.endRecording();
  final image = picture.toImageSync(120, 80);
  picture.dispose();
  return image;
}

Future<Uint8List> _render(void Function(Canvas canvas) paint) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(_dpr);
  paint(canvas);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(
    (_size.width * _dpr).round(),
    (_size.height * _dpr).round(),
  );
  picture.dispose();
  final bytes = await image.toByteData();
  image.dispose();
  return bytes!.buffer.asUint8List();
}

void main() {
  const shadows = [
    BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 7)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  test('draws live while the geometry changes, then bakes it', () {
    final layer = _layer(shadows);
    final first = _matte();
    final second = _matte();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    layer.debugPaintShadows(canvas, _offset, first, _bounds);
    expect(layer.debugBakedShadow, isNull, reason: 'first sight: live');
    layer.debugPaintShadows(canvas, _offset, second, _bounds);
    expect(layer.debugBakedShadow, isNull, reason: 'a new matte: live');
    layer.debugPaintShadows(canvas, _offset, second, _bounds);
    final baked = layer.debugBakedShadow;
    expect(baked, isNotNull, reason: 'the same matte again: baked');

    // The union of the shadows' clips, in whole physical pixels.
    final area = _bounds
        .shift(const Offset(0, 7))
        .inflate(30)
        .expandToInclude(_bounds.shift(const Offset(0, 1)).inflate(9));
    expect(baked!.width, (area.width * _dpr).ceil());
    expect(baked.height, (area.height * _dpr).ceil());

    // Painting again reuses it.
    layer.debugPaintShadows(canvas, _offset, second, _bounds);
    expect(identical(layer.debugBakedShadow, baked), isTrue);

    recorder.endRecording().dispose();
    layer.dispose();
    first.dispose();
    second.dispose();
  });

  test('bakes again when the shadows or the bounds change', () {
    final layer = _layer(shadows);
    final matte = _matte();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    layer
      ..debugPaintShadows(canvas, _offset, matte, _bounds)
      ..debugPaintShadows(canvas, _offset, matte, _bounds);
    final baked = layer.debugBakedShadow;
    expect(baked, isNotNull);

    layer.debugPaintShadows(canvas, _offset, matte, _bounds.inflate(2));
    expect(identical(layer.debugBakedShadow, baked), isFalse);

    final rebaked = layer.debugBakedShadow;
    layer
      ..shadows = const [
        BoxShadow(color: Color(0x40000000), blurRadius: 6),
      ]
      ..debugPaintShadows(canvas, _offset, matte, _bounds.inflate(2));
    expect(identical(layer.debugBakedShadow, rebaked), isFalse);

    recorder.endRecording().dispose();
    layer.dispose();
    matte.dispose();
  });

  test('the baked shadow looks like the live one', () async {
    final matte = _matte();
    final live = await _render((canvas) {
      _layer(shadows).debugPaintShadows(canvas, _offset, matte, _bounds);
    });
    // Two paints of the same matte, off screen: the second one bakes.
    final bakedLayer = _layer(shadows);
    final scratch = ui.PictureRecorder();
    final scratchCanvas = Canvas(scratch);
    bakedLayer
      ..debugPaintShadows(scratchCanvas, _offset, matte, _bounds)
      ..debugPaintShadows(scratchCanvas, _offset, matte, _bounds);
    scratch.endRecording().dispose();
    expect(bakedLayer.debugBakedShadow, isNotNull);
    final bakedOnly = await _render((canvas) {
      bakedLayer.debugPaintShadows(canvas, _offset, matte, _bounds);
    });

    var worst = 0;
    var covered = 0;
    for (var i = 0; i < live.length; i++) {
      final d = (live[i] - bakedOnly[i]).abs();
      if (d > worst) worst = d;
      if (i % 4 == 3 && live[i] > 0) covered++;
    }
    expect(covered, greaterThan(1000), reason: 'the shadow drew something');
    expect(worst, lessThanOrEqualTo(1), reason: 'per channel, out of 255');
    matte.dispose();
    bakedLayer.dispose();
  });
}
