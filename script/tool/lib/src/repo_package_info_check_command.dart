// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

const int _exitBadTableEntry = 3;
const int _exitUnknownPackageEntry = 4;

/// A command to verify repository-level metadata about packages, such as
/// repo README and CODEOWNERS entries.
class RepoPackageInfoCheckCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  RepoPackageInfoCheckCommand(super.packagesDir, {super.gitDir});

  late Directory _repoRoot;

  /// Data from the root README.md table of packages.
  final Map<String, List<String>> _readmeTableEntries =
      <String, List<String>>{};

  /// Packages with entries in CODEOWNERS.
  final List<String> _ownedPackages = <String>[];

  @override
  final String name = 'repo-package-info-check';

  @override
  List<String> get aliases => <String>['check-repo-package-info'];

  @override
  final String description =
      'Checks that all packages are listed correctly in the repo README.';

  @override
  final bool hasLongOutput = false;

  @override
  Future<void> initializeRun() async {
    _repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

    // Extract all of the README.md table entries.
    final RegExp namePattern = RegExp(r'\[(.*?)\]\(');
    for (final String line
        in _repoRoot.childFile('README.md').readAsLinesSync()) {
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
        final String? name =
            namePattern.firstMatch(cells[0])?.group(1)?.replaceAll(r'\_', '_');
        if (name == null) {
          printError('Unexpected README table line:\n  $line');
          throw ToolExit(_exitBadTableEntry);
        }
        _readmeTableEntries[name] = cells;

        if (!(packagesDir.childDirectory(name).existsSync() ||
            thirdPartyPackagesDir.childDirectory(name).existsSync())) {
          printError('Unknown package "$name" in root README.md table.');
          throw ToolExit(_exitUnknownPackageEntry);
        }
      }
    }

    // Extract all of the CODEOWNERS package entries.
    final RegExp packageOwnershipPattern =
        RegExp(r'^((?:third_party/)?packages/(?:[^/]*/)?([^/]*))/\*\*');
    for (final String line
        in _repoRoot.childFile('CODEOWNERS').readAsLinesSync()) {
      final RegExpMatch? match = packageOwnershipPattern.firstMatch(line);
      if (match == null) {
        continue;
      }
      final String path = match.group(1)!;
      final String name = match.group(2)!;
      if (!_repoRoot.childDirectory(path).existsSync()) {
        printError('Unknown directory "$path" in CODEOWNERS');
        throw ToolExit(_exitUnknownPackageEntry);
      }
      _ownedPackages.add(name);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final String packageName = package.directory.basename;
    final List<String> errors = <String>[];

    // All packages should have an owner.
    // Platform interface packages are considered to be owned by the app-facing
    // package owner.
    if (!(_ownedPackages.contains(packageName) ||
        package.isPlatformInterface &&
            _ownedPackages.contains(package.directory.parent.basename))) {
      printError('${indentation}Missing CODEOWNERS entry.');
      errors.add('Missing CODEOWNERS entry');
    }

    // Any published package should be in the README table.
    // For federated plugins, only the app-facing package is listed.
    if (package.isPublishable() &&
        (!package.isFederated || package.isAppFacing)) {
      final List<String>? cells = _readmeTableEntries[packageName];

      if (cells == null) {
        printError('${indentation}Missing repo root README.md table entry');
        errors.add('Missing repo root README.md table entry');
      } else {
        // Extract the two parts of a "[label](link)" .md link.
        final RegExp mdLinkPattern = RegExp(r'^\[(.*)\]\((.*)\)$');
        // Possible link targets.
        for (final String cell in cells) {
          final RegExpMatch? match = mdLinkPattern.firstMatch(cell);
          if (match == null) {
            printError(
                '${indentation}Invalid repo root README.md table entry: "$cell"');
            errors.add('Invalid root README.md table entry');
          } else {
            final String encodedIssueTag =
                Uri.encodeComponent(_issueTagForPackage(packageName));
            final String encodedPRTag =
                Uri.encodeComponent(_prTagForPackage(packageName));
            final String anchor = match.group(1)!;
            final String target = match.group(2)!;

            // The anchor should be one of:
            // - The package name (optionally with any underscores escaped)
            // - An image with a name-based link
            // - An image with a tag-based link
            final RegExp packageLink =
                RegExp(r'^!\[.*\]\(https://img.shields.io/pub/.*/'
                    '$packageName'
                    r'(?:\.svg)?\)$');
            final RegExp issueTagLink = RegExp(
                r'^!\[.*\]\(https://img.shields.io/github/issues/flutter/flutter/'
                '$encodedIssueTag'
                r'\?label=\)$');
            final RegExp prTagLink = RegExp(
                r'^!\[.*\]\(https://img.shields.io/github/issues-pr/flutter/packages/'
                '$encodedPRTag'
                r'\?label=\)$');
            if (!(anchor == packageName ||
                anchor == packageName.replaceAll('_', r'\_') ||
                packageLink.hasMatch(anchor) ||
                issueTagLink.hasMatch(anchor) ||
                prTagLink.hasMatch(anchor))) {
              printError(
                  '${indentation}Incorrect anchor in root README.md table: "$anchor"');
              errors.add('Incorrect anchor in root README.md table');
            }

            // The link should be one of:
            // - a relative link to the in-repo package
            // - a pub.dev link to the package
            // - a github label link to the package's label
            final RegExp pubDevLink =
                RegExp('^https://pub.dev/packages/$packageName(?:/score)?\$');
            final RegExp gitHubIssueLink = RegExp(
                '^https://github.com/flutter/flutter/labels/$encodedIssueTag\$');
            final RegExp gitHubPRLink = RegExp(
                '^https://github.com/flutter/packages/labels/$encodedPRTag\$');
            if (!(target == './packages/$packageName/' ||
                target == './third_party/packages/$packageName/' ||
                pubDevLink.hasMatch(target) ||
                gitHubIssueLink.hasMatch(target) ||
                gitHubPRLink.hasMatch(target))) {
              printError(
                  '${indentation}Incorrect link in root README.md table: "$target"');
              errors.add('Incorrect link in root README.md table');
            }
          }
        }
      }
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  String _prTagForPackage(String packageName) => 'p: $packageName';

  String _issueTagForPackage(String packageName) {
    switch (packageName) {
      case 'google_maps_flutter':
        return 'p: maps';
      case 'webview_flutter':
        return 'p: webview';
      default:
        return 'p: $packageName';
    }
  }
}
