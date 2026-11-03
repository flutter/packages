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
  } on UnsupportedError catch (_) {
    // The original HTML renderer does not implement toImageSync.
    _cachedUseHtmlRenderObject = true;
  } on StateError catch (_) {
    // CanvasKit on Mobile Safari (iOS 18.7) throws "Unable to convert
    // read pixels from SkImage" when readPixels fails at runtime.
    // See https://github.com/flutter/flutter/issues/186333.
    _cachedUseHtmlRenderObject = true;
  } on NoSuchMethodError catch (_) {
    // Same renderer/browser combination as the StateError case also
    // surfaces a "Null check operator used on a null value" thrown
    // from canvaskit.js wasm internals via Surface.createOrUpdateSurface.
    // See https://github.com/flutter/flutter/issues/186333.
    _cachedUseHtmlRenderObject = true;
  } finally {
    image?.dispose();
    picture.dispose();
  }
  return _cachedUseHtmlRenderObject!;
}
