// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cross_file_web/src/web_cross_file.dart';
import 'package:cross_file_web/src/web_helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as html;

const String expectedStringContents = 'Hello, world! I ❤ ñ! 空手';
final Uint8List bytes = Uint8List.fromList(utf8.encode(expectedStringContents));
final html.File textFile = html.File(
  <JSUint8Array>[bytes.toJS].toJS,
  'hello.txt',
);
final String textFileUrl = html.URL.createObjectURL(textFile as JSObject);

void main() {
  group('Create with an objectUrl', () {
    final file = WebXFile(UrlWebXFileCreationParams(objectUrl: textFileUrl));

    test('Can be read as a string', () async {
      expect(await file.readAsString(), equals(expectedStringContents));
    });

    test('Can be read as bytes', () async {
      expect(await file.readAsBytes(), equals(bytes));
    });

    test('Can be read as a stream', () async {
      expect(await file.openRead().first, equals(bytes));
    });

    test('Stream can be sliced', () async {
      expect(await file.openRead(2, 5).first, equals(bytes.sublist(2, 5)));
    });
  });

  group('Blob backend', () {
    final file = WebXFile(BlobWebXFileCreationParams(textFile));

    test('Stores data as a Blob', () async {
      // Read the blob from its path 'natively'
      final html.Response response = await html.window
          .fetch(file.params.uri.toJS)
          .toDart;

      final JSAny arrayBuffer = await response.arrayBuffer().toDart;
      final ByteBuffer data = (arrayBuffer as JSArrayBuffer).toDart;
      expect(data.asUint8List(), equals(bytes));
    });

    test('Data may be purged from the blob!', () async {
      html.URL.revokeObjectURL(file.params.uri);

      final urlFile = WebXFile(
        UrlWebXFileCreationParams(objectUrl: file.params.uri),
      );

      await expectLater(() => urlFile.readAsString(), throwsException);
    });
  });

  group('download', () {
    const crossFileDomElementId = '__x_file_dom_element';

    group('XFile download', () {
      test('creates a DOM container', () async {
        final file = WebXFile(BlobWebXFileCreationParams(textFile));

        await file.download('');

        final html.Element? container = html.document.querySelector(
          '#$crossFileDomElementId',
        );

        expect(container, isNotNull);
      });

      test('create anchor element', () async {
        final file = WebXFile(BlobWebXFileCreationParams(textFile));

        await file.download('path');

        final html.Element container = html.document.querySelector(
          '#$crossFileDomElementId',
        )!;

        late html.HTMLAnchorElement element;
        for (var i = 0; i < container.childNodes.length; i++) {
          final html.Element test = container.children.item(i)!;
          if (test.tagName == 'A') {
            element = test as html.HTMLAnchorElement;
            break;
          }
        }

        // if element is not found, the `firstWhere` call will throw StateError.
        expect(element.href, file.params.uri);
        expect(element.download, 'path');
      });

      test('anchor element is clicked', () async {
        final mockAnchor =
            html.document.createElement('a') as html.HTMLAnchorElement;

        final testOverrides = XFileTestOverrides(
          createAnchorElement: (_, __) => mockAnchor,
        );

        final file = WebXFile(
          BlobWebXFileCreationParams(textFile, testOverrides: testOverrides),
        );

        var clicked = false;
        mockAnchor.onClick.listen((html.MouseEvent event) => clicked = true);

        await file.download('path');

        expect(clicked, true);
      });
    });
  });
}
