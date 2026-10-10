// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:build/build.dart';
import 'package:go_router_builder/src/duplicate_path_severity.dart';
import 'package:test/test.dart';

void main() {
  group('duplicatePathSeverityFromOptions', () {
    test('It should warn when the option is absent', () {
      expect(duplicatePathSeverityFromOptions(BuilderOptions.empty), DuplicatePathSeverity.warning);
    });

    test('It should read each accepted value', () {
      for (final DuplicatePathSeverity severity in DuplicatePathSeverity.values) {
        expect(
          duplicatePathSeverityFromOptions(
            BuilderOptions(<String, dynamic>{duplicateRoutePathsOption: severity.name}),
          ),
          severity,
        );
      }
    });

    test('It should reject an unrecognized value, naming the accepted ones', () {
      expect(
        () => duplicatePathSeverityFromOptions(
          const BuilderOptions(<String, dynamic>{duplicateRoutePathsOption: 'bogus'}),
        ),
        throwsA(
          isA<ArgumentError>()
              .having((ArgumentError e) => e.name, 'name', duplicateRoutePathsOption)
              .having((ArgumentError e) => e.invalidValue, 'invalidValue', 'bogus')
              .having(
                (ArgumentError e) => e.message,
                'message',
                allOf(contains('ignore'), contains('warning'), contains('error')),
              ),
        ),
      );
    });

    test('It should reject a value of the wrong type', () {
      expect(
        () => duplicatePathSeverityFromOptions(
          const BuilderOptions(<String, dynamic>{duplicateRoutePathsOption: true}),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
