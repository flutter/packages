// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

bool? _cachedUseHtmlRenderObject;

/// Signature for overriding [ui.Picture.toImageSync] during testing.
@visibleForTesting
typedef ToImageSyncCallback = ui.Image? Function(ui.Picture picture, int width, int height);

/// Test hook allowing tests to simulate [ui.Picture.toImageSync] behavior.
@visibleForTesting
ToImageSyncCallback? debugToImageSyncOverride;

/// Resets the cached HTML render object selection and any test override.
@visibleForTesting
void debugResetUseHtmlRenderObject() {
  _cachedUseHtmlRenderObject = null;
  debugToImageSyncOverride = null;
}

/// Whether or not the HTML compatibility render object should be used.
///
/// This render object has worse performance and supports fewer features.
bool useHtmlRenderObject() {
  if (_cachedUseHtmlRenderObject != null) {
    return _cachedUseHtmlRenderObject!;
  }

  // Non-web platforms do not use the HTML render object, except when unit tests
  // inject an override to simulate web surface probe behavior.
  if (!kIsWeb && debugToImageSyncOverride == null) {
    return false;
  }

  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder);
  final ui.Picture picture = recorder.endRecording();
  ui.Image? image;
  try {
    image = debugToImageSyncOverride != null
        ? debugToImageSyncOverride!(picture, 1, 1)
        : picture.toImageSync(1, 1);
    _cachedUseHtmlRenderObject = false;
  } catch (_) {
    // Various renderers and browsers can throw exceptions, errors, or bare JS
    // objects (such as Strings or null) during surface creation or toImageSync
    // (see https://github.com/flutter/flutter/issues/186333 and
    // https://github.com/flutter/flutter/issues/189451). Fall back to the HTML
    // render object when any throwable is caught.
    _cachedUseHtmlRenderObject = true;
  } finally {
    image?.dispose();
    picture.dispose();
  }
  return _cachedUseHtmlRenderObject!;
}
