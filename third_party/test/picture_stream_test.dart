import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test/test.dart';

void main() {
  test(
      'Picture does not get disposed if there are outstanding undisposed layers',
      () async {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawPaint(Paint()..color = const Color(0xFFFA0000));
    final Picture picture = recorder.endRecording();

    final PictureInfo info = PictureInfo(
      picture: picture,
      viewport: Rect.zero,
      size: Size.zero,
      compatibilityTester: const CacheCompatibilityTester(),
    );

    final OneFramePictureStreamCompleter completer =
        OneFramePictureStreamCompleter(Future<PictureInfo>.value(info));

    await null; // wait an event turn for future to resolve.

    expect(info.picture, isNotNull);
    final PictureLayer layer = info.createLayer();
    expect(info.picture, isNotNull);

    void listener(PictureInfo? image, bool synchronousCall) {}

    completer.addListener(listener);
    completer.removeListener(listener);
    expect(info.picture, isNotNull);

    layer.dispose();
    expect(info.picture, null);
  });

  test('Completer disposes layer when removed from cache and no listeners',
      () async {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawPaint(Paint()..color = const Color(0xFFFA0000));
    final Picture picture = recorder.endRecording();

    final PictureInfo info = PictureInfo(
      picture: picture,
      viewport: Rect.zero,
      size: Size.zero,
      compatibilityTester: const CacheCompatibilityTester(),
    );

    final OneFramePictureStreamCompleter completer =
        OneFramePictureStreamCompleter(Future<PictureInfo>.value(info));

    await null; // wait an event turn for future to resolve.

    expect(info.picture, isNotNull);
    expect(completer.cached, false);

    completer.cached = true;
    expect(info.picture, isNotNull);
    completer.cached = false;
    expect(info.picture, null);
  });

  test(
      'Completer disposes layer when removed from cache and no listeners after having a listener',
      () async {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawPaint(Paint()..color = const Color(0xFFFA0000));
    final Picture picture = recorder.endRecording();

    final PictureInfo info = PictureInfo(
      picture: picture,
      viewport: Rect.zero,
      size: Size.zero,
      compatibilityTester: const CacheCompatibilityTester(),
    );

    final OneFramePictureStreamCompleter completer =
        OneFramePictureStreamCompleter(Future<PictureInfo>.value(info));

    await null; // wait an event turn for future to resolve.

    expect(info.picture, isNotNull);
    expect(completer.cached, false);

    void _listener(PictureInfo? image, bool syncCall) {}
    completer.addListener(_listener);
    completer.cached = true;

    completer.removeListener(_listener);
    expect(info.picture, isNotNull);
    completer.cached = false;
    expect(info.picture, isNull);
  });

  test('Completer disposes layer when last listener drops and not in cache',
      () async {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawPaint(Paint()..color = const Color(0xFFFA0000));
    final Picture picture = recorder.endRecording();

    final PictureInfo info = PictureInfo(
      picture: picture,
      viewport: Rect.zero,
      size: Size.zero,
      compatibilityTester: const CacheCompatibilityTester(),
    );

    final OneFramePictureStreamCompleter completer =
        OneFramePictureStreamCompleter(Future<PictureInfo>.value(info));

    await null; // wait an event turn for future to resolve.

    expect(info.picture, isNotNull);
    expect(completer.cached, false);

    void _listener(PictureInfo? image, bool syncCall) {}
    completer.addListener(_listener);
    completer.cached = true;

    completer.cached = false;
    expect(info.picture, isNotNull);
    completer.removeListener(_listener);
    expect(info.picture, isNull);
  });
}
