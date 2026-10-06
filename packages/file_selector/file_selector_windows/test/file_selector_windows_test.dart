// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_windows/file_selector_windows.dart';
import 'package:file_selector_windows/src/messages.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CrossFilePlatform.instance = CrossFileTest();

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

      expect(file!.uri, 'foo');
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

      await plugin.openFile(
        const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]),
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
      await plugin.openFile(const OpenDialogOptions(initialDirectory: '/example/directory'));

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFile(const OpenDialogOptions(confirmButtonText: 'Open File'));

      expect(api.passedConfirmButtonText, 'Open File');
    });

    test('throws for a type group that does not support Windows', () async {
      const group = XTypeGroup(label: 'text', mimeTypes: <String>['text/plain']);

      await expectLater(
        plugin.openFile(const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group])),
        throwsArgumentError,
      );
    });

    test('allows a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.openFile(const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group])),
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

      expect(file[0].uri, 'foo');
      expect(file[1].uri, 'bar');
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

      await plugin.openFiles(
        const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]),
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
      await plugin.openFiles(const OpenDialogOptions(initialDirectory: '/example/directory'));

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.openFiles(const OpenDialogOptions(confirmButtonText: 'Open Files'));

      expect(api.passedConfirmButtonText, 'Open Files');
    });

    test('throws for a type group that does not support Windows', () async {
      const group = XTypeGroup(label: 'text', mimeTypes: <String>['text/plain']);

      await expectLater(
        plugin.openFiles(const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group])),
        throwsArgumentError,
      );
    });

    test('allows a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.openFiles(const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group])),
        completes,
      );
    });
  });

  group('getDirectory', () {
    setUp(() {
      api.result = <String>['foo'];
    });

    test('simple call works', () async {
      final XDirectory? dir = await plugin.getDirectory();

      expect(dir?.uri, 'foo/');
      expect(api.passedOptions!.allowMultiple, false);
      expect(api.passedOptions!.selectFolders, true);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectory(const FileDialogOptions(initialDirectory: '/example/directory'));

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectory(const FileDialogOptions(confirmButtonText: 'Open Directory'));

      expect(api.passedConfirmButtonText, 'Open Directory');
    });
  });

  group('getDirectories', () {
    setUp(() {
      api.result = <String>['foo', 'bar'];
    });

    test('simple call works', () async {
      final List<XDirectory> dirs = await plugin.getDirectories();

      expect(dirs[0].uri, 'foo/');
      expect(dirs[1].uri, 'bar/');
      expect(api.passedOptions!.allowMultiple, true);
      expect(api.passedOptions!.selectFolders, true);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getDirectories(const FileDialogOptions(initialDirectory: '/example/directory'));

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getDirectories(const FileDialogOptions(confirmButtonText: 'Open Directory'));

      expect(api.passedConfirmButtonText, 'Open Directory');
    });
  });

  group('getSaveLocation', () {
    setUp(() {
      api.result = <String>['foo'];
    });

    test('simple call works', () async {
      final FileSaveLocation? location = await plugin.getSaveLocation();

      expect(location?.file.uri, 'foo');
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
        const SaveLocationOptions(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]),
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
        const SaveLocationOptions(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]),
      );

      expect(result?.activeFilter, groupTwo);
    });

    test('passes initialDirectory correctly', () async {
      await plugin.getSaveLocation(
        const SaveLocationOptions(initialDirectory: '/example/directory'),
      );

      expect(api.passedInitialDirectory, '/example/directory');
    });

    test('passes suggestedName correctly', () async {
      await plugin.getSaveLocation(const SaveLocationOptions(suggestedName: 'baz.txt'));

      expect(api.passedSuggestedName, 'baz.txt');
    });

    test('passes confirmButtonText correctly', () async {
      await plugin.getSaveLocation(const SaveLocationOptions(confirmButtonText: 'Save File'));

      expect(api.passedConfirmButtonText, 'Save File');
    });

    test('throws for a type group that does not support Windows', () async {
      const group = XTypeGroup(label: 'text', mimeTypes: <String>['text/plain']);

      await expectLater(
        plugin.getSaveLocation(const SaveLocationOptions(acceptedTypeGroups: <XTypeGroup>[group])),
        throwsArgumentError,
      );
    });

    test('allows a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.getSaveLocation(const SaveLocationOptions(acceptedTypeGroups: <XTypeGroup>[group])),
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
    return FileDialogResult(paths: result, typeGroupIndex: resultTypeGroupIndex);
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
    return FileDialogResult(paths: result, typeGroupIndex: resultTypeGroupIndex);
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}

final class CrossFileTest extends CrossFilePlatform {}
