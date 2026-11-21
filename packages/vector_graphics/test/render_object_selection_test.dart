// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/render_object_selection.dart';

void main() {
  setUp(debugResetUseHtmlRenderObject);
  tearDown(debugResetUseHtmlRenderObject);

  test(
    'falls back to HTML render object and caches result when toImageSync throws unhandled throwable',
    () {
      var callCount = 0;
      debugToImageSyncOverride = (picture, width, height) {
        callCount++;
        // ignore: only_throw_errors
        throw 'Canvas with id [object OffscreenCanvas] was not found';
      };

      expect(useHtmlRenderObject(), isTrue);
      expect(callCount, 1);

      // Verify the fallback result was cached and toImageSync is not invoked again.
      expect(useHtmlRenderObject(), isTrue);
      expect(callCount, 1);
    },
  );

  test('falls back to HTML render object when toImageSync throws Error', () {
    var callCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      callCount++;
      throw Error();
    };

    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);
    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);
  });

  test('falls back to HTML render object when toImageSync throws Exception', () {
    var callCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      callCount++;
      throw Exception('Failed to initialize CanvasKit SkSurface.');
    };

    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);
    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);
  });

  test('falls back to HTML render object when toImageSync throws null', () {
    var callCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      callCount++;
      // ignore: throw_of_invalid_type
      throw (null as dynamic);
    };

    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);
    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);
  });

  test('returns false and caches false on success path when toImageSync succeeds', () {
    var callCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      callCount++;
      return null;
    };

    expect(useHtmlRenderObject(), isFalse);
    expect(callCount, 1);

    // Verify the success result was cached and toImageSync is not invoked again.
    expect(useHtmlRenderObject(), isFalse);
    expect(callCount, 1);
  });

  test('debugResetUseHtmlRenderObject resets cached state and test override', () {
    var callCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      callCount++;
      // ignore: only_throw_errors
      throw 'Canvas with id [object OffscreenCanvas] was not found';
    };

    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);

    debugResetUseHtmlRenderObject();
    expect(debugToImageSyncOverride, isNull);

    var secondCallCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      secondCallCount++;
      return null;
    };

    expect(useHtmlRenderObject(), isFalse);
    expect(secondCallCount, 1);
    expect(callCount, 1);
  });

  test('returns false by default when no test override is set', () {
    expect(debugToImageSyncOverride, isNull);
    expect(useHtmlRenderObject(), isFalse);
    expect(useHtmlRenderObject(), isFalse);
  });

  test('falls back to HTML render object when toImageSync throws arbitrary foreign object', () {
    var callCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      callCount++;
      // ignore: only_throw_errors
      throw const <String, Object?>{'code': -1, 'message': 'GPU context lost'};
    };

    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);
    expect(useHtmlRenderObject(), isTrue);
    expect(callCount, 1);
  });

  test('debugResetUseHtmlRenderObject is idempotent when called repeatedly', () {
    // Calling reset multiple times before any override is set should not throw.
    debugResetUseHtmlRenderObject();
    debugResetUseHtmlRenderObject();
    expect(debugToImageSyncOverride, isNull);

    var callCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      callCount++;
      return null;
    };
    expect(useHtmlRenderObject(), isFalse);
    expect(callCount, 1);

    // Calling reset multiple times after use should cleanly reset every time.
    debugResetUseHtmlRenderObject();
    debugResetUseHtmlRenderObject();
    expect(debugToImageSyncOverride, isNull);
  });

  test('debugResetUseHtmlRenderObject allows transitioning from cached false to true fallback', () {
    var successCallCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      successCallCount++;
      return null;
    };

    expect(useHtmlRenderObject(), isFalse);
    expect(successCallCount, 1);

    debugResetUseHtmlRenderObject();
    expect(debugToImageSyncOverride, isNull);

    var failureCallCount = 0;
    debugToImageSyncOverride = (picture, width, height) {
      failureCallCount++;
      // ignore: only_throw_errors
      throw 'Canvas with id [object OffscreenCanvas] was not found';
    };

    expect(useHtmlRenderObject(), isTrue);
    expect(failureCallCount, 1);
    expect(successCallCount, 1);
  });

  test('returns false when called after reset without an override set', () {
    debugToImageSyncOverride = (picture, width, height) {
      // ignore: only_throw_errors
      throw 'Canvas with id [object OffscreenCanvas] was not found';
    };

    expect(useHtmlRenderObject(), isTrue);

    debugResetUseHtmlRenderObject();
    expect(debugToImageSyncOverride, isNull);

    // After reset with no override, should return false by default on non-web platforms.
    expect(useHtmlRenderObject(), isFalse);
  });
}
