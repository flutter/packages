// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_macos/file_selector_macos.dart';
import 'package:file_selector_macos/src/messages.g.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFileSelectorApi api;
  late FileSelectorMacOS plugin;

  setUp(() {
    api = FakeFileSelectorApi();
    plugin = FileSelectorMacOS(api: api);
  });

  test('registered instance', () {
    FileSelectorMacOS.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorMacOS>());
  });

  group('openFile', () {
    test('works as expected with no arguments', () async {
      api.result = <String>['foo'];

      final XFile? file = await plugin.openFile();

      expect(file!.path, 'foo');
      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.allowsMultipleSelection, false);
      expect(options.canChooseFiles, true);
      expect(options.canChooseDirectories, false);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      api.result = <String>[];

      final XFile? file = await plugin.openFile();

      expect(file, null);
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        uniformTypeIdentifiers: <String>['public.text'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
        uniformTypeIdentifiers: <String>['public.image'],
        webWildCards: <String>['image/*'],
      );

      await plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.allowedFileTypes!.extensions, <String>[
        'txt',
        'jpg',
      ]);
      expect(options.baseOptions.allowedFileTypes!.mimeTypes, <String>[
        'text/plain',
        'image/jpg',
      ]);
      expect(options.baseOptions.allowedFileTypes!.utis, <String>[
        'public.text',
        'public.image',
      ]);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFile(initialDirectory: '/example/directory');

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFile(confirmButtonText: 'Open File');

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.prompt, 'Open File');
    });

    test('throws for a type group that does not support macOS', () async {
      const group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
        plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]),
        throwsArgumentError,
      );
    });

    test('allows a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]),
        completes,
      );
    });
  });

  group('openFiles', () {
    test('works as expected with no arguments', () async {
      api.result = <String>['foo', 'bar'];

      final List<XFile> files = await plugin.openFiles();

      expect(files[0].path, 'foo');
      expect(files[1].path, 'bar');
      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.allowsMultipleSelection, true);
      expect(options.canChooseFiles, true);
      expect(options.canChooseDirectories, false);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      api.result = <String>[];

      final List<XFile> files = await plugin.openFiles();

      expect(files, isEmpty);
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        uniformTypeIdentifiers: <String>['public.text'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
        uniformTypeIdentifiers: <String>['public.image'],
        webWildCards: <String>['image/*'],
      );

      await plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.allowedFileTypes!.extensions, <String>[
        'txt',
        'jpg',
      ]);
      expect(options.baseOptions.allowedFileTypes!.mimeTypes, <String>[
        'text/plain',
        'image/jpg',
      ]);
      expect(options.baseOptions.allowedFileTypes!.utis, <String>[
        'public.text',
        'public.image',
      ]);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFiles(initialDirectory: '/example/directory');

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFiles(confirmButtonText: 'Open File');

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.prompt, 'Open File');
    });

    test('throws for a type group that does not support macOS', () async {
      const group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
        plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]),
        throwsArgumentError,
      );
    });

    test('allows a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]),
        completes,
      );
    });
  });

  group('getSavePath (deprecated)', () {
    test('works as expected with no arguments', () async {
      api.result = <String>['foo'];

      final String? path = await plugin.getSavePath();

      expect(path, 'foo');
      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.allowedFileTypes, null);
      expect(options.directoryPath, null);
      expect(options.nameFieldStringValue, null);
      expect(options.prompt, null);
    });

    test('handles cancel', () async {
      api.result = <String>[];

      final String? path = await plugin.getSavePath();

      expect(path, null);
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        uniformTypeIdentifiers: <String>['public.text'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
        uniformTypeIdentifiers: <String>['public.image'],
        webWildCards: <String>['image/*'],
      );

      await plugin.getSavePath(
        acceptedTypeGroups: <XTypeGroup>[group, groupTwo],
      );

      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.allowedFileTypes!.extensions, <String>['txt', 'jpg']);
      expect(options.allowedFileTypes!.mimeTypes, <String>[
        'text/plain',
        'image/jpg',
      ]);
      expect(options.allowedFileTypes!.utis, <String>[
        'public.text',
        'public.image',
      ]);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getSavePath(initialDirectory: '/example/directory');

      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSavePath(confirmButtonText: 'Open File');

      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.prompt, 'Open File');
    });

    test('throws for a type group that does not support macOS', () async {
      const group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
        plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[group]),
        throwsArgumentError,
      );
    });

    test('allows a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.getSavePath(acceptedTypeGroups: <XTypeGroup>[group]),
        completes,
      );
    });

    test('ignores all type groups if any of them is a wildcard', () async {
      await plugin.getSavePath(
        acceptedTypeGroups: <XTypeGroup>[
          const XTypeGroup(
            label: 'text',
            extensions: <String>['txt'],
            mimeTypes: <String>['text/plain'],
            uniformTypeIdentifiers: <String>['public.text'],
          ),
          const XTypeGroup(
            label: 'image',
            extensions: <String>['jpg'],
            mimeTypes: <String>['image/jpg'],
            uniformTypeIdentifiers: <String>['public.image'],
          ),
          const XTypeGroup(label: 'any'),
        ],
      );

      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.allowedFileTypes, null);
    });
  });

  group('getSaveLocation', () {
    test('works as expected with no arguments', () async {
      api.result = <String>['foo'];

      final FileSaveLocation? location = await plugin.getSaveLocation();

      expect(location?.path, 'foo');
      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.allowedFileTypes, null);
      expect(options.directoryPath, null);
      expect(options.nameFieldStringValue, null);
      expect(options.prompt, null);
    });

    test('handles cancel', () async {
      api.result = <String>[];

      final FileSaveLocation? location = await plugin.getSaveLocation();

      expect(location, null);
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        uniformTypeIdentifiers: <String>['public.text'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
        uniformTypeIdentifiers: <String>['public.image'],
        webWildCards: <String>['image/*'],
      );

      await plugin.getSaveLocation(
        acceptedTypeGroups: <XTypeGroup>[group, groupTwo],
      );

      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.allowedFileTypes!.extensions, <String>['txt', 'jpg']);
      expect(options.allowedFileTypes!.mimeTypes, <String>[
        'text/plain',
        'image/jpg',
      ]);
      expect(options.allowedFileTypes!.utis, <String>[
        'public.text',
        'public.image',
      ]);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getSaveLocation(
        options: const SaveDialogOptions(
          initialDirectory: '/example/directory',
        ),
      );

      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSaveLocation(
        options: const SaveDialogOptions(confirmButtonText: 'Open File'),
      );

      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.prompt, 'Open File');
    });

    test('throws for a type group that does not support macOS', () async {
      const group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
        plugin.getSaveLocation(acceptedTypeGroups: <XTypeGroup>[group]),
        throwsArgumentError,
      );
    });

    test('allows a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.getSaveLocation(acceptedTypeGroups: <XTypeGroup>[group]),
        completes,
      );
    });

    test('ignores all type groups if any of them is a wildcard', () async {
      await plugin.getSaveLocation(
        acceptedTypeGroups: <XTypeGroup>[
          const XTypeGroup(
            label: 'text',
            extensions: <String>['txt'],
            mimeTypes: <String>['text/plain'],
            uniformTypeIdentifiers: <String>['public.text'],
          ),
          const XTypeGroup(
            label: 'image',
            extensions: <String>['jpg'],
            mimeTypes: <String>['image/jpg'],
            uniformTypeIdentifiers: <String>['public.image'],
          ),
          const XTypeGroup(label: 'any'),
        ],
      );

      final SavePanelOptions options = api.passedSavePanelOptions!;
      expect(options.allowedFileTypes, null);
    });
  });

  group('getDirectoryPath', () {
    test('works as expected with no arguments', () async {
      api.result = <String>['foo'];

      final String? path = await plugin.getDirectoryPath();

      expect(path, 'foo');
      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.allowsMultipleSelection, false);
      expect(options.canChooseFiles, false);
      expect(options.canChooseDirectories, true);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      api.result = <String>[];

      final String? path = await plugin.getDirectoryPath();

      expect(path, null);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPath(initialDirectory: '/example/directory');

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPath(confirmButtonText: 'Open File');

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.prompt, 'Open File');
    });
  });

  group('getDirectoryPathWithOptions', () {
    test('works as expected with no arguments', () async {
      api.result = <String>['foo'];

      final String? path = await plugin.getDirectoryPathWithOptions(
        const FileDialogOptions(),
      );

      expect(path, 'foo');
      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.allowsMultipleSelection, false);
      expect(options.canChooseFiles, false);
      expect(options.canChooseDirectories, true);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.canCreateDirectories, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      api.result = <String>[];

      final String? path = await plugin.getDirectoryPath();

      expect(path, null);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPathWithOptions(
        const FileDialogOptions(initialDirectory: '/example/directory'),
      );

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPathWithOptions(
        const FileDialogOptions(confirmButtonText: 'Open File'),
      );

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.prompt, 'Open File');
    });

    test('passes canCreateDirectories correctly', () async {
      await plugin.getDirectoryPathWithOptions(
        const FileDialogOptions(canCreateDirectories: false),
      );

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.canCreateDirectories, false);
    });
  });

  group('getDirectoryPaths', () {
    test('works as expected with no arguments', () async {
      api.result = <String>[
        'firstDirectory',
        'secondDirectory',
        'thirdDirectory',
      ];

      final List<String> path = await plugin.getDirectoryPaths();

      expect(path, <String>[
        'firstDirectory',
        'secondDirectory',
        'thirdDirectory',
      ]);
      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.allowsMultipleSelection, true);
      expect(options.canChooseFiles, false);
      expect(options.canChooseDirectories, true);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      api.result = <String>[];

      final List<String> paths = await plugin.getDirectoryPaths();

      expect(paths, <String>[]);
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPaths(confirmButtonText: 'Select directories');

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.prompt, 'Select directories');
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPaths(initialDirectory: '/example/directory');

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });
  });

  group('getDirectoryPathsWithOptions', () {
    test('works as expected with no arguments', () async {
      api.result = <String>[
        'firstDirectory',
        'secondDirectory',
        'thirdDirectory',
      ];

      final List<String> path = await plugin.getDirectoryPathsWithOptions(
        const FileDialogOptions(),
      );

      expect(path, <String>[
        'firstDirectory',
        'secondDirectory',
        'thirdDirectory',
      ]);
      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.allowsMultipleSelection, true);
      expect(options.canChooseFiles, false);
      expect(options.canChooseDirectories, true);
      expect(options.baseOptions.allowedFileTypes, null);
      expect(options.baseOptions.directoryPath, null);
      expect(options.baseOptions.nameFieldStringValue, null);
      expect(options.baseOptions.canCreateDirectories, null);
      expect(options.baseOptions.prompt, null);
    });

    test('handles cancel', () async {
      api.result = <String>[];

      final List<String> paths = await plugin.getDirectoryPathsWithOptions(
        const FileDialogOptions(),
      );

      expect(paths, <String>[]);
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPathsWithOptions(
        const FileDialogOptions(confirmButtonText: 'Select directories'),
      );

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.prompt, 'Select directories');
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPathsWithOptions(
        const FileDialogOptions(initialDirectory: '/example/directory'),
      );

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.directoryPath, '/example/directory');
    });

    test('passes canCreateDirectories correctly', () async {
      await plugin.getDirectoryPathsWithOptions(
        const FileDialogOptions(canCreateDirectories: false),
      );

      final OpenPanelOptions options = api.passedOpenPanelOptions!;
      expect(options.baseOptions.canCreateDirectories, false);
    });
  });
}

/// Fake implementation that stores arguments and provides a canned response.
class FakeFileSelectorApi implements FileSelectorApi {
  OpenPanelOptions? passedOpenPanelOptions;
  SavePanelOptions? passedSavePanelOptions;
  List<String> result = <String>[];

  @override
  Future<List<String>> displayOpenPanel(OpenPanelOptions options) async {
    passedOpenPanelOptions = options;
    return result;
  }

  @override
  Future<String?> displaySavePanel(SavePanelOptions options) async {
    passedSavePanelOptions = options;
    return result.firstOrNull;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
