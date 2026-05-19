import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import '../interpret_coverage.dart';

void main() {
  /// Helper to create a mock coverage file.
  /// Takes a list of items where 'hits' is a Map<int, int> (line -> hits).
  File createMockCoverageFile(
    Directory dir,
    String filename,
    List<Map<String, dynamic>> coverageItems,
  ) {
    final file = File('${dir.path}/$filename');

    final processedItems = coverageItems.map((item) {
      final source = item['source'] as String;
      final hitsMap = item['hits'] as Map<int, int>;
      final flatHits = <int>[];
      hitsMap.forEach((line, count) {
        flatHits.add(line);
        flatHits.add(count);
      });
      return {'source': source, 'hits': flatHits};
    }).toList();

    final json = {'coverage': processedItems};
    file.writeAsStringSync(jsonEncode(json));
    return file;
  }

  test('processCoverage extracts data correctly', () {
    final tempDir = Directory.systemTemp.createTempSync('coverage_test');
    final coverageFile = createMockCoverageFile(tempDir, 'test.vm.json', [
      {
        'source': 'package:foo/bar.dart',
        'hits': {1: 1, 2: 0},
      },
    ]);

    try {
      final result = processCoverage([coverageFile], null);
      expect(result, contains('package:foo/bar.dart'));
      expect(result['package:foo/bar.dart'], {1: 1, 2: 0});
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('processCoverage filters by package name', () {
    final tempDir = Directory.systemTemp.createTempSync('coverage_test');
    final coverageFile = createMockCoverageFile(tempDir, 'test.vm.json', [
      {
        'source': 'package:foo/bar.dart',
        'hits': {1: 1},
      },
      {
        'source': 'package:baz/qux.dart',
        'hits': {1: 1},
      },
    ]);

    try {
      final result = processCoverage([coverageFile], 'foo');
      expect(result, contains('package:foo/bar.dart'));
      expect(result, isNot(contains('package:baz/qux.dart')));
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('processCoverage skips test files', () {
    final tempDir = Directory.systemTemp.createTempSync('coverage_test');
    final coverageFile = createMockCoverageFile(tempDir, 'test.vm.json', [
      {
        'source': 'package:foo/test/bar_test.dart',
        'hits': {1: 1},
      },
      {
        'source': 'package:foo/bar.dart',
        'hits': {1: 1},
      },
    ]);

    try {
      final result = processCoverage([coverageFile], 'foo');
      expect(result, contains('package:foo/bar.dart'));
      expect(result, isNot(contains('package:foo/test/bar_test.dart')));
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  });
}
