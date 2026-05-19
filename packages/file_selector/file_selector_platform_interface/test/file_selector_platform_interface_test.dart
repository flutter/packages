// Copyright 2013 The Flutter Authors
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

  group('getDirectoryPath', () {
    test('Should throw unimplemented exception', () async {
      final FileSelectorPlatform fileSelector = ExtendsFileSelectorPlatform();

      await expectLater(() async {
        return fileSelector.getDirectoryPath();
      }, throwsA(isA<UnimplementedError>()));
    });
  });

  group('getDirectoryPathWithOptions', () {
    test('Should fall back to getDirectoryPath by default', () async {
      final FileSelectorPlatform fileSelector =
          OldFileSelectorPlatformImplementation();

      final String? result = await fileSelector.getDirectoryPathWithOptions(
        const FileDialogOptions(),
      );

      // Should call the old method and return its result
      expect(result, OldFileSelectorPlatformImplementation.directoryPath);
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

  group('getDirectoryPathsWithOptions', () {
    test('Should fall back to getDirectoryPaths by default', () async {
      final FileSelectorPlatform fileSelector =
          OldFileSelectorPlatformImplementation();

      final List<String> result = await fileSelector
          .getDirectoryPathsWithOptions(const FileDialogOptions());

      // Should call the old method and return its result
      expect(result, <String>[
        OldFileSelectorPlatformImplementation.directoryPath,
      ]);
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
  static const String directoryPath = '/a/directory';

  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    return savePath;
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return directoryPath;
  }

  @override
  Future<List<String>> getDirectoryPaths({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return <String>[directoryPath];
  }
}
