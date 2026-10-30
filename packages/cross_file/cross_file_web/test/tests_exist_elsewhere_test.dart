// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:cross_file_web/cross_file_web_safe.dart' as web_safe;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tell the user where to find the real tests', () {
    print('---');
    print('This package uses integration_test for its tests.');
    print('This file only includes tests for the cross platform safe file.');
    print('See `example/README.md` for more info.');
    print('---');
  });

  test(
    'Cross Platform safe WebScopedStorageXFileCreationParams.fromObjectUrl throws UnsupportedError',
    () {
      expect(
        () => web_safe.WebScopedStorageXFileCreationParams.fromObjectUrl(objectUrl: ''),
        throwsA(isA<UnsupportedError>()),
      );
    },
  );

  test(
    'Cross Platform safe WebScopedStorageXFileCreationParams.fromBytes throws UnsupportedError',
    () {
      expect(
        () =>
            web_safe.WebScopedStorageXFileCreationParams.fromBytes(Uint8List.fromList(<int>[0, 2])),
        throwsA(isA<UnsupportedError>()),
      );
    },
  );
}
