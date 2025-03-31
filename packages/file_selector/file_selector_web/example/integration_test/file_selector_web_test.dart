// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/file_selector_web.dart';
import 'package:file_selector_web/src/dom_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart';

void main() {
  group('FileSelectorWeb', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    group('openFile', () {
      testWidgets('works', (WidgetTester _) async {
        final XFile mockFile = createXFile('1001', 'identity.png');

        final MockDomHelper mockDomHelper = MockDomHelper(
            files: <XFile>[mockFile],
            expectAccept: '.jpg,.jpeg,image/png,image/*');

        final FileSelectorWeb plugin =
            FileSelectorWeb(domHelper: mockDomHelper);

        const XTypeGroup typeGroup = XTypeGroup(
          label: 'images',
          extensions: <String>['jpg', 'jpeg'],
          mimeTypes: <String>['image/png'],
          webWildCards: <String>['image/*'],
        );

        final XFile? file =
            await plugin.openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

        expect(file, isNotNull);
        expect(file!.name, mockFile.name);
        expect(await file.length(), 4);
        expect(await file.readAsString(), '1001');
        expect(await file.lastModified(), isNotNull);
      });

      testWidgets('returns null when getFiles returns an empty list',
          (WidgetTester _) async {
        // Simulate returning an empty list of files from the DomHelper...
        final MockDomHelper mockDomHelper = MockDomHelper(
          files: <XFile>[],
        );

        final FileSelectorWeb plugin =
            FileSelectorWeb(domHelper: mockDomHelper);

        final XFile? file = await plugin.openFile();

        expect(file, isNull);
      });
    });

    group('openFiles', () {
      testWidgets('works', (WidgetTester _) async {
        final XFile mockFile1 = createXFile('123456', 'file1.txt');
        final XFile mockFile2 = createXFile('', 'file2.txt');

        final MockDomHelper mockDomHelper = MockDomHelper(
            files: <XFile>[mockFile1, mockFile2],
            expectAccept: '.txt',
            expectMultiple: true);

        final FileSelectorWeb plugin =
            FileSelectorWeb(domHelper: mockDomHelper);

        const XTypeGroup typeGroup = XTypeGroup(
          label: 'files',
          extensions: <String>['.txt'],
        );

        final List<XFile> files =
            await plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

        expect(files.length, 2);

        expect(files[0].name, mockFile1.name);
        expect(await files[0].length(), 6);
        expect(await files[0].readAsString(), '123456');
        expect(await files[0].lastModified(), isNotNull);

        expect(files[1].name, mockFile2.name);
        expect(await files[1].length(), 0);
        expect(await files[1].readAsString(), '');
        expect(await files[1].lastModified(), isNotNull);
      });
    });

    group('getSavePath', () {
      testWidgets('returns non-null', (WidgetTester _) async {
        final FileSelectorWeb plugin = FileSelectorWeb();
        final Future<String?> savePath = plugin.getSavePath();
        expect(await savePath, isNotNull);
      });
    });
  });
}

class MockDomHelper implements DomHelper {
  MockDomHelper({
    List<XFile> files = const <XFile>[],
    String expectAccept = '',
    bool expectMultiple = false,
  })  : _files = files,
        _expectedAccept = expectAccept,
        _expectedMultiple = expectMultiple;

  final List<XFile> _files;
  final String _expectedAccept;
  final bool _expectedMultiple;

  @override
  Future<List<XFile>> getFiles({
    String accept = '',
    bool multiple = false,
    HTMLInputElement? input,
  }) {
    expect(accept, _expectedAccept,
        reason: 'Expected "accept" value does not match.');
    expect(multiple, _expectedMultiple,
        reason: 'Expected "multiple" value does not match.');
    return Future<List<XFile>>.value(_files);
  }
}

XFile createXFile(String content, String name) {
  final Uint8List data = Uint8List.fromList(content.codeUnits);
  return XFile.fromData(data, name: name, lastModified: DateTime.now());
}
