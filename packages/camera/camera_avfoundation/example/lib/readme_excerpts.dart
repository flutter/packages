// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

// #docregion ResponsiveCapture
import 'package:camera_avfoundation/camera_avfoundation.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

Future<void> enableResponsiveCapture(int cameraId) async {
  final CameraPlatform platform = CameraPlatform.instance;
  if (platform is AVFoundationCamera && await platform.isResponsiveCaptureSupported(cameraId)) {
    await platform.setResponsiveCaptureEnabled(cameraId, true);
  }
}
// #enddocregion ResponsiveCapture
