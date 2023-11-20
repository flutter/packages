// Copyright 2023 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'common/package_command.dart';

// TODO(devoncarew): figure out how to test this

/// Update the main analysis_options.yaml file using the latest set of lints
/// from package:dart_flutter_team_lints/analysis_options.yaml.
class UpdateAnalysisOptionsCommand extends PackageCommand {
  /// Creates an instance of the update-analysis-options command.
  UpdateAnalysisOptionsCommand(super.packagesDir);

  @override
  final String name = 'update-analysis-options';

  @override
  final String description =
      'Update the main analysis_options.yaml file using the latest set of '
      'lints from package:dart_flutter_team_lints/analysis_options.yaml.';

  @override
  Future<void> run() async {
    final FileSystem fileSystem = packagesDir.fileSystem;
    final Directory rootDir = packagesDir.parent;
    final File optionsFile = rootDir.childFile('analysis_options.yaml');

    print('Updating ${optionsFile.basename}:');

    final Directory toolDir =
        rootDir.childDirectory('script').childDirectory('tool');
    final Map<String, Directory> packages = _findPackageConfig(toolDir)!;

    final _Lints lints = _Lints.readFrom(
      'package:dart_flutter_team_lints/analysis_options.yaml',
      packages,
      fileSystem: fileSystem,
    );

    void printLints(_Lints lints) {
      if (lints.parent != null) {
        printLints(lints.parent!);
      }
      print('  ${lints.include} [${lints.lints.length} lints]');
    }

    printLints(lints);

    final StringBuffer out = StringBuffer();
    final List<String> optionsAsList = optionsFile.readAsLinesSync();

    // copy over the preamble, up to '  rules:'
    int index = 0;
    while (optionsAsList[index] != '  rules:') {
      out.writeln(optionsAsList[index]);
      index++;
    }
    out.writeln(optionsAsList[index]);

    // copy the included lints
    void copyLints(_Lints lints) {
      if (lints.parent != null) {
        copyLints(lints.parent!);
      }
      out.writeln('    # ${lints.include} [${lints.lints.length} lints]');
      for (final String lint in lints.lints) {
        optionsAsList.remove('    - $lint');
        final int location = optionsAsList
            .indexWhere((String line) => line.startsWith('    # - $lint'));
        final String line =
            location == -1 ? '    - $lint' : optionsAsList.removeAt(location);
        out.writeln(line);
      }
      out.writeln();
    }

    copyLints(lints);

    // copy the additional customization, from '    # Additional customizations'
    int location = optionsAsList.indexWhere(
        (String line) => line.contains('# Additional customizations'));

    while (location < optionsAsList.length) {
      out.writeln(optionsAsList[location]);
      location++;
    }

    // update the original file
    optionsFile.writeAsStringSync(out.toString());
    print('Wrote update lints to ${optionsFile.path}');
  }
}

Map<String, Directory>? _findPackageConfig(Directory dir) {
  final File configFile =
      dir.childDirectory('.dart_tool').childFile('package_config.json');
  if (configFile.existsSync()) {
    return _parseConfigFile(configFile);
  } else {
    return null;
  }
}

Map<String, Directory>? _parseConfigFile(File configFile) {
  final Map<String, dynamic> json =
      jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
  final List<Map<String, dynamic>> packages =
      (json['packages'] as List<dynamic>).cast<Map<String, dynamic>>();

  return Map<String, Directory>.fromIterable(
    packages,
    key: (dynamic package) =>
        (package as Map<String, dynamic>)['name'] as String,
    value: (dynamic package) {
      final String rootUri =
          (package as Map<String, dynamic>)['rootUri'] as String;
      final String filePath = Uri.parse(rootUri).toFilePath();
      if (p.isRelative(filePath)) {
        return configFile.fileSystem
            .directory(p.normalize(p.join(configFile.parent.path, filePath)));
      } else {
        return configFile.fileSystem.directory(filePath);
      }
    },
  );
}

class _Lints {
  _Lints._({
    this.parent,
    required this.include,
    required this.lints,
  });

  static _Lints readFrom(
    String include,
    Map<String, Directory> packages, {
    required FileSystem fileSystem,
  }) {
    // "package:lints/recommended.yaml"
    final Uri uri = Uri.parse(include);
    final String package = uri.pathSegments[0];
    final String filePath = uri.pathSegments[1];

    final Directory dir = packages[package]!;
    final File configFile = fileSystem.file(p.join(dir.path, 'lib', filePath));

    final YamlMap yaml = loadYaml(configFile.readAsStringSync()) as YamlMap;
    final String? localInclude = yaml['include'] as String?;
    final YamlList lints = (yaml['linter'] as YamlMap?)?['rules'] as YamlList;

    return _Lints._(
      parent: localInclude == null
          ? null
          : _Lints.readFrom(localInclude, packages, fileSystem: fileSystem),
      include: include,
      lints: lints.cast<String>().toList()..sort(),
    );
  }

  final _Lints? parent;
  final String include;
  final List<String> lints;
}
