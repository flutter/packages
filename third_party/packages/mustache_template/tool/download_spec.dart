import 'dart:io';

/// Clones the mustache/spec repository, embeds each JSON spec as a Dart raw
/// string under `test/specs/`, and writes `test/specs/specs.dart` with a
/// `SPECS` map.
///
/// Run from the package root:
/// `dart run tool/download_spec.dart`
Future<void> main(List<String> args) async {
  final Directory packageRoot = _packageRootDirectory();
  final testSpecsDir = Directory(_join(packageRoot.path, 'test', 'specs'));
  final String tmpSpecPath = _join(packageRoot.path, 'tmp_spec');
  final tmpSpecDir = Directory(tmpSpecPath);

  if (tmpSpecDir.existsSync()) {
    await tmpSpecDir.delete(recursive: true);
  }

  await _runGit(packageRoot.path, <String>[
    'clone',
    'https://github.com/mustache/spec.git',
    tmpSpecPath,
  ]);

  final String headHash =
      ((await _runGit(packageRoot.path, <String>[
                '-C',
                tmpSpecPath,
                'rev-parse',
                'HEAD',
              ])).stdout
              as String)
          .trim();

  final String utcNow = _formatUtcSecond(DateTime.now().toUtc());

  if (testSpecsDir.existsSync()) {
    await testSpecsDir.delete(recursive: true);
  }
  await testSpecsDir.create(recursive: true);

  final clonedSpecs = Directory(_join(tmpSpecPath, 'specs'));
  final List<File> jsonFiles =
      clonedSpecs
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.json'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));

  final exports = StringBuffer();
  final mapEntries = StringBuffer();

  for (final jsonFile in jsonFiles) {
    final String original = jsonFile.uri.pathSegments.last;
    var base = original;
    if (base.endsWith('.json')) {
      base = base.substring(0, base.length - '.json'.length);
    }
    if (base.startsWith('~')) {
      base = base.substring(1);
    }
    final String dartName = base.replaceAll('-', '_');
    final String constName = dartName.toUpperCase();
    final String jsonText = await jsonFile.readAsString();

    final outFile = File(_join(testSpecsDir.path, '$dartName.dart'));
    await outFile.writeAsString(
      '// Generated from $original@$headHash at $utcNow\n'
      "const String $constName = r'''\n"
      '$jsonText'
      "''';\n",
    );

    exports.write("import '");
    exports.write(dartName);
    exports.writeln(".dart';");

    mapEntries.write("  '");
    mapEntries.write(dartName);
    mapEntries.writeln("': $constName,");
  }

  await File(_join(testSpecsDir.path, 'specs.dart')).writeAsString(
    '// Generated from mustache/spec@$headHash at $utcNow\n'
    '$exports\n'
    'const Map<String, String> SPECS = {\n'
    '$mapEntries'
    '};\n',
  );

  await Directory(tmpSpecPath).delete(recursive: true);
}

Directory _packageRootDirectory() {
  return File.fromUri(Platform.script).parent.parent;
}

String _formatUtcSecond(DateTime dt) {
  assert(dt.isUtc);
  String two(int n) => n.toString().padLeft(2, '0');
  final String y = dt.year.toString().padLeft(4, '0');
  return '$y-${two(dt.month)}-${two(dt.day)}T${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}Z';
}

String _join(String a, String b, [String? c]) {
  final String sep = Platform.pathSeparator;
  return [a, b, if (c != null) c].join(sep);
}

Future<ProcessResult> _runGit(
  String workingDirectory,
  List<String> arguments,
) async {
  final ProcessResult result = await Process.run(
    'git',
    arguments,
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  return result;
}
