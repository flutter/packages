// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// See also dev/automated_tests/flutter_test/flutter_gold_test.dart

import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_goldens/flutter_goldens.dart';
import 'package:flutter_test/flutter_test.dart';

const String _kFlutterRoot = '/flutter';

void main() {
  group('FlutterGoldenFileComparator', () {
    test('calculates the basedir correctly from defaultComparator for local testing', () async {
      final fs = MemoryFileSystem();
      fs.directory(_kFlutterRoot).createSync(recursive: true);
      final defaultComparator = FakeLocalFileComparator();
      final Directory root = fs.directory('/')..createSync(recursive: true);
      defaultComparator.basedir = root.childDirectory('baz').uri;
      final Directory basedir = FlutterGoldenFileComparator.getBaseDirectory(
        defaultComparator,
        fs: fs,
      );
      expect(basedir.uri, fs.directory('/baz/skia_goldens').uri);
    });

    group('_getPackageName', () {
      test('extracts name from pubspec.yaml', () {
        final fs = MemoryFileSystem();
        final Directory packageDir = fs.directory('/my_package')..createSync(recursive: true);
        packageDir.childFile('pubspec.yaml').writeAsStringSync('name: my_package_name\n');
        fs.currentDirectory = packageDir;

        expect(FlutterGoldenFileComparator.getPackageName(fs), 'my_package_name');
      });

      test('traverses upwards to find pubspec.yaml', () {
        final fs = MemoryFileSystem();
        final Directory packageDir = fs.directory('/my_package')..createSync(recursive: true);
        packageDir.childFile('pubspec.yaml').writeAsStringSync('name: my_package_name\n');
        final Directory testDir = packageDir.childDirectory('test')..createSync(recursive: true);
        fs.currentDirectory = testDir;

        expect(FlutterGoldenFileComparator.getPackageName(fs), 'my_package_name');
      });

      test('returns null if no pubspec.yaml is found', () {
        final fs = MemoryFileSystem();
        final Directory someDir = fs.directory('/some/dir')..createSync(recursive: true);
        fs.currentDirectory = someDir;

        expect(FlutterGoldenFileComparator.getPackageName(fs), isNull);
      });

      test('handles invalid yaml gracefully', () {
        final fs = MemoryFileSystem();
        final Directory packageDir = fs.directory('/my_package')..createSync(recursive: true);
        packageDir.childFile('pubspec.yaml').writeAsStringSync('invalid: yaml: : :');
        fs.currentDirectory = packageDir;

        expect(FlutterGoldenFileComparator.getPackageName(fs), isNull);
      });
    });
  });

  group('FlutterSkippingFileComparator', () {
    test('compare returns true', () async {
      final fs = MemoryFileSystem();
      final comparator = FlutterSkippingFileComparator(Uri.parse('/basedir'), 'reason', fs: fs);
      final bool result = await comparator.compare(
        Uint8List.fromList(<int>[1, 2, 3]),
        Uri.parse('golden.png'),
      );
      expect(result, isTrue);
    });
  });
}

class FakeLocalFileComparator extends Fake implements LocalFileComparator {
  @override
  late Uri basedir;
}
