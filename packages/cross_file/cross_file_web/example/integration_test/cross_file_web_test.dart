// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:cross_file_web/cross_file_web.dart';
import 'package:cross_file_web/src/web_helpers.dart';
import 'package:cross_file_web/src/web_scoped_storage_cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as html;

const String testFileStringContents = 'Hello, world! I ❤ ñ! 空手';
final Uint8List testFileBytes = Uint8List.fromList(utf8.encode(testFileStringContents));
final html.File testFile = html.File(<JSUint8Array>[testFileBytes.toJS].toJS, 'hello.txt');
final String testFileUrl = html.URL.createObjectURL(testFile as JSObject);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('WebScopedStorageXFile', () {
    CrossFilePlatform.instance = CrossFileWeb();

    group('Create with url', () {
      testWidgets('openRead', (_) async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.openRead().first, testFileBytes);
      });

      testWidgets('openRead with partial data', (_) async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.openRead(2, 5).first, testFileBytes.sublist(2, 5));
      });

      testWidgets('readAsBytes', (_) async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.readAsBytes(), testFileBytes);
      });

      testWidgets('readAsString', (_) async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.readAsString(), testFileStringContents);
      });

      testWidgets('canRead', (_) async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.canRead(), true);
      });

      testWidgets('exists', (_) async {
        final file = PlatformScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: testFileUrl),
        );

        expect(await file.exists(), true);
      });
    });

    group('Create with File', () {
      testWidgets('lastModified', (_) async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(
          await file.lastModified(),
          DateTime.fromMillisecondsSinceEpoch(testFile.lastModified),
        );
      });

      testWidgets('length', (_) async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.length(), testFile.size);
      });

      testWidgets('openRead', (_) async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.openRead().first, testFileBytes);
      });

      testWidgets('openRead with partial data', (_) async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.openRead(2, 5).first, testFileBytes.sublist(2, 5));
      });

      testWidgets('readAsBytes', (_) async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.readAsBytes(), testFileBytes);
      });

      testWidgets('readAsString', (_) async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.readAsString(), testFileStringContents);
      });

      testWidgets('exists', (_) async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.exists(), true);
      });

      testWidgets('name', (_) async {
        final file = PlatformScopedStorageXFile(
          WebScopedStorageXFileCreationParams.fromBlob(testFile),
        );

        expect(await file.name(), testFile.name);
      });
    });

    group('download', () {
      const crossFileDomElementId = '__x_file_dom_element';

      group('XFile download', () {
        testWidgets('creates a DOM container', (_) async {
          final mockAnchor = html.document.createElement('a') as html.HTMLAnchorElement;
          final testOverrides = XFileTestOverrides(createAnchorElement: (_, _) => mockAnchor);

          final file = WebScopedStorageXFile(
            WebScopedStorageXFileCreationParams.fromBlob(testFile, testOverrides: testOverrides),
          );

          await file.download();

          final html.Element? container = html.document.querySelector('#$crossFileDomElementId');

          expect(container, isNotNull);
        });

        testWidgets('create anchor element', (_) async {
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

        testWidgets('anchor element is clicked', (_) async {
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
