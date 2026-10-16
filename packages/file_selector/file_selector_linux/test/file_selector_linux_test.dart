// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:file_selector_linux/file_selector_linux.dart';
import 'package:file_selector_linux/src/messages.g.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CrossFilePlatform.instance = CrossFileTest();

  late FakeFileSelectorApi api;
  late FileSelectorLinux plugin;

  setUp(() {
    api = FakeFileSelectorApi();
    plugin = FileSelectorLinux(api: api);
  });

  test('registers instance', () {
    FileSelectorLinux.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorLinux>());
  });

  group('openFile', () {
    test('passes the core flags correctly', () async {
      const path = '/foo/bar';
      api.result = <String>[path];

      final file = (await plugin.openFile())! as FileSystemXFile;
      expect(file.path, path);

      expect(api.passedType, PlatformFileChooserActionType.open);
      expect(api.passedOptions?.selectMultiple, false);
    });

    test('handles empty return for cancel', () async {
      api.result = <String>[];

      expect(await plugin.openFile(), null);
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

      expect(api.passedOptions?.allowedFileTypes?[0].label, group.label);
      // Extensions should be converted to *.<extension> format.
      expect(api.passedOptions?.allowedFileTypes?[0].extensions, <String>['*.txt']);
      expect(api.passedOptions?.allowedFileTypes?[0].mimeTypes, group.mimeTypes);
      expect(api.passedOptions?.allowedFileTypes?[1].label, groupTwo.label);
      expect(api.passedOptions?.allowedFileTypes?[1].extensions, <String>['*.jpg']);
      expect(api.passedOptions?.allowedFileTypes?[1].mimeTypes, groupTwo.mimeTypes);
    });

    test('passes initialDirectory correctly', () async {
      const path = '/example/directory';
      await plugin.openFile(const OpenDialogOptions(initialDirectory: path));

      expect(api.passedOptions?.currentFolderPath, path);
    });

    test('passes confirmButtonText correctly', () async {
      const button = 'Open File';
      await plugin.openFile(const OpenDialogOptions(confirmButtonText: button));

      expect(api.passedOptions?.acceptButtonLabel, button);
    });

    test('throws for a type group that does not support Linux', () async {
      const group = XTypeGroup(label: 'images', webWildCards: <String>['images/*']);

      await expectLater(
        plugin.openFile(const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group])),
        throwsArgumentError,
      );
    });

    test('passes a wildcard group correctly', () async {
      const group = XTypeGroup(label: 'any');

      await plugin.openFile(const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group]));

      expect(api.passedOptions?.allowedFileTypes?[0].extensions, <String>['*']);
    });
  });

  group('openFiles', () {
    test('passes the core flags correctly', () async {
      api.result = <String>['/foo/bar', 'baz'];

      final List<XFile> files = await plugin.openFiles();

      expect(files.length, 2);
      expect((files[0] as FileSystemXFile).path, api.result[0]);
      expect((files[1] as FileSystemXFile).path, api.result[1]);

      expect(api.passedType, PlatformFileChooserActionType.open);
      expect(api.passedOptions?.selectMultiple, true);
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

      expect(api.passedOptions?.allowedFileTypes?[0].label, group.label);
      // Extensions should be converted to *.<extension> format.
      expect(api.passedOptions?.allowedFileTypes?[0].extensions, <String>['*.txt']);
      expect(api.passedOptions?.allowedFileTypes?[0].mimeTypes, group.mimeTypes);
      expect(api.passedOptions?.allowedFileTypes?[1].label, groupTwo.label);
      expect(api.passedOptions?.allowedFileTypes?[1].extensions, <String>['*.jpg']);
      expect(api.passedOptions?.allowedFileTypes?[1].mimeTypes, groupTwo.mimeTypes);
    });

    test('passes initialDirectory correctly', () async {
      const path = '/example/directory';
      await plugin.openFiles(const OpenDialogOptions(initialDirectory: path));

      expect(api.passedOptions?.currentFolderPath, path);
    });

    test('passes confirmButtonText correctly', () async {
      const button = 'Open File';
      await plugin.openFiles(const OpenDialogOptions(confirmButtonText: button));

      expect(api.passedOptions?.acceptButtonLabel, button);
    });

    test('throws for a type group that does not support Linux', () async {
      const group = XTypeGroup(label: 'images', webWildCards: <String>['images/*']);

      await expectLater(
        plugin.openFiles(const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group])),
        throwsArgumentError,
      );
    });

    test('passes a wildcard group correctly', () async {
      const group = XTypeGroup(label: 'any');

      await plugin.openFiles(const OpenDialogOptions(acceptedTypeGroups: <XTypeGroup>[group]));

      expect(api.passedOptions?.allowedFileTypes?[0].extensions, <String>['*']);
    });
  });

  group('getSaveLocation', () {
    test('passes the core flags correctly', () async {
      const path = '/foo/bar';
      api.result = <String>[path];

      final file = (await plugin.getSaveLocation())!.file as FileSystemXFile;
      expect(file.path, path);

      expect(api.passedType, PlatformFileChooserActionType.save);
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

      expect(api.passedOptions?.allowedFileTypes?[0].label, group.label);
      // Extensions should be converted to *.<extension> format.
      expect(api.passedOptions?.allowedFileTypes?[0].extensions, <String>['*.txt']);
      expect(api.passedOptions?.allowedFileTypes?[0].mimeTypes, group.mimeTypes);
      expect(api.passedOptions?.allowedFileTypes?[1].label, groupTwo.label);
      expect(api.passedOptions?.allowedFileTypes?[1].extensions, <String>['*.jpg']);
      expect(api.passedOptions?.allowedFileTypes?[1].mimeTypes, groupTwo.mimeTypes);
    });

    test('passes initialDirectory correctly', () async {
      const path = '/example/directory';
      await plugin.getSaveLocation(const SaveLocationOptions(initialDirectory: path));

      expect(api.passedOptions?.currentFolderPath, path);
    });

    test('passes confirmButtonText correctly', () async {
      const button = 'Open File';
      await plugin.getSaveLocation(const SaveLocationOptions(confirmButtonText: button));

      expect(api.passedOptions?.acceptButtonLabel, button);
    });

    test('throws for a type group that does not support Linux', () async {
      const group = XTypeGroup(label: 'images', webWildCards: <String>['images/*']);

      await expectLater(
        plugin.getSaveLocation(const SaveLocationOptions(acceptedTypeGroups: <XTypeGroup>[group])),
        throwsArgumentError,
      );
    });

    test('passes a wildcard group correctly', () async {
      const group = XTypeGroup(label: 'any');

      await plugin.getSaveLocation(
        const SaveLocationOptions(acceptedTypeGroups: <XTypeGroup>[group]),
      );

      expect(api.passedOptions?.allowedFileTypes?[0].extensions, <String>['*']);
    });
  });

  group('getDirectory', () {
    test('passes the core flags correctly', () async {
      const path = '/foo/bar';
      api.result = <String>[path];

      final dir = (await plugin.getDirectory())! as FileSystemXDirectory;
      expect(dir.path, path);

      expect(api.passedType, PlatformFileChooserActionType.chooseDirectory);
      expect(api.passedOptions?.selectMultiple, false);
    });

    test('passes initialDirectory correctly', () async {
      const path = '/example/directory';
      await plugin.getDirectory(const OpenDialogOptions(initialDirectory: path));

      expect(api.passedOptions?.currentFolderPath, path);
    });

    test('passes confirmButtonText correctly', () async {
      const button = 'Select Folder';
      await plugin.getDirectory(const OpenDialogOptions(confirmButtonText: button));

      expect(api.passedOptions?.acceptButtonLabel, button);
    });
  });

  group('getDirectories', () {
    test('passes the core flags correctly', () async {
      api.result = <String>['/foo/bar', 'baz'];

      final List<XDirectory> dirs = await plugin.getDirectories();
      expect(dirs.map((XDirectory dir) => (dir as FileSystemXDirectory).path), api.result);

      expect(api.passedType, PlatformFileChooserActionType.chooseDirectory);
      expect(api.passedOptions?.selectMultiple, true);
    });

    test('passes initialDirectory correctly', () async {
      const path = '/example/directory';
      await plugin.getDirectory(const OpenDialogOptions(initialDirectory: path));

      expect(api.passedOptions?.currentFolderPath, path);
    });

    test('passes confirmButtonText correctly', () async {
      const button = 'Select one or mode folders';
      await plugin.getDirectory(const OpenDialogOptions(confirmButtonText: button));

      expect(api.passedOptions?.acceptButtonLabel, button);
    });

    test('passes multiple flag correctly', () async {
      await plugin.getDirectories();

      expect(api.passedOptions?.selectMultiple, true);
    });
  });
}

/// Fake implementation that stores arguments and provides a canned response.
class FakeFileSelectorApi implements FileSelectorApi {
  List<String> result = <String>[];
  PlatformFileChooserActionType? passedType;
  PlatformFileChooserOptions? passedOptions;

  @override
  Future<List<String>> showFileChooser(
    PlatformFileChooserActionType type,
    PlatformFileChooserOptions options,
  ) async {
    passedType = type;
    passedOptions = options;
    return result;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}

final class CrossFileTest extends CrossFilePlatform {}
