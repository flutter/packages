// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/src/types/types.dart';

void main() {
  group('MultiImagePickerOptions', () {
    test('createAndValidate does not throw error for correct limit', () {
      expect(() => MultiImagePickerOptions.createAndValidate(limit: 2), returnsNormally);
    });

    test('createAndValidate throws error for too small limit', () {
      final Matcher throwsLimitArgumentError = throwsA(
        isA<RangeError>()
            .having((ArgumentError error) => error.toString(), 'message', contains('Not greater than or equal to 2')),
      );

      expect(() => MultiImagePickerOptions.createAndValidate(limit: 1), throwsLimitArgumentError);
      expect(() => MultiImagePickerOptions.createAndValidate(limit: 0), throwsLimitArgumentError);
      expect(() => MultiImagePickerOptions.createAndValidate(limit: -1), throwsLimitArgumentError);
    });
  });
}
