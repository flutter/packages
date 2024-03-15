// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as html;

const String expectedStringContents = 'Hello, world! I ❤ ñ! 空手';
final Uint8List bytes = Uint8List.fromList(utf8.encode(expectedStringContents));
final html.File textFile =
    html.File(<JSUint8Array>[bytes.toJS].toJS, 'hello.txt');
final String textFileUrl =
    // TODO(kevmoo): drop ignore when pkg:web constraint excludes v0.3
    // ignore: unnecessary_cast
    html.URL.createObjectURL(textFile as JSObject);

void main() {
  group('Create with an objectUrl', () {
    final XFile file = XFile(textFileUrl);

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

  group('Create from data', () {
    final XFile file = XFile.fromData(bytes);

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
    final XFile file = XFile(textFileUrl);

    test('Stores data as a Blob', () async {
      // Read the blob from its path 'natively'
      final html.Response response =
          await html.window.fetch(file.path.toJS).toDart;

      final JSAny arrayBuffer = await response.arrayBuffer().toDart;
      final ByteBuffer data = (arrayBuffer as JSArrayBuffer).toDart;
      expect(data.asUint8List(), equals(bytes));
    });

    test('Data may be purged from the blob!', () async {
      html.URL.revokeObjectURL(file.path);

      expect(() async {
        await file.readAsBytes();
      }, throwsException);
    });
  });

  group('saveTo(..)', () {
    const String crossFileDomElementId = '__x_file_dom_element';

    group('CrossFile saveTo(..)', () {
      test('creates a DOM container', () async {
        final XFile file = XFile.fromData(bytes);

        await file.saveTo('');

        final html.Element? container =
            html.document.querySelector('#$crossFileDomElementId');

        expect(container, isNotNull);
      });

      test('create anchor element', () async {
        final XFile file = XFile.fromData(bytes, name: textFile.name);

        await file.saveTo('path');

        final html.Element container =
            html.document.querySelector('#$crossFileDomElementId')!;

        late html.HTMLAnchorElement element;
        for (int i = 0; i < container.childNodes.length; i++) {
          final html.Element test = container.children.item(i)!;
          if (test.tagName == 'A') {
            element = test as html.HTMLAnchorElement;
            break;
          }
        }

        // if element is not found, the `firstWhere` call will throw StateError.
        expect(element.href, file.path);
        expect(element.download, file.name);
      });

      test('anchor element is clicked', () async {
        final html.HTMLAnchorElement mockAnchor =
            html.document.createElement('a') as html.HTMLAnchorElement;

        final CrossFileTestOverrides overrides = CrossFileTestOverrides(
          createAnchorElement: (_, __) => mockAnchor,
        );

        final XFile file =
            XFile.fromData(bytes, name: textFile.name, overrides: overrides);

        bool clicked = false;
        mockAnchor.onClick.listen((html.MouseEvent event) => clicked = true);

        await file.saveTo('path');

        expect(clicked, true);
      });
    });
  });
}
