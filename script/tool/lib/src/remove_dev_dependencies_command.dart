// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to remove dev_dependencies, which are not used by package clients.
///
/// This is intended for use with legacy Flutter version testing, to allow
/// running analysis (with --lib-only) with versions that are supported for
/// clients of the library, but not for development of the library.
class RemoveDevDependenciesCommand extends PackageLoopingCommand {
  /// Creates a publish metadata updater command instance.
  RemoveDevDependenciesCommand(super.packagesDir, {super.gitDir});

  static const String _dependenciesKey = 'dependencies';
  static const String _devDependenciesKey = 'dev_dependencies';
  static final RegExp _docImportStartPattern = RegExp(r'^\s*///\s*@docImport\b');
  static final RegExp _packageUriPattern = RegExp(r'''['"]package:([^/'"]+)/''');
  static final RegExp _bareLibraryDirectivePattern = RegExp(r'^\s*library\s*;(?:\s*//.*)?$');

  @override
  final String name = 'remove-dev-dependencies';

  @override
  final String description =
      'Removes any dev_dependencies section from a '
      'package, to allow more legacy testing.';

  @override
  bool get hasLongOutput => false;

  @override
  PackageLoopingType get packageLoopingType => PackageLoopingType.includeAllSubpackages;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    var changed = false;
    final editablePubspec = YamlEditor(package.pubspecFile.readAsStringSync());
    final root = editablePubspec.parseAt(<String>[]) as YamlMap;
    final Object? dependenciesNode = root[_dependenciesKey];
    final Set<String> dependencies = dependenciesNode is YamlMap
        ? dependenciesNode.keys.whereType<String>().toSet()
        : <String>{};
    final devDependencies = root[_devDependenciesKey] as YamlMap?;
    if (devDependencies != null) {
      final Set<String> docImportPackagesToRemove = devDependencies.keys
          .whereType<String>()
          .toSet()
          .difference(dependencies);
      changed = true;
      print('${indentation}Removed dev_dependencies');
      editablePubspec.remove(<String>[_devDependenciesKey]);
      package.pubspecFile.writeAsStringSync(editablePubspec.toString());
      if (docImportPackagesToRemove.isNotEmpty) {
        _removeDocImports(package, docImportPackagesToRemove);
      }
    }

    return changed ? PackageResult.success() : PackageResult.skip('Nothing to remove.');
  }

  void _removeDocImports(RepositoryPackage package, Set<String> removedPackages) {
    if (!package.libDirectory.existsSync()) {
      return;
    }
    for (final FileSystemEntity entity in package.libDirectory.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        _stripDocImportsFromFile(entity, removedPackages);
      }
    }
  }

  void _stripDocImportsFromFile(File file, Set<String> removedPackages) {
    final String content = file.readAsStringSync();
    final lineEnding = content.contains('\r\n') ? '\r\n' : '\n';
    final List<String> lines = content.split(lineEnding);
    final updatedLines = <String>[];
    var modified = false;
    var strippedDocImport = false;
    var i = 0;
    while (i < lines.length) {
      final String line = lines[i];
      if (_docImportStartPattern.hasMatch(line)) {
        final directiveLines = <String>[line];
        var j = i;
        while (!lines[j].contains(';') &&
            j + 1 < lines.length &&
            lines[j + 1].trimLeft().startsWith('///')) {
          j++;
          directiveLines.add(lines[j]);
        }
        final String directiveText = directiveLines.join(' ');
        final RegExpMatch? match = _packageUriPattern.firstMatch(directiveText);
        final String? packageName = match?.group(1);
        if (packageName != null && removedPackages.contains(packageName)) {
          modified = true;
          strippedDocImport = true;
          i = j + 1;
          continue;
        }
        updatedLines.addAll(directiveLines);
        i = j + 1;
        continue;
      }
      if (strippedDocImport && _bareLibraryDirectivePattern.hasMatch(line)) {
        final bool hasPrecedingDocOrAnnotation =
            updatedLines.isNotEmpty &&
            (updatedLines.last.trimLeft().startsWith('///') ||
                updatedLines.last.trimLeft().startsWith('@'));
        strippedDocImport = false;
        if (!hasPrecedingDocOrAnnotation) {
          // A bare `library;` that lost all preceding @docImport directives fails
          // `unnecessary_library_directive`, so drop it as well.
          if ((updatedLines.isEmpty || updatedLines.last.trim().isEmpty) &&
              i + 1 < lines.length &&
              lines[i + 1].trim().isEmpty) {
            i += 2;
            continue;
          }
          i++;
          continue;
        }
      } else if (line.trim().isNotEmpty && !line.trimLeft().startsWith('@')) {
        strippedDocImport = false;
      }
      updatedLines.add(line);
      i++;
    }
    if (modified) {
      file.writeAsStringSync(updatedLines.join(lineEnding));
    }
  }
}
