#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print(
      'Usage: dart interpret_coverage.dart <coverage_directory> [package_name]',
    );
    exitCode = 64; // Bad usage
    return;
  }
  final dirPath = args[0];
  final packageName = args.length > 1 ? args[1] : null;

  final dir = Directory(dirPath);
  if (!dir.existsSync()) {
    print('Directory not found: $dirPath');
    exitCode = 78; // Configuration error
    return;
  }

  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.vm.json'));

  final coverageData = processCoverage(files, packageName);

  if (coverageData.isEmpty) {
    print('No coverage data found for the specified criteria.');
    return;
  }

  // Print summary
  coverageData.forEach((source, lineHits) {
    final totalLines = lineHits.length;
    final coveredLines = lineHits.values.where((hits) => hits > 0).length;
    final percent = totalLines > 0
        ? (coveredLines / totalLines * 100).toStringAsFixed(1)
        : '100';

    print('$source: $percent% ($coveredLines/$totalLines lines)');

    // Show missed lines
    final missed =
        lineHits.entries.where((e) => e.value == 0).map((e) => e.key).toList()
          ..sort();

    if (missed.isNotEmpty) {
      print('  Missed lines: ${missed.join(', ')}');
    }
  });
}

/// Processes a list of coverage files and returns a map of file paths to line hit counts.
///
/// The returned map structure is: `{ file_uri: { line_number: hit_count } }`.
///
/// If [packageName] is provided, only files starting with `package:$packageName/` are included.
/// Files containing `/test/` are skipped.
Map<String, Map<int, int>> processCoverage(
  Iterable<File> files,
  String? packageName,
) {
  final coverageData = <String, Map<int, int>>{}; // file -> (line -> hits)
  for (final file in files) {
    final content = file.readAsStringSync();
    final json = jsonDecode(content) as Map<String, dynamic>;
    final coverage = json['coverage'] as List<dynamic>;

    for (final item in coverage) {
      final source = item['source'] as String;

      // Filter by package name if provided
      if (packageName != null && !source.startsWith('package:$packageName/')) {
        continue;
      }

      // Skip test files usually
      if (source.contains('/test/')) continue;

      final hits = item['hits'] as List<dynamic>;
      final fileData = coverageData.putIfAbsent(source, () => <int, int>{});

      for (var i = 0; i < hits.length; i += 2) {
        final line = hits[i] as int;
        final count = hits[i + 1] as int;
        fileData[line] = (fileData[line] ?? 0) + count;
      }
    }
  }
  return coverageData;
}
