// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'fallback_strategy.dart';
import 'instance_manager.dart';
import 'java_object.dart';

@immutable
class QualitySelector extends JavaObject {
  /// Creates a [QualitySelector].
  QualitySelector.from(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      required Quality quality,
      FallbackStrategy? fallbackStragey})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    qualityList = <Quality>[quality];
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  QualitySelector.fromOrderedList(
      {BinaryMessenger? binaryMessenger,
      InstanceManager? instanceManager,
      this.qualityList,
      FallbackStrategy? fallbackStragey})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Creates a [QualitySelector] that is not automatically attached to a native object
  QualitySelector.detached(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  List<Quality> qualityList;

  Size getResolution(CameraInfo cameraInfo, Quality quality) {}
}
