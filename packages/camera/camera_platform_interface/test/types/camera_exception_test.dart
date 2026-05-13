// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('constructor should initialize properties', () {
    const code = 'TEST_ERROR';
    const description = 'This is a test error';
    final exception = CameraException(code, description);

    expect(exception.code, code);
    expect(exception.description, description);
  });

  test('toString: Should return a description of the exception', () {
    const code = 'TEST_ERROR';
    const description = 'This is a test error';
    const expected = 'CameraException($code, $description)';
    final exception = CameraException(code, description);

    final actual = exception.toString();

    expect(actual, expected);
  });
}
