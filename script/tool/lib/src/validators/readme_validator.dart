// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../common/file_utils.dart';
import '../common/output_utils.dart';
import '../common/repository_package.dart';

// Standardized capitalizations for platforms that a plugin can support.
const Map<String, String> _standardPlatformNames = <String, String>{
  'android': 'Android',
  'ios': 'iOS',
  'linux': 'Linux',
  'macos': 'macOS',
  'web': 'Web',
  'windows': 'Windows',
};

const String _instructionUrl =
    'https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md';

/// Validates that READMEs follow repository conventions.
class ReadmeValidator {
  /// Creates a new instance of the validator with the given command context.
  ReadmeValidator({
    required path.Context path,
    required String indentation,
    required void Function(String) warningLogger,
    required bool requireCodeExcerpts,
  }) : _path = path,
       _indentation = indentation,
       _logWarning = warningLogger,
       _requireCodeExcerpts = requireCodeExcerpts;

  final path.Context _path;
  final String _indentation;
  final void Function(String) _logWarning;
  final bool _requireCodeExcerpts;

  /// Validates the given README file, returning a list of resulting error
  /// strings.
  ///
  /// If no errors are found, an empty list is returned.
  List<String> validateReadme(
    File readme, {
    required RepositoryPackage mainPackage,
    required bool isExample,
  }) {
    if (!readme.existsSync()) {
      if (isExample) {
        print(
          '${_indentation}No README for '
          '${relativePosixPath(readme.parent, from: mainPackage.directory, platformContext: _path)}',
        );
        return <String>[];
      } else {
        printError(
          '${_indentation}No README found at '
          '${relativePosixPath(readme, from: mainPackage.directory, platformContext: _path)}',
        );
        return <String>['Missing README.md'];
      }
    }

    print(
      '${_indentation}Checking '
      '${relativePosixPath(readme, from: mainPackage.directory, platformContext: _path)}...',
    );

    final List<String> readmeLines = readme.readAsLinesSync();
    final errors = <String>[];

    final String? blockValidationError = _validateCodeBlocks(
      readmeLines,
      mainPackage: mainPackage,
    );
    if (blockValidationError != null) {
      errors.add(blockValidationError);
    }

    errors.addAll(
      _validateBoilerplate(
        readmeLines,
        mainPackage: mainPackage,
        isExample: isExample,
      ),
    );

    // Check if this is the main readme for a plugin, and if so enforce extra
    // checks.
    if (!isExample) {
      final Pubspec pubspec = mainPackage.parsePubspec();
      final isPlugin = pubspec.flutter?['plugin'] != null;
      if (isPlugin && (!mainPackage.isFederated || mainPackage.isAppFacing)) {
        final String? error = _validateSupportedPlatforms(readmeLines, pubspec);
        if (error != null) {
          errors.add(error);
        }
      }
    }

    return errors;
  }

  /// Validates that code blocks (``` ... ```) follow repository standards.
  String? _validateCodeBlocks(
    List<String> readmeLines, {
    required RepositoryPackage mainPackage,
  }) {
    final codeBlockDelimiterPattern = RegExp(r'^\s*```\s*([^ ]*)\s*');
    const excerptTagStart = '<?code-excerpt ';
    final missingLanguageLines = <int>[];
    final missingExcerptLines = <int>[];
    var inBlock = false;
    for (var i = 0; i < readmeLines.length; ++i) {
      final RegExpMatch? match = codeBlockDelimiterPattern.firstMatch(
        readmeLines[i],
      );
      if (match == null) {
        continue;
      }
      if (inBlock) {
        inBlock = false;
        continue;
      }
      inBlock = true;

      final int humanReadableLineNumber = i + 1;

      // Ensure that there's a language tag.
      final String infoString = match[1] ?? '';
      if (infoString.isEmpty) {
        missingLanguageLines.add(humanReadableLineNumber);
        continue;
      }

      // Check for code-excerpt usage if requested.
      if (_requireCodeExcerpts && infoString == 'dart') {
        if (i == 0 || !readmeLines[i - 1].trim().startsWith(excerptTagStart)) {
          missingExcerptLines.add(humanReadableLineNumber);
        }
      }
    }

    String? errorSummary;

    if (missingLanguageLines.isNotEmpty) {
      for (final lineNumber in missingLanguageLines) {
        printError(
          '${_indentation}Code block at line $lineNumber is missing '
          'a language identifier.',
        );
      }
      printError(
        '\n${_indentation}For each block listed above, add a language tag to '
        'the opening block. For instance, for Dart code, use:\n'
        '${_indentation * 2}```dart\n',
      );
      errorSummary = 'Missing language identifier for code block';
    }

    if (missingExcerptLines.isNotEmpty) {
      for (final lineNumber in missingExcerptLines) {
        printError(
          '${_indentation}Dart code block at line $lineNumber is not '
          'managed by code-excerpt.',
        );
      }
      printError(
        '\n${_indentation}For each block listed above, add <?code-excerpt ...> '
        'tag on the previous line, as explained at\n'
        '$_instructionUrl',
      );
      errorSummary ??= 'Missing code-excerpt management for code block';
    }

    return errorSummary;
  }

  /// Validates that the plugin has a supported platforms table following the
  /// expected format, returning an error string if any issues are found.
  String? _validateSupportedPlatforms(
    List<String> readmeLines,
    Pubspec pubspec,
  ) {
    // Example table following expected format:
    // |                | Android | iOS      | Web                    |
    // |----------------|---------|----------|------------------------|
    // | **Support**    | SDK 21+ | iOS 10+* | [See `camera_web `][1] |
    final int detailsLineNumber = readmeLines.indexWhere(
      (String line) => line.startsWith('| **Support**'),
    );
    if (detailsLineNumber == -1) {
      return 'No OS support table found';
    }
    final int osLineNumber = detailsLineNumber - 2;
    if (osLineNumber < 0 || !readmeLines[osLineNumber].startsWith('|')) {
      return 'OS support table does not have the expected header format';
    }

    // Utility method to convert an iterable of strings to a case-insensitive
    // sorted, comma-separated string of its elements.
    String sortedListString(Iterable<String> entries) {
      final List<String> entryList = entries.toList();
      entryList.sort(
        (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()),
      );
      return entryList.join(', ');
    }

    // Validate that the supported OS lists match.
    final pluginSection = pubspec.flutter!['plugin'] as YamlMap;
    final dynamic platformsEntry = pluginSection['platforms'];
    if (platformsEntry == null) {
      _logWarning('Plugin not support any platforms');
      return null;
    }
    final platformSupportMaps = platformsEntry as YamlMap;
    final Set<String> actuallySupportedPlatform = platformSupportMaps.keys
        .toSet()
        .cast<String>();
    final Iterable<String> documentedPlatforms = readmeLines[osLineNumber]
        .split('|')
        .map((String entry) => entry.trim())
        .where((String entry) => entry.isNotEmpty);
    final Set<String> documentedPlatformsLowercase = documentedPlatforms
        .map((String entry) => entry.toLowerCase())
        .toSet();
    if (actuallySupportedPlatform.length != documentedPlatforms.length ||
        actuallySupportedPlatform
                .intersection(documentedPlatformsLowercase)
                .length !=
            actuallySupportedPlatform.length) {
      printError('''
${_indentation}OS support table does not match supported platforms:
${_indentation * 2}Actual:     ${sortedListString(actuallySupportedPlatform)}
${_indentation * 2}Documented: ${sortedListString(documentedPlatformsLowercase)}
''');
      return 'Incorrect OS support table';
    }

    // Enforce a standard set of capitalizations for the OS headings.
    final Iterable<String> incorrectCapitalizations = documentedPlatforms
        .toSet()
        .difference(_standardPlatformNames.values.toSet());
    if (incorrectCapitalizations.isNotEmpty) {
      final Iterable<String> expectedVersions = incorrectCapitalizations.map(
        (String name) => _standardPlatformNames[name.toLowerCase()]!,
      );
      printError('''
${_indentation}Incorrect OS capitalization: ${sortedListString(incorrectCapitalizations)}
${_indentation * 2}Please use standard capitalizations: ${sortedListString(expectedVersions)}
''');
      return 'Incorrect OS support formatting';
    }

    // TODO(stuartmorgan): Add validation that the minimums in the table are
    // consistent with what the current implementations require. See
    // https://github.com/flutter/flutter/issues/84200
    return null;
  }

  /// Validates [readmeLines], outputing error messages for any issue and
  /// returning an array of error summaries (if any).
  ///
  /// Returns an empty array if validation passes.
  List<String> _validateBoilerplate(
    List<String> readmeLines, {
    required RepositoryPackage mainPackage,
    required bool isExample,
  }) {
    final errors = <String>[];

    if (_containsTemplateFlutterBoilerplate(readmeLines)) {
      printError(
        '${_indentation}The boilerplate section about getting started '
        'with Flutter should not be left in.',
      );
      errors.add('Contains template boilerplate');
    }

    // Enforce a repository-standard message in implementation plugin examples,
    // since they aren't typical examples, which has been a source of
    // confusion for plugin clients who find them.
    if (isExample && mainPackage.isPlatformImplementation) {
      if (_containsExampleBoilerplate(readmeLines)) {
        printError(
          '${_indentation}The boilerplate should not be left in for a '
          "federated plugin implementation package's example.",
        );
        errors.add('Contains template boilerplate');
      }
      if (!_containsImplementationExampleExplanation(readmeLines)) {
        printError(
          '${_indentation}The example README for a platform '
          'implementation package should warn readers about its intended '
          'use. Please copy the example README from another implementation '
          'package in this repository.',
        );
        errors.add('Missing implementation package example warning');
      }
    }

    return errors;
  }

  /// Returns true if the README still has unwanted parts of the boilerplate
  /// from the `flutter create` templates.
  bool _containsTemplateFlutterBoilerplate(List<String> readmeLines) {
    return readmeLines.any(
      (String line) => line.contains('For help getting started with Flutter'),
    );
  }

  /// Returns true if the README still has the generic description of an
  /// example from the `flutter create` templates.
  bool _containsExampleBoilerplate(List<String> readmeLines) {
    return readmeLines.any(
      (String line) => line.contains('Demonstrates how to use the'),
    );
  }

  /// Returns true if the README contains the repository-standard explanation of
  /// the purpose of a federated plugin implementation's example.
  bool _containsImplementationExampleExplanation(List<String> readmeLines) {
    return (readmeLines.contains('# Platform Implementation Test App') &&
            readmeLines.any(
              (String line) => line.contains('This is a test app for'),
            )) ||
        (readmeLines.contains('# Platform Implementation Test Apps') &&
            readmeLines.any(
              (String line) => line.contains('These are test apps for'),
            ));
  }
}
