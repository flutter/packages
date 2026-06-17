// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';

enum _MaterialVersion { material3, material3Expressive }

/// A template for generating Material 3 component defaults.
abstract class M3TokenTemplate extends TokenTemplate {
  const M3TokenTemplate();

  @override
  _MaterialVersion get _version => _MaterialVersion.material3;
}

/// A template for generating Material 3 Expressive component defaults.
abstract class M3ETokenTemplate extends TokenTemplate {
  const M3ETokenTemplate();

  @override
  _MaterialVersion get _version => _MaterialVersion.material3Expressive;
}

@visibleForTesting
abstract class TokenTemplate {
  const TokenTemplate();

  /// The copyright header prepended to all generated defaults files.
  static const String _copyrightHeader = '''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
''';

  /// The warning comment prepended to all generated defaults files informing
  /// readers not to edit them by hand.
  static const String _headerComment = '''

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
''';

  /// The regular expression used to verify that a template name is written with
  /// spaces and capitalized words (e.g., "Icon Button").
  static final RegExp _nameRegExp = RegExp(r'^[A-Z][a-zA-Z0-9]*( [A-Z][a-zA-Z0-9]*)*$');

  /// The name of the template, which corresponds to the target file name.
  /// E.g., 'Icon Button' for generating 'icon_button_m3_defaults.g.dart'.
  String get name;

  /// The path of the parent file relative to `lib/src`.
  /// E.g., 'icon_button.dart' or 'buttons/icon_button.dart'.
  String get parentFilePath;

  /// The path to the library's directory where generated files are placed.
  @visibleForTesting
  String get materialLib {
    const packagePath = 'packages/material_ui';
    const generatedDirectory = 'lib/src/generated';
    if (Directory(packagePath).existsSync()) {
      return '$packagePath/$generatedDirectory';
    }
    return generatedDirectory;
  }

  /// The Material version this template is for.
  _MaterialVersion get _version;

  /// The name of the class that will be generated (e.g. `_M3IconButtonDefaults`
  /// or `_M3EIconButtonDefaults`).
  String get _className {
    assert(
      _nameRegExp.hasMatch(name),
      'The template name "$name" must use spaces and capitalized words (e.g., "Typography" or "Icon Button").',
    );
    final String camelName = name.replaceAll(' ', '');
    return switch (_version) {
      _MaterialVersion.material3 => '_M3${camelName}Defaults',
      _MaterialVersion.material3Expressive => '_M3E${camelName}Defaults',
    };
  }

  /// The regular expression used to verify that the generated contents declare
  /// the class.
  RegExp get _classRegExp => RegExp('class\\s+$_className\\b');

  /// Returns the body of the generated file as a string.
  ///
  /// The [className] parameter must be used to declare the class.
  String generateContents(String className);

  /// Generates the file under the target path [materialLib] and formats it.
  void generateFile({bool verbose = false}) {
    final String snakeName = name.toLowerCase().replaceAll(' ', '_');
    final String outputFileName = switch (_version) {
      _MaterialVersion.material3 => '${snakeName}_m3_defaults.g.dart',
      _MaterialVersion.material3Expressive => '${snakeName}_m3e_defaults.g.dart',
    };
    final fileName = '$materialLib/$outputFileName';
    if (verbose) {
      stdout.writeln('Generating file: $fileName');
      stdout.writeln('Target parent file path: lib/src/$parentFilePath');
    }
    assert(
      !parentFilePath.startsWith('/') && !parentFilePath.startsWith('lib/'),
      'parentFilePath must be relative to lib/src/ (e.g. "icon_button.dart").',
    );
    final file = File(fileName);
    if (!file.existsSync()) {
      if (verbose) {
        stdout.writeln('File does not exist, creating it.');
      }
      file.createSync(recursive: true);
    }

    if (verbose) {
      stdout.writeln('Generating contents...');
    }
    final String contents = generateContents(_className);
    assert(
      contents.contains(_classRegExp),
      'The generated contents for "$name" must define the class "$_className". '
      'Make sure you are utilizing the passed `className` parameter.',
    );

    final buffer = StringBuffer();
    buffer.write(_copyrightHeader);
    buffer.write(_headerComment);
    buffer.write("part of '../$parentFilePath';\n\n");
    buffer.write(contents);

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
