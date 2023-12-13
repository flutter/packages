// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart' show BinaryMessenger;
import 'package:meta/meta.dart' show immutable;

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camerax_library.g.dart';
import 'instance_manager.dart';
import 'java_object.dart';
import 'metering_point_factory.dart';

/// somethin
@immutable
class DisplayOrientedMeteringPointFactory extends MeteringPointFactory {
  /// Creates a [MeteringPoint] that is not automatically attached to a
  /// native object.
  DisplayOrientedMeteringPointFactory.detached({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : super.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _api = _DisplayOrientedMeteringPointFactory(
        binaryMessenger: binaryMessenger, instanceManager: instanceManager);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  late final _DisplayOrientedMeteringPointFactory _api;

  /// somethin
  @override
  Future<int> getDefaultPointSize() {
    return Future.value(3);
  }
}
