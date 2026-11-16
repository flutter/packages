// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';

/// Creates a controller that shows an HDR preview when [description] supports it.
Future<CameraController> createHdrPreviewController(CameraDescription description) async {
  // #docregion HdrPreview
  final Iterable<PreviewDynamicRange> ranges = await availablePreviewDynamicRanges(description);
  final controller = CameraController(
    description,
    ResolutionPreset.max,
    previewDynamicRange: ranges.contains(PreviewDynamicRange.hlg10)
        ? PreviewDynamicRange.hlg10
        : PreviewDynamicRange.sdr,
  );
  // #enddocregion HdrPreview
  return controller;
}
