// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:file_selector_android/src/file_selector_android.dart';
import 'package:file_selector_android/src/file_selector_api.g.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'file_selector_android_test.mocks.dart';

@GenerateMocks(<Type>[FileSelectorApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CrossFilePlatform.instance = CrossFileTest();

  late FileSelectorAndroid plugin;
  late MockFileSelectorApi mockApi;

  setUp(() {
    mockApi = MockFileSelectorApi();
    plugin = FileSelectorAndroid(api: mockApi);
  });

  test('registered instance', () {
    FileSelectorAndroid.registerWith();

    expect(FileSelectorPlatform.instance, isA<FileSelectorAndroid>());
  });

  group('openFile', () {
    test('passes the accepted type groups correctly', () async {
      when(
        mockApi.openFile(
          'some/path/',
          argThat(
            isA<FileTypes>()
                .having((FileTypes types) => types.mimeTypes, 'mimeTypes', <String>[
                  'text/plain',
                  'image/jpg',
                ])
                .having((FileTypes types) => types.extensions, 'extensions', <String>[
                  'txt',
                  'jpg',
                ]),
          ),
        ),
      ).thenAnswer((_) => Future<String?>.value('some/path.txt'));

      const group = XTypeGroup(extensions: <String>['txt'], mimeTypes: <String>['text/plain']);

      const group2 = XTypeGroup(extensions: <String>['jpg'], mimeTypes: <String>['image/jpg']);

      final XFile? file = await plugin.openFile(
        const OpenDialogOptions(
          acceptedTypeGroups: <XTypeGroup>[group, group2],
          initialDirectory: 'some/path/',
        ),
      );

      expect(file?.uri, 'some/path.txt');
    });
  });

  group('openFiles', () {
    test('passes the accepted type groups correctly', () async {
      when(
        mockApi.openFiles(
          'some/path/',
          argThat(
            isA<FileTypes>()
                .having((FileTypes types) => types.mimeTypes, 'mimeTypes', <String>[
                  'text/plain',
                  'image/jpg',
                ])
                .having((FileTypes types) => types.extensions, 'extensions', <String>[
                  'txt',
                  'jpg',
                ]),
          ),
        ),
      ).thenAnswer((_) => Future<List<String>>.value(<String>['some/path.txt', 'other/dir.jpg']));

      const group = XTypeGroup(extensions: <String>['txt'], mimeTypes: <String>['text/plain']);

      const group2 = XTypeGroup(extensions: <String>['jpg'], mimeTypes: <String>['image/jpg']);

      final List<XFile> files = await plugin.openFiles(
        const OpenDialogOptions(
          acceptedTypeGroups: <XTypeGroup>[group, group2],
          initialDirectory: 'some/path/',
        ),
      );

      expect(files[0].uri, 'some/path.txt');

      expect(files[1].uri, 'other/dir.jpg');
    });
  });

  test('getDirectory', () async {
    when(
      mockApi.getDirectoryPath('some/path'),
    ).thenAnswer((_) => Future<String?>.value('some/path/chosen/'));

    final XDirectory? dir = await plugin.getDirectory(
      const FileDialogOptions(initialDirectory: 'some/path'),
    );

    expect(dir?.uri, 'some/path/chosen/');
  });
}

final class CrossFileTest extends CrossFilePlatform {}
