// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFileSelector fakePlatformImplementation;
  const initialDirectory = '/home/flutteruser';
  const confirmButtonText = 'Use this profile picture';
  const suggestedName = 'suggested_name';

  const acceptedTypeGroups = <XTypeGroup>[
    XTypeGroup(
      label: 'documents',
      mimeTypes: <String>[
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessing',
      ],
    ),
    XTypeGroup(label: 'images', extensions: <String>['jpg', 'png']),
  ];

  setUp(() {
    fakePlatformImplementation = FakeFileSelector();
    FileSelectorPlatform.instance = fakePlatformImplementation;
  });

  group('openFile', () {
    final expectedFile = XFile.fileSystem(path: 'path');

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(
          initialDirectory: initialDirectory,
          confirmButtonText: confirmButtonText,
          acceptedTypeGroups: acceptedTypeGroups,
        )
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

      final XFile? file = await openFile(acceptedTypeGroups: acceptedTypeGroups);
      expect(file, expectedFile);
    });
  });

  group('openFiles', () {
    final expectedFiles = <XFile>[XFile.fileSystem(path: 'path')];

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(
          initialDirectory: initialDirectory,
          confirmButtonText: confirmButtonText,
          acceptedTypeGroups: acceptedTypeGroups,
        )
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

      final List<XFile> files = await openFiles(initialDirectory: initialDirectory);
      expect(files, expectedFiles);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setFileResponse(expectedFiles);

      final List<XFile> files = await openFiles(confirmButtonText: confirmButtonText);
      expect(files, expectedFiles);
    });

    test('sets the accepted type groups', () async {
      fakePlatformImplementation
        ..setExpectations(acceptedTypeGroups: acceptedTypeGroups)
        ..setFileResponse(expectedFiles);

      final List<XFile> files = await openFiles(acceptedTypeGroups: acceptedTypeGroups);
      expect(files, expectedFiles);
    });
  });

  group('getSaveLocation', () {
    const expectedSavePath = '/example/path';

    test('works', () async {
      const expectedActiveFilter = 1;
      fakePlatformImplementation
        ..setExpectations(
          initialDirectory: initialDirectory,
          confirmButtonText: confirmButtonText,
          acceptedTypeGroups: acceptedTypeGroups,
          suggestedName: suggestedName,
        )
        ..setPathsResponse(<String>[expectedSavePath], activeFilter: expectedActiveFilter);

      final FileSaveLocation? location = await getSaveLocation(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
        acceptedTypeGroups: acceptedTypeGroups,
        suggestedName: suggestedName,
      );

      expect(location?.file.uri, expectedSavePath);
      expect(location?.activeFilter, acceptedTypeGroups[expectedActiveFilter]);
    });

    test('works with no arguments', () async {
      fakePlatformImplementation.setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location = await getSaveLocation();
      expect(location?.file.uri, expectedSavePath);
    });

    test('sets the initial directory', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location = await getSaveLocation(initialDirectory: initialDirectory);
      expect(location?.file.uri, expectedSavePath);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location = await getSaveLocation(
        confirmButtonText: confirmButtonText,
      );
      expect(location?.file.uri, expectedSavePath);
    });

    test('sets the accepted type groups', () async {
      fakePlatformImplementation
        ..setExpectations(acceptedTypeGroups: acceptedTypeGroups)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location = await getSaveLocation(
        acceptedTypeGroups: acceptedTypeGroups,
      );
      expect(location?.file.uri, expectedSavePath);
    });

    test('sets the suggested name', () async {
      fakePlatformImplementation
        ..setExpectations(suggestedName: suggestedName)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location = await getSaveLocation(suggestedName: suggestedName);
      expect(location?.file.uri, expectedSavePath);
    });

    test('sets the directory creation control flag', () async {
      const canCreateDirectories = false;
      fakePlatformImplementation
        ..setExpectations(canCreateDirectories: canCreateDirectories)
        ..setPathsResponse(<String>[expectedSavePath]);

      final FileSaveLocation? location = await getSaveLocation(
        canCreateDirectories: canCreateDirectories,
      );
      expect(location?.file.uri, expectedSavePath);
    });
  });

  group('getDirectoryPath', () {
    const expectedDirectoryPath = '/example/path';

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory, confirmButtonText: confirmButtonText)
        ..setPathsResponse(<String>[expectedDirectoryPath]);

      final XDirectory? directory = await getDirectoryPath(
        initialDirectory: initialDirectory,
        confirmButtonText: confirmButtonText,
      );

      expect(directory.uri, expectedDirectoryPath);
    });

    test('works with no arguments', () async {
      fakePlatformImplementation.setPathsResponse(<String>[expectedDirectoryPath]);

      final XDirectory? directoryPath = await getDirectoryPath();
      expect(directoryPath, expectedDirectoryPath);
    });

    test('sets the initial directory', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory)
        ..setPathsResponse(<String>[expectedDirectoryPath]);

      final String? directoryPath = await getDirectoryPath(initialDirectory: initialDirectory);
      expect(directoryPath, expectedDirectoryPath);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setPathsResponse(<String>[expectedDirectoryPath]);

      final String? directoryPath = await getDirectoryPath(confirmButtonText: confirmButtonText);
      expect(directoryPath, expectedDirectoryPath);
    });

    test('sets the directory creation control flag', () async {
      const canCreateDirectories = true;
      fakePlatformImplementation
        ..setExpectations(canCreateDirectories: canCreateDirectories)
        ..setPathsResponse(<String>[expectedDirectoryPath]);

      final String? directoryPath = await getDirectoryPath(
        canCreateDirectories: canCreateDirectories,
      );
      expect(directoryPath, expectedDirectoryPath);
    });
  });

  group('getDirectoryPaths', () {
    const expectedDirectoryPaths = <String>['/example/path', '/example/2/path'];

    test('works', () async {
      fakePlatformImplementation
        ..setExpectations(initialDirectory: initialDirectory, confirmButtonText: confirmButtonText)
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

      final List<String?> directoryPaths = await getDirectoryPaths(
        initialDirectory: initialDirectory,
      );
      expect(directoryPaths, expectedDirectoryPaths);
    });

    test('sets the button confirmation label', () async {
      fakePlatformImplementation
        ..setExpectations(confirmButtonText: confirmButtonText)
        ..setPathsResponse(expectedDirectoryPaths);

      final List<String?> directoryPaths = await getDirectoryPaths(
        confirmButtonText: confirmButtonText,
      );
      expect(directoryPaths, expectedDirectoryPaths);
    });
    test('sets the directory creation control flag', () async {
      const canCreateDirectories = true;
      fakePlatformImplementation
        ..setExpectations(canCreateDirectories: canCreateDirectories)
        ..setPathsResponse(expectedDirectoryPaths);

      final List<String?> directoryPaths = await getDirectoryPaths(
        canCreateDirectories: canCreateDirectories,
      );
      expect(directoryPaths, expectedDirectoryPaths);
    });
  });
}

final class FakeFileSelector extends FileSelectorPlatform {
  // Expectations.
  List<XTypeGroup>? acceptedTypeGroups = const <XTypeGroup>[];
  String? initialDirectory;
  String? confirmButtonText;
  String? suggestedName;
  bool? canCreateDirectories;
  // Return values.
  List<XFile>? files;
  List<XDirectory> directories = <XDirectory>[];
  int? activeFilter;

  void setExpectations({
    List<XTypeGroup> acceptedTypeGroups = const <XTypeGroup>[],
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
    bool? canCreateDirectories,
  }) {
    this.acceptedTypeGroups = acceptedTypeGroups;
    this.initialDirectory = initialDirectory;
    this.suggestedName = suggestedName;
    this.confirmButtonText = confirmButtonText;
    this.canCreateDirectories = canCreateDirectories;
  }

  // ignore: use_setters_to_change_properties
  void setFileResponse(List<XFile> files, {int? activeFilter}) {
    this.files = files;
    this.activeFilter = activeFilter;
  }

  @override
  Future<XFile?> openFile([OpenDialogOptions options = const OpenDialogOptions()]) async {
    expect(acceptedTypeGroups, options.acceptedTypeGroups);
    expect(initialDirectory, options.initialDirectory);
    return files?[0];
  }

  @override
  Future<List<XFile>> openFiles([OpenDialogOptions options = const OpenDialogOptions()]) async {
    expect(acceptedTypeGroups, options.acceptedTypeGroups);
    expect(initialDirectory, options.initialDirectory);
    expect(suggestedName, suggestedName);
    return files!;
  }

  @override
  Future<FileSaveLocation?> getSaveLocation([
    SaveLocationOptions options = const SaveLocationOptions(),
  ]) async {
    expect(options.acceptedTypeGroups, acceptedTypeGroups);
    expect(options.initialDirectory, initialDirectory);
    expect(options.suggestedName, suggestedName);
    expect(options.confirmButtonText, confirmButtonText);
    final XFile? file = files?[0];
    final int? activeFilterIndex = activeFilter;
    return file == null
        ? null
        : FileSaveLocation(
            file,
            activeFilter: activeFilterIndex == null ? null : acceptedTypeGroups?[activeFilterIndex],
          );
  }

  @override
  Future<XDirectory?> getDirectoryPath([
    FileDialogOptions options = const FileDialogOptions(),
  ]) async {
    expect(options.initialDirectory, initialDirectory);
    expect(options.confirmButtonText, confirmButtonText);
    expect(options.canCreateDirectories, canCreateDirectories);
    return directories[0];
  }

  @override
  Future<List<XDirectory>> getDirectoryPaths([
    FileDialogOptions options = const FileDialogOptions(),
  ]) async {
    expect(options.initialDirectory, initialDirectory);
    expect(options.confirmButtonText, confirmButtonText);
    expect(options.canCreateDirectories, canCreateDirectories);
    return directories;
  }
}
