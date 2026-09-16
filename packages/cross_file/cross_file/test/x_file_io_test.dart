// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm') // Uses dart:io
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:test/test.dart';

final String pathPrefix = Directory.current.path.endsWith('test') ? './assets/' : './test/assets/';
final String path = '${pathPrefix}hello.txt';
const String expectedStringContents = 'Hello, world!';
final Uint8List bytes = Uint8List.fromList(utf8.encode(expectedStringContents));
final File textFile = File(path);
final String textFilePath = textFile.path;

void main() {
  group('Create with a path', () {
    test('Can be read as a string', () async {
      final file = XFile(textFilePath);
      expect(await file.readAsString(), equals(expectedStringContents));
    });
    test('Can be read as bytes', () async {
      final file = XFile(textFilePath);
      expect(await file.readAsBytes(), equals(bytes));
    });

    test('Can be read as a stream', () async {
      final file = XFile(textFilePath);
      expect(await file.openRead().first, equals(bytes));
    });

    test('Stream can be sliced', () async {
      final file = XFile(textFilePath);
      expect(await file.openRead(2, 5).first, equals(bytes.sublist(2, 5)));
    });

    test('saveTo(..) creates file', () async {
      final file = XFile(textFilePath);
      final Directory tempDir = Directory.systemTemp.createTempSync();
      final targetFile = File('${tempDir.path}/newFilePath.txt');
      if (targetFile.existsSync()) {
        await targetFile.delete();
      }

      await file.saveTo(targetFile.path);

      expect(targetFile.existsSync(), isTrue);
      expect(targetFile.readAsStringSync(), 'Hello, world!');

      await tempDir.delete(recursive: true);
    });

    test('saveTo(..) does not load the file into memory', () async {
      final file = TestXFile(textFilePath);
      final Directory tempDir = Directory.systemTemp.createTempSync();
      final targetFile = File('${tempDir.path}/newFilePath.txt');
      if (targetFile.existsSync()) {
        await targetFile.delete();
      }

      await file.saveTo(targetFile.path);

      expect(file.hasBeenRead, isFalse);

      await tempDir.delete(recursive: true);
    });

    test('nullability is correct', () async {
      expect(_ensureNonnullPathArgument('a/path'), isNotNull);
    });
  });

  group('Create with data', () {
    final file = XFile.fromData(bytes);

    test('Can be read as a string', () async {
      expect(await file.readAsString(), equals(expectedStringContents));
    });

    test('Can be read as a string with multi-byte characters', () async {
      const contents = 'Hello, world! I ❤ ñ! 空手 😀';
      final multiByteFile = XFile.fromData(utf8.encode(contents));
      expect(await multiByteFile.readAsString(), equals(contents));
    });

    test('Can be read as a string with a non-default encoding', () async {
      const contents = 'Une soirée à Genève';
      final latin1File = XFile.fromData(latin1.encode(contents));
      expect(await latin1File.readAsString(encoding: latin1), equals(contents));
    });

    test('Reading undecodable data fails the future', () async {
      final malformedFile = XFile.fromData(Uint8List.fromList(<int>[0xc3, 0x28]));
      await expectLater(malformedFile.readAsString(), throwsA(isA<FormatException>()));
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

    test('Function saveTo(..) creates file', () async {
      final Directory tempDir = Directory.systemTemp.createTempSync();
      final targetFile = File('${tempDir.path}/newFilePath.txt');
      if (targetFile.existsSync()) {
        await targetFile.delete();
      }

      await file.saveTo(targetFile.path);

      expect(targetFile.existsSync(), isTrue);
      expect(targetFile.readAsStringSync(), 'Hello, world!');

      await tempDir.delete(recursive: true);
    });
  });
}

// This is to create an analysis error if the version of XFile in
// interface.dart, which should never actually be used but is what the analyzer
// runs against, has the nullability of `path` changed.
XFile _ensureNonnullPathArgument(String? path) {
  return XFile(path!);
}

/// An XFile subclass that tracks reads, for testing purposes.
class TestXFile extends XFile {
  TestXFile(super.path);

  bool hasBeenRead = false;

  @override
  Future<Uint8List> readAsBytes() {
    hasBeenRead = true;
    return super.readAsBytes();
  }
}
