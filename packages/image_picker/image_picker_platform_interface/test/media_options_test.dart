// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/src/types/types.dart';

void main() {
  group('MediaOptions', () {
    test('createAndValidate does not throw when allowMultiple is true', () {
      expect(
        () => MediaOptions.createAndValidate(allowMultiple: true),
        returnsNormally,
      );
    });
    test('createAndValidate does not throw when allowMultiple is false', () {
      expect(
        () => MediaOptions.createAndValidate(allowMultiple: false),
        returnsNormally,
      );
    });

    test('createAndValidate does not throw error for correct limit', () {
      expect(
        () => MediaOptions.createAndValidate(allowMultiple: true, limit: 2),
        returnsNormally,
      );
    });

    test('createAndValidate throws error for too small limit', () {
      final Matcher throwsLimitArgumentError = throwsA(
        isA<ArgumentError>()
            .having((ArgumentError error) => error.name, 'name', 'limit')
            .having(
              (ArgumentError error) => error.message,
              'message',
              'cannot be lower than 2',
            ),
      );

      expect(
        () => MediaOptions.createAndValidate(allowMultiple: true, limit: 1),
        throwsLimitArgumentError,
      );
      expect(
        () => MediaOptions.createAndValidate(allowMultiple: true, limit: 0),
        throwsLimitArgumentError,
      );
      expect(
        () => MediaOptions.createAndValidate(allowMultiple: true, limit: -1),
        throwsLimitArgumentError,
      );
    });

    test(
      'createAndValidate throw error when allowMultiple is false and has limit',
      () {
        expect(
          () => MediaOptions.createAndValidate(allowMultiple: false, limit: 2),
          throwsArgumentError,
        );
      },
    );
  });
}
