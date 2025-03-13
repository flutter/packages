// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:web/web.dart' as web;

const String expectedStringContents = 'Hello, world!';
final Uint8List bytes = utf8.encode(expectedStringContents);
final web.File textFile =
    web.File(<JSUint8Array>[bytes.toJS].toJS, 'hello.txt');
final String textFileUrl = web.URL.createObjectURL(textFile);

void main() {
  group('Create with an objectUrl', () {
    final PickedFile pickedFile = PickedFile(textFileUrl);

    test('Can be read as a string', () async {
      expect(await pickedFile.readAsString(), equals(expectedStringContents));
    });
    test('Can be read as bytes', () async {
      expect(await pickedFile.readAsBytes(), equals(bytes));
    });

    test('Can be read as a stream', () async {
      expect(await pickedFile.openRead().first, equals(bytes));
    });

    test('Stream can be sliced', () async {
      expect(
          await pickedFile.openRead(2, 5).first, equals(bytes.sublist(2, 5)));
    });
  });
}
