// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/pending_changelog_entry.dart';
import 'package:test/test.dart';

void main() {
  group('PendingChangelogEntry', () {
    test('parses valid entry', () {
      final File file = MemoryFileSystem().file('a.yaml');
      const yaml = '''
changelog: A
version: patch
''';
      final entry = PendingChangelogEntry.parse(yaml, file);

      expect(entry.changelog, 'A');
      expect(entry.version, VersionChange.patch);
      expect(entry.file, file);
    });

    test('throws for non-map YAML', () {
      final File file = MemoryFileSystem().file('a.yaml');
      expect(
        () => PendingChangelogEntry.parse('not a map', file),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('Expected a YAML map'),
          ),
        ),
      );
    });

    test('throws for missing changelog', () {
      final File file = MemoryFileSystem().file('a.yaml');
      expect(
        () => PendingChangelogEntry.parse('version: patch', file),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('Expected "changelog" to be a string'),
          ),
        ),
      );
    });

    test('throws for missing version', () {
      final File file = MemoryFileSystem().file('a.yaml');
      expect(
        () => PendingChangelogEntry.parse('changelog: A', file),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('Missing "version" key'),
          ),
        ),
      );
    });

    test('throws for invalid version', () {
      final File file = MemoryFileSystem().file('a.yaml');
      expect(
        () => PendingChangelogEntry.parse('''
changelog: A
version: invalid
''', file),
        throwsA(
          isA<FormatException>().having(
            (FormatException e) => e.message,
            'message',
            contains('Invalid version type'),
          ),
        ),
      );
    });
  });
}
