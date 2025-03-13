// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

bool? _cachedUseHtmlRenderObject;

/// Whether or not the HTML compatibility render object should be used.
///
/// This render object has worse performance and supports fewer features.
bool useHtmlRenderObject() {
  if (!kIsWeb) {
    return false;
  }

  if (_cachedUseHtmlRenderObject != null) {
    return _cachedUseHtmlRenderObject!;
  }

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  ui.Canvas(recorder);
  final ui.Picture picture = recorder.endRecording();
  ui.Image? image;
  try {
    image = picture.toImageSync(1, 1);
    _cachedUseHtmlRenderObject = false;
  } on UnsupportedError catch (_) {
    _cachedUseHtmlRenderObject = true;
  } finally {
    image?.dispose();
    picture.dispose();
  }
  return _cachedUseHtmlRenderObject!;
}
