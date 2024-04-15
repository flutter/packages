// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/src/dom_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart';

void main() {
  group('dom_helper', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    late DomHelper domHelper;
    late HTMLInputElement input;

    FileList? createFileList(List<File> files) {
      final DataTransfer dataTransfer = DataTransfer();
      // Tear-offs of external extension type interop member 'add' are disallowed.
      // ignore: prefer_foreach
      for (final File e in files) {
        dataTransfer.items.add(e);
      }
      return dataTransfer.files;
    }

    void setFilesAndTriggerEvent(List<File> files, Event event) {
      input.files = createFileList(files);
      input.dispatchEvent(event);
    }

    void setFilesAndTriggerChange(List<File> files) {
      setFilesAndTriggerEvent(files, Event('change'));
    }

    void setFilesAndTriggerCancel(List<File> files) {
      setFilesAndTriggerEvent(files, Event('cancel'));
    }

    setUp(() {
      domHelper = DomHelper();
      input = (document.createElement('input') as HTMLInputElement)
        ..type = 'file';
    });

    group('getFiles', () {
      final File mockFile1 = File(<JSAny>['123456'.toJS].toJS, 'file1.txt');
      final File mockFile2 = File(<JSAny>[].toJS, 'file2.txt');

      testWidgets('works', (_) async {
        final Future<List<XFile>> futureFiles = domHelper.getFiles(
          input: input,
        );

        setFilesAndTriggerChange(<File>[mockFile1, mockFile2]);

        final List<XFile> files = await futureFiles;

        expect(files.length, 2);

        expect(files[0].name, 'file1.txt');
        expect(await files[0].length(), 6);
        expect(await files[0].readAsString(), '123456');
        expect(await files[0].lastModified(), isNotNull);

        expect(files[1].name, 'file2.txt');
        expect(await files[1].length(), 0);
        expect(await files[1].readAsString(), '');
        expect(await files[1].lastModified(), isNotNull);
      });

      testWidgets('"cancel" returns an empty selection', (_) async {
        final Future<List<XFile>> futureFiles = domHelper.getFiles(
          input: input,
        );

        setFilesAndTriggerCancel(<File>[mockFile1, mockFile2]);

        final List<XFile> files = await futureFiles;

        expect(files.length, 0);
      });

      testWidgets('works multiple times', (_) async {
        Future<List<XFile>> futureFiles;
        List<XFile> files;

        // It should work the first time
        futureFiles = domHelper.getFiles(input: input);
        setFilesAndTriggerChange(<File>[mockFile1]);

        files = await futureFiles;

        expect(files.length, 1);
        expect(files.first.name, mockFile1.name);

        // The same input should work more than once
        futureFiles = domHelper.getFiles(input: input);
        setFilesAndTriggerChange(<File>[mockFile2]);

        files = await futureFiles;

        expect(files.length, 1);
        expect(files.first.name, mockFile2.name);
      });

      testWidgets('sets the <input /> attributes and clicks it', (_) async {
        const String accept = '.jpg,.png';
        const bool multiple = true;
        final Future<bool> wasClicked = input.onClick.first.then((_) => true);

        final Future<List<XFile>> futureFile = domHelper.getFiles(
          accept: accept,
          multiple: multiple,
          input: input,
        );

        expect(input.isConnected, true,
            reason: 'input must be injected into the DOM');
        expect(input.accept, accept);
        expect(input.multiple, multiple);
        expect(await wasClicked, true,
            reason:
                'The <input /> should be clicked otherwise no dialog will be shown');

        setFilesAndTriggerChange(<File>[]);
        await futureFile;

        // It should be already removed from the DOM after the file is resolved.
        expect(input.isConnected, isFalse);
      });
    });
  });
}
