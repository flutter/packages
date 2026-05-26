// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';

enum _MaterialVersion { material3, material3Expressive }

abstract class M3TokenTemplate extends _TokenTemplate {
  const M3TokenTemplate();

  @override
  _MaterialVersion get _version => _MaterialVersion.material3;
}

abstract class M3ETokenTemplate extends _TokenTemplate {
  const M3ETokenTemplate();

  @override
  _MaterialVersion get _version => _MaterialVersion.material3Expressive;
}

abstract class _TokenTemplate {
  const _TokenTemplate();

  static const String copyrightHeader = '''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
''';

  static const String headerComment = '''

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
''';

  /// The Material version this template is for.
  _MaterialVersion get _version;

  /// The name of the template, which corresponds to the target file name.
  /// E.g., 'typography' for generating 'typography_defaults.g.dart'.
  String get name;

  @visibleForTesting
  String get materialLib {
    const packagePath = 'packages/material_ui';
    const generatedDirectory = 'lib/src/generated';
    final String relativeOutputPath = switch (_version) {
      _MaterialVersion.material3 => generatedDirectory,
      _MaterialVersion.material3Expressive => '$generatedDirectory/material_3_expressive',
    };
    if (Directory(packagePath).existsSync()) {
      return '$packagePath/$relativeOutputPath';
    }
    return relativeOutputPath;
  }

  String generateContents();

  void generateFile({bool verbose = false}) {
    final fileName = '$materialLib/${name}_defaults.g.dart';
    if (verbose) {
      stdout.writeln('Generating file: $fileName');
      stdout.writeln('Target parent file name: $name.dart');
    }
    final file = File(fileName);
    if (!file.existsSync()) {
      if (verbose) {
        stdout.writeln('File does not exist, creating it.');
      }
      file.createSync(recursive: true);
    }

    final parentName = '$name.dart';

    if (verbose) {
      stdout.writeln('Generating contents...');
    }
    final buffer = StringBuffer();
    buffer.write(copyrightHeader);
    buffer.write(headerComment);
    final String partOfPath = switch (_version) {
      _MaterialVersion.material3 => '../$parentName',
      _MaterialVersion.material3Expressive => '../../material_3_expressive/$parentName',
    };
    buffer.write("part of '$partOfPath';\n\n");
    buffer.write(generateContents());

    if (verbose) {
      stdout.writeln('Writing generated contents to $fileName...');
    }
    file.writeAsStringSync(buffer.toString());
    if (verbose) {
      stdout.writeln('Formatting $fileName...');
    }
    final ProcessResult result = Process.runSync(Platform.resolvedExecutable, <String>[
      'format',
      fileName,
    ]);
    if (result.exitCode != 0) {
      stderr.writeln('Failed to format $fileName: ${result.stderr}');
    }
    if (verbose) {
      stdout.writeln('Done generating $fileName.');
    }
  }
}
