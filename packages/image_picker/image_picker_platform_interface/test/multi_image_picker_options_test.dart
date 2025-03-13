// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/src/types/types.dart';

void main() {
  group('MultiImagePickerOptions', () {
    test('createAndValidate does not throw error for correct limit', () {
      expect(
        () => MultiImagePickerOptions.createAndValidate(limit: 2),
        returnsNormally,
      );
    });

    test('createAndValidate throw error for to small limit', () {
      expect(
        () => MultiImagePickerOptions.createAndValidate(limit: 1),
        throwsArgumentError,
      );
      expect(
        () => MultiImagePickerOptions.createAndValidate(limit: 0),
        throwsArgumentError,
      );
      expect(
        () => MultiImagePickerOptions.createAndValidate(limit: -1),
        throwsArgumentError,
      );
    });
  });
}
