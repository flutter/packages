// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/src/types/types.dart';

void main() {
  group('RecentMediaOptions', () {
    test('has expected defaults', () {
      const options = RecentMediaOptions();

      expect(options.limit, 1);
      expect(options.types, <MediaSelectionType>{
        MediaSelectionType.image,
        MediaSelectionType.video,
      });
      expect(options.thumbnailWidth, 256);
      expect(options.thumbnailHeight, 256);
    });

    test('createAndValidate does not throw for default values', () {
      expect(() => RecentMediaOptions.createAndValidate(), returnsNormally);
    });

    test('createAndValidate does not throw for the maximum limit', () {
      expect(
        () => RecentMediaOptions.createAndValidate(limit: RecentMediaOptions.maxLimit),
        returnsNormally,
      );
    });

    test('createAndValidate throws for out of range limit', () {
      final Matcher throwsLimitArgumentError = throwsA(
        isA<ArgumentError>().having((ArgumentError error) => error.name, 'name', 'limit'),
      );

      expect(() => RecentMediaOptions.createAndValidate(limit: 0), throwsLimitArgumentError);
      expect(() => RecentMediaOptions.createAndValidate(limit: -1), throwsLimitArgumentError);
      expect(
        () => RecentMediaOptions.createAndValidate(limit: RecentMediaOptions.maxLimit + 1),
        throwsLimitArgumentError,
      );
    });

    test('createAndValidate throws for empty types', () {
      expect(
        () => RecentMediaOptions.createAndValidate(types: const <MediaSelectionType>{}),
        throwsA(isA<ArgumentError>().having((ArgumentError error) => error.name, 'name', 'types')),
      );
    });

    test('createAndValidate does not throw for a single type', () {
      expect(
        () => RecentMediaOptions.createAndValidate(
          types: const <MediaSelectionType>{MediaSelectionType.video},
        ),
        returnsNormally,
      );
    });

    test('createAndValidate throws for non-positive thumbnailWidth', () {
      final Matcher throwsWidthArgumentError = throwsA(
        isA<ArgumentError>().having((ArgumentError error) => error.name, 'name', 'thumbnailWidth'),
      );

      expect(
        () => RecentMediaOptions.createAndValidate(thumbnailWidth: 0),
        throwsWidthArgumentError,
      );
      expect(
        () => RecentMediaOptions.createAndValidate(thumbnailWidth: -1),
        throwsWidthArgumentError,
      );
    });

    test('createAndValidate throws for non-positive thumbnailHeight', () {
      final Matcher throwsHeightArgumentError = throwsA(
        isA<ArgumentError>().having((ArgumentError error) => error.name, 'name', 'thumbnailHeight'),
      );

      expect(
        () => RecentMediaOptions.createAndValidate(thumbnailHeight: 0),
        throwsHeightArgumentError,
      );
      expect(
        () => RecentMediaOptions.createAndValidate(thumbnailHeight: -1),
        throwsHeightArgumentError,
      );
    });
  });
}
