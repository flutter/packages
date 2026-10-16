// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('openFile should throw unimplemented error', () async {
    final FileSelectorPlatform fileSelector = ExtendsFileSelectorPlatform();

    await expectLater(() async {
      return fileSelector.openFile();
    }, throwsA(isA<UnimplementedError>()));
  });

  test('openFiles should throw unimplemented error', () async {
    final FileSelectorPlatform fileSelector = ExtendsFileSelectorPlatform();

    await expectLater(() async {
      return fileSelector.openFiles();
    }, throwsA(isA<UnimplementedError>()));
  });

  test('getSaveLocation should throw unimplemented exception error', () async {
    final FileSelectorPlatform fileSelector = ExtendsFileSelectorPlatform();

    await expectLater(() async {
      return fileSelector.getSaveLocation();
    }, throwsA(isA<UnimplementedError>()));
  });

  test('getDirectories should throw unimplemented exception error', () async {
    final FileSelectorPlatform fileSelector = ExtendsFileSelectorPlatform();

    await expectLater(() async {
      return fileSelector.getDirectory();
    }, throwsA(isA<UnimplementedError>()));
  });

  test('getDirectories should throw unimplemented exception error', () async {
    final FileSelectorPlatform fileSelector = ExtendsFileSelectorPlatform();

    await expectLater(() async {
      return fileSelector.getDirectories();
    }, throwsA(isA<UnimplementedError>()));
  });
}

final class ExtendsFileSelectorPlatform extends FileSelectorPlatform {}
