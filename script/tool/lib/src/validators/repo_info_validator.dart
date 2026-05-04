// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:yaml/yaml.dart';

import '../common/core.dart';
import '../common/output_utils.dart';
import '../common/repository_package.dart';

const int _exitBadTableEntry = 3;
const int _exitUnknownPackageEntry = 4;

/// Validates that a package has all of the expected repository-level entries.
class RepoInfoValidator {
  /// Creates a new instance of the validator with the given command context.
  RepoInfoValidator({
    required Map<String, List<String>> readmeTableEntries,
    required Set<String> autoLabeledPackages,
    required GitDir gitDir,
    required String indentation,
  }) : _readmeTableEntries = readmeTableEntries,
       _autoLabeledPackages = autoLabeledPackages,
       _gitDir = gitDir,
       _indentation = indentation;

  final Map<String, List<String>> _readmeTableEntries;
  final Set<String> _autoLabeledPackages;
  final GitDir _gitDir;
  final String _indentation;

  /// Returns all the data from the package table in the root README.md file.
  ///
  /// Throws a [ToolExit] if the table is malformed or contains unknown packages.
  static Map<String, List<String>> loadReadmeTableEntries({
    required Directory repoRoot,
    required Directory packagesDir,
    required Directory thirdPartyPackagesDir,
  }) {
    final entries = <String, List<String>>{};
    final namePattern = RegExp(r'\[(.*?)\]\(');
    for (final String line
        in repoRoot.childFile('README.md').readAsLinesSync()) {
      // Find all the table entries, skipping the header.
      if (line.startsWith('|') &&
          !line.startsWith('| Package') &&
          !line.startsWith('|-')) {
        final List<String> cells = line
            .split('|')
            .map((String s) => s.trim())
            .where((String s) => s.isNotEmpty)
            .toList();
        // Extract the name, removing any markdown escaping.
        final String? name = namePattern
            .firstMatch(cells[0])
            ?.group(1)
            ?.replaceAll(r'\_', '_');
        if (name == null) {
          printError('Unexpected README table line:\n  $line');
          throw ToolExit(_exitBadTableEntry);
        }
        entries[name] = cells;

        if (!(packagesDir.childDirectory(name).existsSync() ||
            thirdPartyPackagesDir.childDirectory(name).existsSync())) {
          printError('Unknown package "$name" in root README.md table.');
          throw ToolExit(_exitUnknownPackageEntry);
        }
      }
    }
    return entries;
  }

  /// Returns all of the package names from the labeler.yml file.
  static Set<String> loadAutoLabeledPackages({required Directory repoRoot}) {
    final entries = <String>{};
    // Validate the match rules rather than the label itself, as the labels
    // don't always correspond 1:1 to packages and package names.
    final packageGlobPattern = RegExp(
      r'^\s*-\s*(?:third_party/)?packages/([^*]*)/',
    );
    for (final String line
        in repoRoot
            .childDirectory('.github')
            .childFile('labeler.yml')
            .readAsLinesSync()) {
      final RegExpMatch? match = packageGlobPattern.firstMatch(line);
      if (match == null) {
        continue;
      }
      final String name = match.group(1)!;
      entries.add(name);
    }
    return entries;
  }

  /// Validates that the repository information for a package is correct,
  /// returning a list of resulting error strings.
  ///
  /// If no errors are found, an empty list is returned.
  Future<List<String>> validatePackage(RepositoryPackage package) async {
    final String packageName = package.directory.basename;
    final errors = <String>[];

    // All packages should have an auto-applied label. For plugins, only the
    // group needs a rule, so check the app-facing package.
    if (!(package.isFederated && !package.isAppFacing) &&
        !_autoLabeledPackages.contains(packageName)) {
      printError('${_indentation}Missing a rule in .github/labeler.yml.');
      errors.add('Missing auto-labeler entry');
    }

    // The content of ci_config.yaml must be valid if there is one.
    try {
      package.parseCIConfig();
    } on FormatException catch (e) {
      printError('$_indentation${e.message}');
      errors.add(e.message);
    }

    errors.addAll(await _validateFilesBasedOnReleaseStrategy(package));

    // All published packages should have a README.md entry.
    if (package.isPublishable()) {
      errors.addAll(_validateRootReadme(package));
    }

    return errors;
  }

  List<String> _validateRootReadme(RepositoryPackage package) {
    final errors = <String>[];

    // For federated plugins, only the app-facing package is listed.
    if (package.isFederated && !package.isAppFacing) {
      return errors;
    }

    final String packageName = package.directory.basename;
    final List<String>? cells = _readmeTableEntries[packageName];
    if (cells == null) {
      printError('${_indentation}Missing repo root README.md table entry');
      errors.add('Missing repo root README.md table entry');
    } else {
      // Extract the two parts of a "[label](link)" .md link.
      final mdLinkPattern = RegExp(r'^\[(.*)\]\((.*)\)$');
      // Possible link targets.
      for (final String cell in cells) {
        final RegExpMatch? match = mdLinkPattern.firstMatch(cell);
        if (match == null) {
          printError(
            '${_indentation}Invalid repo root README.md table entry: "$cell"',
          );
          errors.add('Invalid root README.md table entry');
        } else {
          final String encodedIssueTag = Uri.encodeComponent(
            _issueTagForPackage(packageName),
          );
          final String encodedPRTag = Uri.encodeComponent(
            _prTagForPackage(packageName),
          );
          final String anchor = match.group(1)!;
          final String target = match.group(2)!;

          // The anchor should be one of:
          // - The package name (optionally with any underscores escaped)
          // - An image with a name-based link
          // - An image with a tag-based link
          final packageLink = RegExp(
            r'^!\[.*\]\(https://img.shields.io/pub/.*/'
            '$packageName'
            r'(?:\.svg)?\)$',
          );
          final issueTagLink = RegExp(
            r'^!\[.*\]\(https://img.shields.io/github/issues/flutter/flutter/'
            '$encodedIssueTag'
            r'\?label=\)$',
          );
          final prTagLink = RegExp(
            r'^!\[.*\]\(https://img.shields.io/github/issues-pr/flutter/packages/'
            '$encodedPRTag'
            r'\?label=\)$',
          );
          if (!(anchor == packageName ||
              anchor == packageName.replaceAll('_', r'\_') ||
              packageLink.hasMatch(anchor) ||
              issueTagLink.hasMatch(anchor) ||
              prTagLink.hasMatch(anchor))) {
            printError(
              '${_indentation}Incorrect anchor in root README.md table: "$anchor"',
            );
            errors.add('Incorrect anchor in root README.md table');
          }

          // The link should be one of:
          // - a relative link to the in-repo package
          // - a pub.dev link to the package
          // - a github label link to the package's label
          final pubDevLink = RegExp(
            '^https://pub.dev/packages/$packageName(?:/score)?\$',
          );
          final gitHubIssueLink = RegExp(
            '^https://github.com/flutter/flutter/labels/$encodedIssueTag\$',
          );
          final gitHubPRLink = RegExp(
            '^https://github.com/flutter/packages/labels/$encodedPRTag\$',
          );
          if (!(target == './packages/$packageName/' ||
              target == './third_party/packages/$packageName/' ||
              pubDevLink.hasMatch(target) ||
              gitHubIssueLink.hasMatch(target) ||
              gitHubPRLink.hasMatch(target))) {
            printError(
              '${_indentation}Incorrect link in root README.md table: "$target"',
            );
            errors.add('Incorrect link in root README.md table');
          }
        }
      }
    }
    return errors;
  }

  String _prTagForPackage(String packageName) => 'p: $packageName';

  String _issueTagForPackage(String packageName) {
    // TODO(stuartmorgan): Move this to a config file. See
    // https://github.com/flutter/flutter/issues/185364
    switch (packageName) {
      case 'google_maps_flutter':
        return 'p: maps';
      case 'webview_flutter':
        return 'p: webview';
      default:
        return 'p: $packageName';
    }
  }

  Future<List<String>> _validateFilesBasedOnReleaseStrategy(
    RepositoryPackage package,
  ) async {
    final errors = <String>[];
    final bool isBatchRelease =
        package.parseCIConfig()?.isBatchRelease ?? false;
    final String packageName = package.directory.basename;
    final Directory repoRoot = package.directory.fileSystem.directory(
      _gitDir.path,
    );
    final Directory workflowDir = repoRoot
        .childDirectory('.github')
        .childDirectory('workflows');

    errors.addAll(
      _validateSpecificBatchWorkflow(
        packageName,
        workflowDir: workflowDir,
        isBatchRelease: isBatchRelease,
      ),
    );

    errors.addAll(
      _validateGlobalWorkflowTrigger(
        'release_from_branches.yml',
        workflowDir: workflowDir,
        isBatchRelease: isBatchRelease,
        packageName: packageName,
      ),
    );
    errors.addAll(
      _validateGlobalWorkflowTrigger(
        'sync_release_pr.yml',
        workflowDir: workflowDir,
        isBatchRelease: isBatchRelease,
        packageName: packageName,
      ),
    );

    errors.addAll(
      _validateCiYamlEnabledBranches(
        packageName,
        repoRoot: repoRoot,
        isBatchRelease: isBatchRelease,
      ),
    );

    if (isBatchRelease &&
        (package.parsePubspec().version?.isPreRelease ?? false)) {
      errors.add(
        'Batch release packages must not have a pre-release version.\n'
        'See https://github.com/flutter/flutter/blob/master/docs/ecosystem/release/README.md#batch-release',
      );
    }

    return errors;
  }

  List<String> _validateSpecificBatchWorkflow(
    String packageName, {
    required Directory workflowDir,
    required bool isBatchRelease,
  }) {
    final errors = <String>[];
    final File batchWorkflowFile = workflowDir.childFile(
      '${packageName}_batch.yml',
    );
    if (isBatchRelease) {
      if (!batchWorkflowFile.existsSync()) {
        errors.add(
          'Missing batch workflow file: .github/workflows/${packageName}_batch.yml\n'
          'See https://github.com/flutter/flutter/blob/master/docs/ecosystem/release/README.md#batch-release',
        );
      } else {
        // Validate content.
        final String content = batchWorkflowFile.readAsStringSync();
        final YamlMap yaml;
        try {
          yaml = loadYaml(content) as YamlMap;
        } catch (e) {
          errors.add('Invalid YAML in ${packageName}_batch.yml: $e');
          return errors;
        }

        var foundDispatch = false;
        final jobs = yaml['jobs'] as YamlMap?;
        if (jobs != null) {
          for (final Object? job in jobs.values) {
            if (job is YamlMap && job['steps'] is YamlList) {
              final steps = job['steps'] as YamlList;
              for (final Object? step in steps) {
                if (step is YamlMap &&
                    step['uses'] is String &&
                    (step['uses'] as String).startsWith(
                      'peter-evans/repository-dispatch',
                    )) {
                  final withArgs = step['with'] as YamlMap?;
                  if (withArgs != null &&
                      withArgs['event-type'] == 'batch-release-pr' &&
                      withArgs['client-payload'] ==
                          '{"package": "$packageName"}') {
                    foundDispatch = true;
                  }
                }
              }
            }
          }
        }

        if (!foundDispatch) {
          errors.add(
            'Invalid batch workflow content in ${packageName}_batch.yml. '
            'Must contain a step using peter-evans/repository-dispatch with:\n'
            '  event-type: batch-release-pr\n'
            '  client-payload: \'{"package": "$packageName"}\'\n'
            'See https://github.com/flutter/flutter/blob/master/docs/ecosystem/release/README.md#batch-release',
          );
        }
      }
    } else {
      if (batchWorkflowFile.existsSync()) {
        errors.add(
          'Unexpected batch workflow file: .github/workflows/${packageName}_batch.yml\n',
        );
      }
    }
    return errors;
  }

  List<String> _validateGlobalWorkflowTrigger(
    String workflowName, {
    required Directory workflowDir,
    required bool isBatchRelease,
    required String packageName,
  }) {
    final errors = <String>[];
    final File workflowFile = workflowDir.childFile(workflowName);
    if (!workflowFile.existsSync()) {
      if (isBatchRelease) {
        errors.add(
          'Missing global workflow file: .github/workflows/$workflowName\n'
          'See https://github.com/flutter/flutter/blob/master/docs/ecosystem/release/README.md#batch-release',
        );
      }
      return errors;
    }

    final String content = workflowFile.readAsStringSync();
    final YamlMap yaml;
    try {
      yaml = loadYaml(content) as YamlMap;
    } catch (e) {
      errors.add('Invalid YAML in $workflowName: $e');
      return errors;
    }

    var hasTrigger = false;
    final on = yaml['on'] as YamlMap?;
    if (on is YamlMap) {
      final push = on['push'] as YamlMap?;
      if (push is YamlMap) {
        final branches = push['branches'] as YamlList?;
        if (branches is YamlList) {
          if (branches.contains('release-$packageName-*')) {
            hasTrigger = true;
          }
        }
      }
    }

    if (isBatchRelease && !hasTrigger) {
      errors.add(
        'Missing trigger for release-$packageName-* in .github/workflows/$workflowName\n'
        'See https://github.com/flutter/flutter/blob/master/docs/ecosystem/release/README.md#batch-release',
      );
    } else if (!isBatchRelease && hasTrigger) {
      errors.add(
        'Unexpected trigger for release-$packageName-* in .github/workflows/$workflowName\n',
      );
    }
    return errors;
  }

  List<String> _validateCiYamlEnabledBranches(
    String packageName, {
    required Directory repoRoot,
    required bool isBatchRelease,
  }) {
    final errors = <String>[];
    final File ciYamlFile = repoRoot.childFile('.ci.yaml');
    final String content = ciYamlFile.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap;

    final enabledBranches = yaml['enabled_branches'] as YamlList?;
    final bool hasBranchPattern =
        enabledBranches != null &&
        enabledBranches.contains(r'release-' + packageName + r'-\d+\.\d+\.\d+');

    if (isBatchRelease && !hasBranchPattern) {
      printError(
        '${_indentation}Missing release branch pattern release-$packageName-\\d+\\.\\d+\\.\\d+ '
        'in enabled_branches in .ci.yaml\n'
        '${_indentation}See https://github.com/flutter/flutter/blob/master/docs/ecosystem/release/README.md#batch-release',
      );
      errors.add('Unexpected branch handling in .ci.yaml');
    } else if (!isBatchRelease && hasBranchPattern) {
      printError(
        '${_indentation}Unexpected release branch pattern release-$packageName-\\d+\\.\\d+\\.\\d+ '
        'in enabled_branches in .ci.yaml',
      );
      errors.add('Unexpected branch handling in .ci.yaml');
    }
    return errors;
  }
}
