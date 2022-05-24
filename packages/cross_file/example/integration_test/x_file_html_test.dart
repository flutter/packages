// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:js/js_util.dart' as js_util;

const String expectedStringContents = 'Hello, world! I ❤ ñ! 空手';
final Uint8List bytes = Uint8List.fromList(utf8.encode(expectedStringContents));
final html.File textFile = html.File(<Object>[bytes], 'hello.txt');
final String textFileUrl = html.Url.createObjectUrl(textFile);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Create with an objectUrl', () {
    final XFile file = XFile(textFileUrl);

    testWidgets('Can be read as a string', (WidgetTester tester) async {
      expect(await file.readAsString(), equals(expectedStringContents));
    });

    testWidgets('Can be read as bytes', (WidgetTester tester) async {
      expect(await file.readAsBytes(), equals(bytes));
    });

    testWidgets('Can be read as a stream', (WidgetTester tester) async {
      expect(await file.openRead().first, equals(bytes));
    });

    testWidgets('Stream can be sliced', (WidgetTester tester) async {
      expect(await file.openRead(2, 5).first, equals(bytes.sublist(2, 5)));
    });
  });

  group('Create from data', () {
    final XFile file = XFile.fromData(bytes);

    testWidgets('Can be read as a string', (WidgetTester tester) async {
      expect(await file.readAsString(), equals(expectedStringContents));
    });

    testWidgets('Can be read as bytes', (WidgetTester tester) async {
      expect(await file.readAsBytes(), equals(bytes));
    });

    testWidgets('Can be read as a stream', (WidgetTester tester) async {
      expect(await file.openRead().first, equals(bytes));
    });

    testWidgets('Stream can be sliced', (WidgetTester tester) async {
      expect(await file.openRead(2, 5).first, equals(bytes.sublist(2, 5)));
    });
  });

  group('Blob backend', () {
    final XFile file = XFile(textFileUrl);

    testWidgets('Stores data as a Blob', (WidgetTester tester) async {
      // Read the blob from its path 'natively'
      final Object response = await html.window.fetch(file.path);
      // Call '.arrayBuffer()' on the fetch response object to look at its bytes.
      final ByteBuffer data = await js_util.promiseToFuture(
        js_util.callMethod(response, 'arrayBuffer', <Object?>[]),
      );
      expect(data.asUint8List(), equals(bytes));
    });

    testWidgets('Data may be purged from the blob!',
        (WidgetTester tester) async {
      html.Url.revokeObjectUrl(file.path);

      expect(() async {
        await file.readAsBytes();
      }, throwsException);
    });
  });

  group('saveTo(..)', () {
    const String crossFileDomElementId = '__x_file_dom_element';

    group('CrossFile saveTo(..)', () {
      testWidgets('creates a DOM container', (WidgetTester tester) async {
        final XFile file = XFile.fromData(bytes);

        await file.saveTo('');

        final html.Element? container =
            html.querySelector('#$crossFileDomElementId');

        expect(container, isNotNull);
      });

      testWidgets('create anchor element', (WidgetTester tester) async {
        final XFile file = XFile.fromData(bytes, name: textFile.name);

        await file.saveTo('path');

        final html.Element container =
            html.querySelector('#$crossFileDomElementId')!;
        final html.AnchorElement element = container.children
                .firstWhere((html.Element element) => element.tagName == 'A')
            as html.AnchorElement;

        // if element is not found, the `firstWhere` call will throw StateError.
        expect(element.href, file.path);
        expect(element.download, file.name);
      });

      testWidgets('anchor element is clicked', (WidgetTester tester) async {
        final html.AnchorElement mockAnchor = html.AnchorElement();

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
