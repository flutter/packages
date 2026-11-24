// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:cross_file/cross_file.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_stubs.dart';

void main() {
  group('XEntity', () {
    test('dispose', () async {
      final entity = XEntity(
        TestXEntity(
          const PlatformXFileCreationParams(uri: 'uri'),
          onDispose: expectAsync0(() async {}),
        ),
      );

      await expectLater(entity.dispose(), completes);
    });

    group('calling methods after dispose', () {
      test('exists throws StateError', () async {
        final entity = XEntity(
          TestXEntity(
            const PlatformXFileCreationParams(uri: 'uri'),
            onDispose: expectAsync0(() async {}),
          ),
        );
        await entity.dispose();
        await expectLater(() => entity.exists(), throwsAssertionError);
      });

      test('getExtension throws StateError', () async {
        final entity = XEntity(
          TestXEntity(
            const PlatformXFileCreationParams(uri: 'uri'),
            onDispose: expectAsync0(() async {}),
          ),
        );
        await entity.dispose();
        await expectLater(() => entity.getExtension(), throwsAssertionError);
      });

      test('dispose only calls `platform.dispose` once', () async {
        final entity = XEntity(
          TestXEntity(
            const PlatformXFileCreationParams(uri: 'uri'),
            onDispose: expectAsync0(() async {}),
          ),
        );
        await entity.dispose();
        await expectLater(entity.dispose(), completes);
      });
    });
  });
}
