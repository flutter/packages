// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_platform_interface/src/method_channel/method_channel_file_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Store the initial instance before any tests change it.
  final FileSelectorPlatform initialInstance = FileSelectorPlatform.instance;

  group('FileSelectorPlatform', () {
    test('$MethodChannelFileSelector() is the default instance', () {
      expect(initialInstance, isInstanceOf<MethodChannelFileSelector>());
    });

    test('Can be extended', () {
      FileSelectorPlatform.instance = ExtendsFileSelectorPlatform();
    });
  });

  group('getDirectoryPaths', () {
    test('Should throw unimplemented exception', () async {
      final FileSelectorPlatform fileSelector = ExtendsFileSelectorPlatform();

      await expectLater(() async {
        return fileSelector.getDirectoryPaths();
      }, throwsA(isA<UnimplementedError>()));
    });
  });

  test('getSaveLocation falls back to getSavePath by default', () async {
    final FileSelectorPlatform fileSelector =
        OldFileSelectorPlatformImplementation();

    final FileSaveLocation? result = await fileSelector.getSaveLocation();

    expect(result?.path, OldFileSelectorPlatformImplementation.savePath);
    expect(result?.activeFilter, null);
  });
}

class ExtendsFileSelectorPlatform extends FileSelectorPlatform {}

class OldFileSelectorPlatformImplementation extends FileSelectorPlatform {
  static const String savePath = '/a/path';
  // Only implement the deprecated getSavePath.
  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    return savePath;
  }
}
