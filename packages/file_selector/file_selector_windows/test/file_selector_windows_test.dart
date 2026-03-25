// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:file_selector_windows/src/messages.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFileSelectorApi api;
  late FileSelectorWindows plugin;

  setUp(() {
    api = FakeFileSelectorApi();
    plugin = FileSelectorWindows(api: api);
  });

  test('registered instance', () {
    FileSelectorWindows.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorWindows>());
  });

  group('openFile', () {
    setUp(() {
      api.result = <String>['foo'];
    });

    test('simple call works', () async {
      final XFile? file = await plugin.openFile();

      expect(file!.path, 'foo');
      expect(api.passedOptions!.allowMultiple, false);
      expect(api.passedOptions!.selectFolders, false);
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
      );

      await plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      expect(
        _typeGroupListsMatch(api.passedOptions!.allowedTypes, <TypeGroup>[
          TypeGroup(label: 'text', extensions: <String>['txt']),
          TypeGroup(label: 'image', extensions: <String>['jpg']),
        ]),
        true,
      );
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFile(initialDirectory: '/example/directory');

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFile(confirmButtonText: 'Open File');

      expect(api.passedConfirmButtonText, 'Open File');
    });

    test('throws for a type group that does not support Windows', () async {
      const group = XTypeGroup(
        label: 'text',
        mimeTypes: <String>['text/plain'],
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
    setUp(() {
      api.result = <String>['foo', 'bar'];
    });

    test('simple call works', () async {
      final List<XFile> file = await plugin.openFiles();

      expect(file[0].path, 'foo');
      expect(file[1].path, 'bar');
      expect(api.passedOptions!.allowMultiple, true);
      expect(api.passedOptions!.selectFolders, false);
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
      );

      await plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      expect(
        _typeGroupListsMatch(api.passedOptions!.allowedTypes, <TypeGroup>[
          TypeGroup(label: 'text', extensions: <String>['txt']),
          TypeGroup(label: 'image', extensions: <String>['jpg']),
        ]),
        true,
      );
    });

    test('passes initialDirectory correctly', () async {
      await plugin.openFiles(initialDirectory: '/example/directory');

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFiles(confirmButtonText: 'Open Files');

      expect(api.passedConfirmButtonText, 'Open Files');
    });

    test('throws for a type group that does not support Windows', () async {
      const group = XTypeGroup(
        label: 'text',
        mimeTypes: <String>['text/plain'],
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

  group('getDirectoryPath', () {
    setUp(() {
      api.result = <String>['foo'];
    });

    test('simple call works', () async {
      final String? path = await plugin.getDirectoryPath();

      expect(path, 'foo');
      expect(api.passedOptions!.allowMultiple, false);
      expect(api.passedOptions!.selectFolders, true);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPath(initialDirectory: '/example/directory');

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPath(confirmButtonText: 'Open Directory');

      expect(api.passedConfirmButtonText, 'Open Directory');
    });
  });

  group('getDirectoryPaths', () {
    setUp(() {
      api.result = <String>['foo', 'bar'];
    });

    test('simple call works', () async {
      final List<String> paths = await plugin.getDirectoryPaths();

      expect(paths[0], 'foo');
      expect(paths[1], 'bar');
      expect(api.passedOptions!.allowMultiple, true);
      expect(api.passedOptions!.selectFolders, true);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectoryPaths(initialDirectory: '/example/directory');

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectoryPaths(confirmButtonText: 'Open Directory');

      expect(api.passedConfirmButtonText, 'Open Directory');
    });
  });

  group('getSaveLocation', () {
    setUp(() {
      api.result = <String>['foo'];
    });

    test('simple call works', () async {
      final FileSaveLocation? location = await plugin.getSaveLocation();

      expect(location?.path, 'foo');
      expect(location?.activeFilter, null);
      expect(api.passedOptions!.allowMultiple, false);
      expect(api.passedOptions!.selectFolders, false);
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
      );

      await plugin.getSaveLocation(
        acceptedTypeGroups: <XTypeGroup>[group, groupTwo],
      );

      expect(
        _typeGroupListsMatch(api.passedOptions!.allowedTypes, <TypeGroup>[
          TypeGroup(label: 'text', extensions: <String>['txt']),
          TypeGroup(label: 'image', extensions: <String>['jpg']),
        ]),
        true,
      );
    });

    test('returns the selected type group correctly', () async {
      api.result = <String>['foo'];
      api.resultTypeGroupIndex = 1;
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
      );

      final FileSaveLocation? result = await plugin.getSaveLocation(
        acceptedTypeGroups: <XTypeGroup>[group, groupTwo],
      );

      expect(result?.activeFilter, groupTwo);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getSaveLocation(
        options: const SaveDialogOptions(
          initialDirectory: '/example/directory',
        ),
      );

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes suggestedName correctly', () async {
      await plugin.getSaveLocation(
        options: const SaveDialogOptions(suggestedName: 'baz.txt'),
      );

      expect(api.passedSuggestedName, 'baz.txt');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSaveLocation(
        options: const SaveDialogOptions(confirmButtonText: 'Save File'),
      );

      expect(api.passedConfirmButtonText, 'Save File');
    });

    test('throws for a type group that does not support Windows', () async {
      const group = XTypeGroup(
        label: 'text',
        mimeTypes: <String>['text/plain'],
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
  });

  group('getSavePath (deprecated)', () {
    setUp(() {
      api.result = <String>['foo'];
    });

    test('simple call works', () async {
      final String? path = await plugin.getSavePath();

      expect(path, 'foo');
      expect(api.passedOptions!.allowMultiple, false);
      expect(api.passedOptions!.selectFolders, false);
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
      );

      await plugin.getSavePath(
        acceptedTypeGroups: <XTypeGroup>[group, groupTwo],
      );

      expect(
        _typeGroupListsMatch(api.passedOptions!.allowedTypes, <TypeGroup>[
          TypeGroup(label: 'text', extensions: <String>['txt']),
          TypeGroup(label: 'image', extensions: <String>['jpg']),
        ]),
        true,
      );
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getSavePath(initialDirectory: '/example/directory');

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes suggestedName correctly', () async {
      await plugin.getSavePath(suggestedName: 'baz.txt');

      expect(api.passedSuggestedName, 'baz.txt');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSavePath(confirmButtonText: 'Save File');

      expect(api.passedConfirmButtonText, 'Save File');
    });

    test('throws for a type group that does not support Windows', () async {
      const group = XTypeGroup(
        label: 'text',
        mimeTypes: <String>['text/plain'],
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
  });
}

// True if the given options match.
//
// This is needed because Pigeon data classes don't have custom equality checks,
// so only match for identical instances.
bool _typeGroupListsMatch(List<TypeGroup?> a, List<TypeGroup?> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (!_typeGroupsMatch(a[i], b[i])) {
      return false;
    }
  }
  return true;
}

// True if the given type groups match.
//
// This is needed because Pigeon data classes don't have custom equality checks,
// so only match for identical instances.
bool _typeGroupsMatch(TypeGroup? a, TypeGroup? b) {
  return a!.label == b!.label && listEquals(a.extensions, b.extensions);
}

/// Fake implementation that stores arguments and provides a canned response.
class FakeFileSelectorApi implements FileSelectorApi {
  List<String> result = <String>[];
  int? resultTypeGroupIndex;
  String? passedInitialDirectory;
  String? passedConfirmButtonText;
  String? passedSuggestedName;
  SelectionOptions? passedOptions;

  @override
  Future<FileDialogResult> showOpenDialog(
    SelectionOptions options,
    String? initialDirectory,
    String? confirmButtonText,
  ) async {
    passedInitialDirectory = initialDirectory;
    passedConfirmButtonText = confirmButtonText;
    passedOptions = options;
    return FileDialogResult(
      paths: result,
      typeGroupIndex: resultTypeGroupIndex,
    );
  }

  @override
  Future<FileDialogResult> showSaveDialog(
    SelectionOptions options,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  ) async {
    passedInitialDirectory = initialDirectory;
    passedConfirmButtonText = confirmButtonText;
    passedSuggestedName = suggestedName;
    passedOptions = options;
    return FileDialogResult(
      paths: result,
      typeGroupIndex: resultTypeGroupIndex,
    );
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
