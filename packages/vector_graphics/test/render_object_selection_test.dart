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
}
