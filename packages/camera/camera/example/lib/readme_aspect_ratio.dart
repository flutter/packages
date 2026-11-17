// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera/camera.dart';

/// Creates a controller for 4:3 photos and a controller for 16:9 1080p video.
List<CameraController> createAspectRatioControllers(CameraDescription description) {
  // #docregion AspectRatio
  final photoController = CameraController(
    description,
    ResolutionPreset.max,
    aspectRatio: CameraAspectRatio.ratio4x3,
  );
  final videoController = CameraController(
    description,
    ResolutionPreset.veryHigh,
    aspectRatio: CameraAspectRatio.ratio16x9,
  );
  // #enddocregion AspectRatio
  return <CameraController>[photoController, videoController];
}
