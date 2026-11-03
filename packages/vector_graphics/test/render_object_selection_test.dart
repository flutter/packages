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
}
