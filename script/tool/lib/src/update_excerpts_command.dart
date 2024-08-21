// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

class _UpdateResult {
  const _UpdateResult(this.changed, this.snippetCount, this.errors);
  final bool changed;
  final int snippetCount;
  final List<String> errors;
}

enum _ExcerptParseMode { normal, pragma, injecting }

/// A command to update .md code excerpts from code files.
class UpdateExcerptsCommand extends PackageLoopingCommand {
  /// Creates a excerpt updater command instance.
  UpdateExcerptsCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    argParser.addFlag(
      _failOnChangeFlag,
      help: 'Fail if the command does anything. '
          '(Used in CI to ensure excerpts are up to date.)',
    );
  }

  static const String _failOnChangeFlag = 'fail-on-change';

  @override
  final String name = 'update-excerpts';

  @override
  final String description = 'Updates code excerpts in .md files, based '
      'on code from code files, via <?code-excerpt?> pragmas.';

  @override
  bool get hasLongOutput => false;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final List<File> changedFiles = <File>[];
    final List<String> errors = <String>[];
    final List<File> markdownFiles = package.directory
        .listSync(recursive: true)
        .where((FileSystemEntity entity) {
          return entity is File &&
              entity.basename != 'CHANGELOG.md' &&
              entity.basename.toLowerCase().endsWith('.md');
        })
        .cast<File>()
        .toList();
    for (final File file in markdownFiles) {
      final _UpdateResult result = _updateExcerptsIn(file);
      if (result.snippetCount > 0) {
        final String displayPath =
            getRelativePosixPath(file, from: package.directory);
        print('${indentation}Checked ${result.snippetCount} snippet(s) in '
            '$displayPath.');
      }
      if (result.changed) {
        changedFiles.add(file);
      }
      if (result.errors.isNotEmpty) {
        errors.addAll(result.errors);
      }
    }

    if (errors.isNotEmpty) {
      printError('${indentation}Injecting excerpts failed:');
      printError(errors.join('\n$indentation'));
      return PackageResult.fail();
    }

    if (getBoolArg(_failOnChangeFlag) && changedFiles.isNotEmpty) {
      printError(
        '${indentation}The following files have out of date excerpts:\n'
        '$indentation  ${changedFiles.map((File file) => file.path).join("\n$indentation  ")}\n'
        '\n'
        '${indentation}If you edited code in a .md file directly, you should '
        'instead edit the files that contain the sources of the excerpts.\n'
        '${indentation}If you did edit those source files, run the repository '
        'tooling\'s "$name" command on this package, and update your PR with '
        'the resulting changes.\n'
        '\n'
        '${indentation}For more information, see '
        'https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#readme-code',
      );
      return PackageResult.fail();
    }

    return PackageResult.success();
  }

  static const String _pragma = '<?code-excerpt';
  static final RegExp _basePattern =
      RegExp(r'^ *<\?code-excerpt path-base="([^"]+)"\?>$');
  static final RegExp _injectPattern = RegExp(
    r'^ *<\?code-excerpt "(?<path>[^ ]+) \((?<section>[^)]+)\)"(?: plaster="(?<plaster>[^"]*)")?\?>$',
  );

  _UpdateResult _updateExcerptsIn(File file) {
    bool detectedChange = false;
    int snippetCount = 0;
    final List<String> errors = <String>[];
    Directory pathBase = file.parent;
    final StringBuffer output = StringBuffer();
    final StringBuffer existingBlock = StringBuffer();
    String? language;
    String? excerpt;
    _ExcerptParseMode mode = _ExcerptParseMode.normal;
    int lineNumber = 0;
    for (final String line in file.readAsLinesSync()) {
      lineNumber += 1;
      switch (mode) {
        case _ExcerptParseMode.normal:
          if (line.contains(_pragma)) {
            RegExpMatch? match = _basePattern.firstMatch(line);
            if (match != null) {
              pathBase =
                  file.parent.childDirectory(path.normalize(match.group(1)!));
            } else {
              match = _injectPattern.firstMatch(line);
              if (match != null) {
                snippetCount++;
                final String excerptPath =
                    path.normalize(match.namedGroup('path')!);
                final File excerptSourceFile = pathBase.childFile(excerptPath);
                final String extension = path.extension(excerptSourceFile.path);
                switch (extension) {
                  case '':
                    language = 'txt';
                  case '.kt':
                    language = 'kotlin';
                  case '.cc':
                  case '.cpp':
                    language = 'c++';
                  case '.m':
                    language = 'objectivec';
                  case '.gradle':
                    language = 'groovy';
                  default:
                    language = extension.substring(1);
                }
                final String section = match.namedGroup('section')!;
                final String plaster = match.namedGroup('plaster') ?? '···';
                if (!excerptSourceFile.existsSync()) {
                  errors.add(
                      '${file.path}:$lineNumber: specified file "$excerptPath" (resolved to "${excerptSourceFile.path}") does not exist');
                } else {
                  excerpt = _extractExcerpt(
                      excerptSourceFile, section, plaster, language, errors);
                }
                mode = _ExcerptParseMode.pragma;
              } else {
                errors.add(
                    '${file.path}:$lineNumber: $_pragma?> pragma does not match expected syntax or is not alone on the line');
              }
            }
          }
          output.writeln(line);
        case _ExcerptParseMode.pragma:
          if (!line.startsWith('```')) {
            errors.add(
                '${file.path}:$lineNumber: expected code block but did not find one');
            mode = _ExcerptParseMode.normal;
          } else {
            if (line.startsWith('``` ')) {
              errors.add(
                  '${file.path}:$lineNumber: code block was followed by a space character instead of the language (expected "$language")');
              mode = _ExcerptParseMode.injecting;
            } else if (line != '```$language' &&
                line != '```rfwtxt' &&
                line != '```json') {
              // We special-case rfwtxt and json because the rfw package extracts such sections from Dart files.
              // If we get more special cases we should think about a more general solution.
              errors.add(
                  '${file.path}:$lineNumber: code block has wrong language');
            }
            mode = _ExcerptParseMode.injecting;
          }
          output.writeln(line);
        case _ExcerptParseMode.injecting:
          if (line == '```') {
            if (existingBlock.toString() != excerpt) {
              detectedChange = true;
            }
            output.write(excerpt);
            output.writeln(line);
            mode = _ExcerptParseMode.normal;
            language = null;
            excerpt = null;
            existingBlock.clear();
          } else {
            existingBlock.writeln(line);
          }
      }
    }
    if (detectedChange) {
      if (errors.isNotEmpty) {
        errors.add('${file.path}: skipped updating file due to errors');
      } else {
        try {
          file.writeAsStringSync(output.toString());
        } catch (e) {
          errors.add(
              '${file.path}: failed to update file (${e.runtimeType}: $e)');
        }
      }
    }
    return _UpdateResult(detectedChange, snippetCount, errors);
  }

  String _extractExcerpt(File excerptSourceFile, String section,
      String plasterInside, String language, List<String> errors) {
    final List<String> buffer = <String>[];
    bool extracting = false;
    int lineNumber = 0;
    int maxLength = 0;
    bool found = false;
    String prefix = '';
    String suffix = '';
    String padding = '';
    switch (language) {
      case 'cc':
      case 'c++':
      case 'dart':
      case 'js':
      case 'kotlin':
      case 'rfwtxt':
      case 'java':
      case 'groovy':
      case 'objectivec':
      case 'swift':
        prefix = '// ';
      case 'css':
        prefix = '/* ';
        suffix = ' */';
      case 'html':
      case 'xml':
        prefix = '<!--';
        suffix = '-->';
        padding = ' ';
      case 'yaml':
        prefix = '# ';
      case 'sh':
        prefix = '# ';
    }
    final String startRegionMarker = '$prefix#docregion $section$suffix';
    final String endRegionMarker = '$prefix#enddocregion $section$suffix';
    final String plaster = '$prefix$padding$plasterInside$padding$suffix';
    int? indentation;
    for (final String excerptLine in excerptSourceFile.readAsLinesSync()) {
      final String trimmedLine = excerptLine.trimLeft();
      lineNumber += 1;
      if (extracting) {
        if (trimmedLine == endRegionMarker) {
          extracting = false;
          indentation = excerptLine.length - trimmedLine.length;
        } else {
          if (trimmedLine == startRegionMarker) {
            errors.add(
                '${excerptSourceFile.path}:$lineNumber: saw "$startRegionMarker" pragma while already in a "$section" doc region');
          }
          if (excerptLine.length > maxLength) {
            maxLength = excerptLine.length;
          }
          if (!excerptLine.contains('$prefix#docregion ') &&
              !excerptLine.contains('$prefix#enddocregion ')) {
            buffer.add(excerptLine);
          }
        }
      } else {
        if (trimmedLine == startRegionMarker) {
          found = true;
          extracting = true;
          if (buffer.isNotEmpty && plasterInside != 'none') {
            assert(indentation != null);
            buffer.add('${" " * indentation!}$plaster');
            indentation = null;
          }
        }
      }
    }
    if (extracting) {
      errors
          .add('${excerptSourceFile.path}: missing "$endRegionMarker" pragma');
    }
    if (!found) {
      errors.add(
          '${excerptSourceFile.path}: did not find a "$startRegionMarker" pragma');
      return '';
    }
    if (buffer.isEmpty) {
      errors.add('${excerptSourceFile.path}: region "$section" is empty');
      return '';
    }
    int indent = maxLength;
    for (final String line in buffer) {
      if (indent == 0) {
        break;
      }
      if (line.isEmpty) {
        continue;
      }
      for (int index = 0; index < line.length; index += 1) {
        if (line[index] != ' ') {
          if (index < indent) {
            indent = index;
          }
        }
      }
    }
    final StringBuffer excerpt = StringBuffer();
    for (final String line in buffer) {
      if (line.isEmpty) {
        excerpt.writeln();
      } else {
        excerpt.writeln(line.substring(indent));
      }
    }
    return excerpt.toString();
  }
}
