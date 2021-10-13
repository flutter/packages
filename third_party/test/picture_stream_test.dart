import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test/test.dart';

void main() {
  test('PictureInfo Tests', () {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawPaint(Paint()..color = const Color(0xFFFA0000));
    final Picture picture = recorder.endRecording();
    final LayerHandle<PictureLayer> layer = LayerHandle<PictureLayer>();
    layer.layer = PictureLayer(Rect.zero)..picture = picture;
    final PictureInfo info1 = PictureInfo(
      layerHandle: layer,
      viewport: Rect.zero,
      size: Size.zero,
    );

    final PictureInfo info2 = PictureInfo(
      layerHandle: layer,
      viewport: Rect.zero,
      size: Size.zero,
    );
    expect(info1.hashCode, equals(info2.hashCode));
    expect(info1, equals(info2));
  });

  test('Completer disposes layer when removed from cache and no listeners',
      () async {
    final LayerHandle<PictureLayer> layer = LayerHandle<PictureLayer>();
    layer.layer = PictureLayer(Rect.zero);
    final PictureInfo info = PictureInfo(
      layerHandle: layer,
      viewport: Rect.zero,
      size: Size.zero,
    );

    final OneFramePictureStreamCompleter completer =
        OneFramePictureStreamCompleter(Future<PictureInfo>.value(info));

    await null; // wait an event turn for future to resolve.

    expect(layer.layer, isNotNull);
    expect(completer.cached, false);

    completer.cached = true;
    expect(layer.layer, isNotNull);
    completer.cached = false;
    expect(layer.layer, null);
  });

  test(
      'Completer disposes layer when removed from cache and no listeners after having a listener',
      () async {
    final LayerHandle<PictureLayer> layer = LayerHandle<PictureLayer>();
    layer.layer = PictureLayer(Rect.zero);
    final PictureInfo info = PictureInfo(
      layerHandle: layer,
      viewport: Rect.zero,
      size: Size.zero,
    );

    final OneFramePictureStreamCompleter completer =
        OneFramePictureStreamCompleter(Future<PictureInfo>.value(info));

    await null; // wait an event turn for future to resolve.

    expect(layer.layer, isNotNull);
    expect(completer.cached, false);

    void _listener(PictureInfo? image, bool syncCall) {}
    completer.addListener(_listener);
    completer.cached = true;

    completer.removeListener(_listener);
    expect(layer.layer, isNotNull);
    completer.cached = false;
    expect(layer.layer, isNull);
  });

  test('Completer disposes layer when last listener drops and not in cache',
      () async {
    final LayerHandle<PictureLayer> layer = LayerHandle<PictureLayer>();
    layer.layer = PictureLayer(Rect.zero);
    final PictureInfo info = PictureInfo(
      layerHandle: layer,
      viewport: Rect.zero,
      size: Size.zero,
    );

    final OneFramePictureStreamCompleter completer =
        OneFramePictureStreamCompleter(Future<PictureInfo>.value(info));

    await null; // wait an event turn for future to resolve.

    expect(layer.layer, isNotNull);
    expect(completer.cached, false);

    void _listener(PictureInfo? image, bool syncCall) {}
    completer.addListener(_listener);
    completer.cached = true;

    completer.cached = false;
    expect(layer.layer, isNotNull);
    completer.removeListener(_listener);
    expect(layer.layer, isNull);
  });
}
