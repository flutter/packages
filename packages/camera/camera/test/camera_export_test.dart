// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unnecessary_statements

import 'package:camera/camera.dart' as main_file;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('camera', () {
    test('ensure camera.dart exports classes from platform interface', () {
      main_file.CameraDescription;
      main_file.CameraException;
      main_file.CameraLensDirection;
      main_file.CameraLensType;
      main_file.ExposureMode;
      main_file.FlashMode;
      main_file.FocusMode;
      main_file.ImageFormatGroup;
      main_file.ResolutionPreset;
      main_file.XFile;
    });
  });
}
