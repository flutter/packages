// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  late FakeFileSelector fakePlatformImplementation;
  const String initialDirectory = '/home/flutteruser';
  const String confirmButtonText = 'Use this profile picture';
  const String suggestedName = 'suggested_name';
  const List<XTypeGroup> acceptedTypeGroups = <XTypeGroup>[
    XTypeGroup(label: 'documents', mimeTypes: <String>[
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessing',
    ]),
    XTypeGroup(label: 'images', extensions: <String>[
      'jpg',
      'png',
    ]),
  ];

  setUp(() {
    fakePlatformImplementation = FakeFileSelector();
    FileSelectorPlatform.instance = fakePlatformImplementation;
  });

  group('openFile', () {
    final XFile expectedFile = XFile('path');

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(
            initialDirectory: initialDirectory,
            confirmButtonText: confirmButtonText,
            acceptedTypeGroups: acceptedTypeGroups)
        ..setFileResponse(<XFile>[expectedFile]);

      final XFile? file = await openFile(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
      );

      expect(file, expectedFile);
    });

    test('works with no arguments', () async {
      fakePlatformImplementation.setFileResponse(<XFile>[expectedFile]);

      final XFile? file = await openFile();

      expect(file, expectedFile);
    });

    test('sets the initial directory', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory)
        ..setFileResponse(<XFile>[expectedFile]);

      final XFile? file = await openFile(initialDirectory: initialDirectory);
      expect(file, expectedFile);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setFileResponse(<XFile>[expectedFile]);

      final XFile? file = await openFile(confirmButtonText: confirmButtonText);
      expect(file, expectedFile);
    });

    test('sets the accepted type groups', () async {
      fakePlatformImplementation
        ..setExpectations(acceptedTypeGroups: acceptedTypeGroups)
        ..setFileResponse(<XFile>[expectedFile]);

      final XFile? file =
          await openFile(acceptedTypeGroups: acceptedTypeGroups);
      expect(file, expectedFile);
    });
  });

  group('openFiles', () {
    final List<XFile> expectedFiles = <XFile>[XFile('path')];

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(
            initialDirectory: initialDirectory,
            confirmButtonText: confirmButtonText,
            acceptedTypeGroups: acceptedTypeGroups)
        ..setFileResponse(expectedFiles);

      final List<XFile> files = await openFiles(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
      );

      expect(files, expectedFiles);
    });

    test('works with no arguments', () async {
      fakePlatformImplementation.setFileResponse(expectedFiles);

      final List<XFile> files = await openFiles();

      expect(files, expectedFiles);
    });

    test('sets the initial directory', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory)
        ..setFileResponse(expectedFiles);

      final List<XFile> files =
          await openFiles(initialDirectory: initialDirectory);
      expect(files, expectedFiles);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setFileResponse(expectedFiles);

      final List<XFile> files =
          await openFiles(confirmButtonText: confirmButtonText);
      expect(files, expectedFiles);
    });

    test('sets the accepted type groups', () async {
      fakePlatformImplementation
        ..setExpectations(acceptedTypeGroups: acceptedTypeGroups)
        ..setFileResponse(expectedFiles);

      final List<XFile> files =
          await openFiles(acceptedTypeGroups: acceptedTypeGroups);
      expect(files, expectedFiles);
    });
  });

  group('getSaveLocation', () {
    const String expectedSavePath = '/example/path';

    test('works', () async {
      const int expectedActiveFilter = 1;
      fakePlatformImplementation
        ..setExpectations(
            initialDirectory: initialDirectory,
            confirmButtonText: confirmButtonText,
            acceptedTypeGroups: acceptedTypeGroups,
            suggestedName: suggestedName)
        ..setPathsResponse(<String>[expectedSavePath],
            activeFilter: expectedActiveFilter);

      final FileSaveLocation? location = await getSaveLocation(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
        suggestedName: suggestedName,
      );

      expect(location?.path, expectedSavePath);
      expect(location?.activeFilter, acceptedTypeGroups[expectedActiveFilter]);
    });

    test('works with no arguments', () async {
      fakePlatformImplementation.setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location = await getSaveLocation();
      expect(location?.path, expectedSavePath);
    });

    test('sets the initial directory', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location =
          await getSaveLocation(initialDirectory: initialDirectory);
      expect(location?.path, expectedSavePath);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location =
          await getSaveLocation(confirmButtonText: confirmButtonText);
      expect(location?.path, expectedSavePath);
    });

    test('sets the accepted type groups', () async {
      fakePlatformImplementation
        ..setExpectations(acceptedTypeGroups: acceptedTypeGroups)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location =
          await getSaveLocation(acceptedTypeGroups: acceptedTypeGroups);
      expect(location?.path, expectedSavePath);
    });

    test('sets the suggested name', () async {
      fakePlatformImplementation
        ..setExpectations(suggestedName: suggestedName)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location =
          await getSaveLocation(suggestedName: suggestedName);
      expect(location?.path, expectedSavePath);
    });
  });

  group('getSavePath (deprecated)', () {
    const String expectedSavePath = '/example/path';

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(
            initialDirectory: initialDirectory,
            confirmButtonText: confirmButtonText,
            acceptedTypeGroups: acceptedTypeGroups,
            suggestedName: suggestedName)
        ..setPathsResponse(<String>[expectedSavePath]);

      final String? savePath = await getSavePath(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
        suggestedName: suggestedName,
      );

      expect(savePath, expectedSavePath);
    });

    test('works with no arguments', () async {
      fakePlatformImplementation.setPathsResponse(<String>[expectedSavePath]);

      final String? savePath = await getSavePath();
      expect(savePath, expectedSavePath);
    });

    test('sets the initial directory', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory)
        ..setPathsResponse(<String>[expectedSavePath]);

      final String? savePath =
          await getSavePath(initialDirectory: initialDirectory);
      expect(savePath, expectedSavePath);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setPathsResponse(<String>[expectedSavePath]);

      final String? savePath =
          await getSavePath(confirmButtonText: confirmButtonText);
      expect(savePath, expectedSavePath);
    });

    test('sets the accepted type groups', () async {
      fakePlatformImplementation
        ..setExpectations(acceptedTypeGroups: acceptedTypeGroups)
        ..setPathsResponse(<String>[expectedSavePath]);

      final String? savePath =
          await getSavePath(acceptedTypeGroups: acceptedTypeGroups);
      expect(savePath, expectedSavePath);
    });

    test('sets the suggested name', () async {
      fakePlatformImplementation
        ..setExpectations(suggestedName: suggestedName)
        ..setPathsResponse(<String>[expectedSavePath]);

      final String? savePath = await getSavePath(suggestedName: suggestedName);
      expect(savePath, expectedSavePath);
    });
  });

  group('getDirectoryPath', () {
    const String expectedDirectoryPath = '/example/path';

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(
            initialDirectory: initialDirectory,
            confirmButtonText: confirmButtonText)
        ..setPathsResponse(<String>[expectedDirectoryPath]);

      final String? directoryPath = await getDirectoryPath(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
      );

      expect(directoryPath, expectedDirectoryPath);
    });

    test('works with no arguments', () async {
      fakePlatformImplementation
          .setPathsResponse(<String>[expectedDirectoryPath]);

      final String? directoryPath = await getDirectoryPath();
      expect(directoryPath, expectedDirectoryPath);
    });

    test('sets the initial directory', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory)
        ..setPathsResponse(<String>[expectedDirectoryPath]);

      final String? directoryPath =
          await getDirectoryPath(initialDirectory: initialDirectory);
      expect(directoryPath, expectedDirectoryPath);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setPathsResponse(<String>[expectedDirectoryPath]);

      final String? directoryPath =
          await getDirectoryPath(confirmButtonText: confirmButtonText);
      expect(directoryPath, expectedDirectoryPath);
    });
  });

  group('getDirectoryPaths', () {
    const List<String> expectedDirectoryPaths = <String>[
      '/example/path',
      '/example/2/path'
    ];

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(
            initialDirectory: initialDirectory,
            confirmButtonText: confirmButtonText)
        ..setPathsResponse(expectedDirectoryPaths);

      final List<String?> directoryPaths = await getDirectoryPaths(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
      );

      expect(directoryPaths, expectedDirectoryPaths);
    });

    test('works with no arguments', () async {
      fakePlatformImplementation.setPathsResponse(expectedDirectoryPaths);

      final List<String?> directoryPaths = await getDirectoryPaths();
      expect(directoryPaths, expectedDirectoryPaths);
    });

    test('sets the initial directory', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory)
        ..setPathsResponse(expectedDirectoryPaths);

      final List<String?> directoryPaths =
          await getDirectoryPaths(initialDirectory: initialDirectory);
      expect(directoryPaths, expectedDirectoryPaths);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setPathsResponse(expectedDirectoryPaths);

      final List<String?> directoryPaths =
          await getDirectoryPaths(confirmButtonText: confirmButtonText);
      expect(directoryPaths, expectedDirectoryPaths);
    });
  });
}

class FakeFileSelector extends Fake
    with MockPlatformInterfaceMixin
    implements FileSelectorPlatform {
  // Expectations.
  List<XTypeGroup>? acceptedTypeGroups = const <XTypeGroup>[];
  String? initialDirectory;
  String? confirmButtonText;
  String? suggestedName;
  // Return values.
  List<XFile>? files;
  List<String>? paths;
  int? activeFilter;

  void setExpectations({
    List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) {
    this.acceptedTypeGroups = acceptedTypeGroups;
    this.initialDirectory = initialDirectory;
    this.suggestedName = suggestedName;
    this.confirmButtonText = confirmButtonText;
  }

  // ignore: use_setters_to_change_properties
  void setFileResponse(List<XFile> files) {
    this.files = files;
  }

  void setPathsResponse(List<String> paths, {int? activeFilter}) {
    this.paths = paths;
    this.activeFilter = activeFilter;
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    expect(acceptedTypeGroups, this.acceptedTypeGroups);
    expect(initialDirectory, this.initialDirectory);
    expect(suggestedName, suggestedName);
    return files?[0];
  }

  @override
  Future<List<XFile>> openFiles({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    expect(acceptedTypeGroups, this.acceptedTypeGroups);
    expect(initialDirectory, this.initialDirectory);
    expect(suggestedName, suggestedName);
    return files!;
  }

  @override
  Future<String?> getSavePath({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  }) async {
    final FileSaveLocation? result = await getSaveLocation(
      acceptedTypeGroups: acceptedTypeGroups,
      options: SaveDialogOptions(
        initialDirectory: initialDirectory,
        suggestedName: suggestedName,
        confirmButtonText: confirmButtonText,
      ),
    );
    return result?.path;
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    expect(acceptedTypeGroups, this.acceptedTypeGroups);
    expect(options.initialDirectory, initialDirectory);
    expect(options.suggestedName, suggestedName);
    expect(options.confirmButtonText, confirmButtonText);
    final String? path = paths?[0];
    final int? activeFilterIndex = activeFilter;
    return path == null
        ? null
        : FileSaveLocation(path,
            activeFilter: activeFilterIndex == null
                ? null
                : acceptedTypeGroups?[activeFilterIndex]);
  }

  @override
  Future<String?> getDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    expect(initialDirectory, this.initialDirectory);
    expect(confirmButtonText, this.confirmButtonText);
    return paths?[0];
  }

  @override
  Future<List<String>> getDirectoryPaths({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    expect(initialDirectory, this.initialDirectory);
    expect(confirmButtonText, this.confirmButtonText);
    return paths!;
  }
}
