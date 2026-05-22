// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

abstract class TokenTemplate {
  const TokenTemplate();

  /// The name of the template, which corresponds to the target file name.
  /// E.g., 'typography' for generating 'typography_defaults.g.dart'.
  String get name;

  static const String copyrightHeader = '''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
''';

  static const String headerComment = '''

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/m3e_gen_defaults/bin/gen_defaults.dart.

// dart format off
''';

  static const String footerComment = '''
// dart format on
''';

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
    buffer.write("part of '../$parentName';\n\n");
    buffer.write(generateContents());
    buffer.write(footerComment);

    if (verbose) {
      stdout.writeln('Writing generated contents to $fileName...');
    }
    file.writeAsStringSync(buffer.toString());
    if (verbose) {
      stdout.writeln('Done generating $fileName.');
    }
  }

  String get materialLib {
    const packagePath = 'packages/material_ui';
    const relativeOutputPath = 'lib/src/m3e/generated';
    if (Directory(packagePath).existsSync()) {
      return '$packagePath/$relativeOutputPath';
    }
    return relativeOutputPath;
  }
}
