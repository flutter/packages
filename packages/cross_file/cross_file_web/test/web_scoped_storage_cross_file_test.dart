// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:cross_file_web/cross_file_web.dart';
import 'package:cross_file_web/src/web_helpers.dart';
import 'package:cross_file_web/src/web_scoped_storage_cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as html;

const String testFileStringContents = 'Hello, world! I ❤ ñ! 空手';
final Uint8List testFileBytes = Uint8List.fromList(utf8.encode(testFileStringContents));
final html.File testFile = html.File(<JSUint8Array>[testFileBytes.toJS].toJS, 'hello.txt');
final String testFileUrl = html.URL.createObjectURL(testFile as JSObject);

void main() {
  group('WebScopedStorageXFile', () {
    CrossFilePlatform.instance = CrossFileWeb();

    group('Create with url', () {
      test('openRead', () async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.openRead().first, testFileBytes);
      });

      test('openRead with partial data', () async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.openRead(2, 5).first, testFileBytes.sublist(2, 5));
      });

      test('readAsBytes', () async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.readAsBytes(), testFileBytes);
      });

      test('readAsString', () async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.readAsString(), testFileStringContents);
      });

      test('canRead', () async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.canRead(), true);
      });

      test('exists', () async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.exists(), true);
      });
    });

    group('Create with File', () {
      test('lastModified', () async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(
          await file.lastModified(),
          DateTime.fromMillisecondsSinceEpoch(testFile.lastModified),
        );
      });

      test('length', () async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.length(), testFile.size);
      });

      test('openRead', () async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.openRead().first, testFileBytes);
      });

      test('openRead with partial data', () async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.openRead(2, 5).first, testFileBytes.sublist(2, 5));
      });

      test('readAsBytes', () async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.readAsBytes(), testFileBytes);
      });

      test('readAsString', () async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.readAsString(), testFileStringContents);
      });

      test('exists', () async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.exists(), true);
      });

      test('name', () async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.name(), testFile.name);
      });
    });

    group('download', () {
      const crossFileDomElementId = '__x_file_dom_element';

      group('XFile download', () {
        test('creates a DOM container', () async {
          final mockAnchor = html.document.createElement('a') as html.HTMLAnchorElement;
          final testOverrides = XFileTestOverrides(createAnchorElement: (_, _) => mockAnchor);

          final file = WebScopedStorageXFile(
            WebScopedStorageXFileCreationParams.fromBlob(testFile, testOverrides: testOverrides),
          );

          await file.download();

          final html.Element? container = html.document.querySelector('#$crossFileDomElementId');

          expect(container, isNotNull);
        });

        test('create anchor element', () async {
          final mockAnchor = html.document.createElement('a') as html.HTMLAnchorElement;
          late final String setHref;
          late final String? setDownload;
          final testOverrides = XFileTestOverrides(
            createAnchorElement: (String href, String? suggestedName) {
              setHref = href;
              setDownload = suggestedName;
              return mockAnchor;
            },
          );

          final file = WebScopedStorageXFile(
            WebScopedStorageXFileCreationParams.fromBlob(testFile, testOverrides: testOverrides),
          );

          await file.download('path');

          final html.Element container = html.document.querySelector('#$crossFileDomElementId')!;

          // Find anchor element.
          late final html.HTMLAnchorElement element;
          for (var i = 0; i < container.childNodes.length; i++) {
            element = container.children.item(i)! as html.HTMLAnchorElement;
          }

          // If element is not found, the `firstWhere` call will throw StateError.
          expect(element, mockAnchor);
          expect(element.tagName, 'A');
          expect(setHref, file.params.uri);
          expect(setDownload, 'path');
        });

        test('anchor element is clicked', () async {
          final mockAnchor = html.document.createElement('a') as html.HTMLAnchorElement;

          final testOverrides = XFileTestOverrides(createAnchorElement: (_, _) => mockAnchor);

          final file = WebScopedStorageXFile(
            WebScopedStorageXFileCreationParams.fromBlob(testFile, testOverrides: testOverrides),
          );

          var clicked = false;
          mockAnchor.onClick.listen((html.MouseEvent event) => clicked = true);

          await file.download('path');

          expect(clicked, true);
        });
      });
    });
  });
}
