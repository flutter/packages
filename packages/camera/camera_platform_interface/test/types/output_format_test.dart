// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/src/types/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$OutputFormat tests', () {
    test('ImageFormat extension returns correct values', () {
      expect(OutputFormat.jpeg.name(), 'jpeg');
      expect(OutputFormat.heif.name(), 'heif');
    });
  });
}
