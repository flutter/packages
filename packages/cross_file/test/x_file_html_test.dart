// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:cross_file/web/factory.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as html;

const String expectedStringContents = 'Hello, world! I ❤ ñ! 空手';
final Uint8List bytes = Uint8List.fromList(utf8.encode(expectedStringContents));
final html.File textFile =
    html.File(<JSUint8Array>[bytes.toJS].toJS, 'hello.txt');
final String textFileUrl = html.URL.createObjectURL(textFile);

void main() {
  group('Create with an objectUrl', () {
    late XFile file;

    setUp(() async {
      file = await XFileFactory.fromObjectUrl(textFileUrl);
    });

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
    final XFile file = XFileFactory.fromBytes(bytes);

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
    late String objectUrl;

    setUp(() async {
      objectUrl = html.URL.createObjectURL(textFile);
    });

    test('Stores data as a Blob', () async {
      // Read the blob from its path 'natively'
      final html.Response response =
          await html.window.fetch(objectUrl.toJS).toDart;

      final JSAny arrayBuffer = await response.arrayBuffer().toDart;
      final ByteBuffer data = (arrayBuffer as JSArrayBuffer).toDart;
      expect(data.asUint8List(), equals(bytes));
    });

    test('Data may be purged from the blob!', () async {
      expect(() async {
        final XFile fileBeforeRevoke =
            await XFileFactory.fromObjectUrl(objectUrl);
        await fileBeforeRevoke.readAsBytes();
      }, returnsNormally);

      html.URL.revokeObjectURL(objectUrl);

      expect(() async {
        final XFile fileAfterRevoke =
            await XFileFactory.fromObjectUrl(objectUrl);
        await fileAfterRevoke.readAsBytes();
      }, throwsStateError);
    });
  });

  group('saveTo(..)', () {
    const String crossFileDomElementId = '__x_file_dom_element';

    group('CrossFile saveTo(..)', () {
      test('creates a DOM container', () async {
        final XFile file = XFileFactory.fromBytes(bytes);

        await file.saveTo('');

        final html.Element? container =
            html.document.querySelector('#$crossFileDomElementId');

        expect(container, isNotNull);
      });

      test('create anchor element', () async {
        final XFile file = XFileFactory.fromFile(textFile);

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
        expect(element.href, isNotEmpty);
        expect(element.download, file.name);
      });
    });
  });
}
