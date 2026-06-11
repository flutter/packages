// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';

import 'analyze_command.dart';
import 'branches_for_batch_release_command.dart';
import 'build_examples_command.dart';
import 'common/core.dart';
import 'create_all_packages_app_command.dart';
import 'custom_test_command.dart';
import 'dart_test_command.dart';
import 'drive_examples_command.dart';
import 'federation_safety_check_command.dart';
import 'fetch_deps_command.dart';
import 'firebase_test_lab_command.dart';
import 'fix_command.dart';
import 'format_command.dart';
import 'license_check_command.dart';
import 'list_command.dart';
import 'make_deps_path_based_command.dart';
import 'native_test_command.dart';
import 'podspec_check_command.dart';
import 'publish_check_command.dart';
import 'publish_command.dart';
import 'remove_dev_dependencies_command.dart';
import 'update_dependency_command.dart';
import 'update_excerpts_command.dart';
import 'update_min_sdk_command.dart';
import 'update_release_info_command.dart';
import 'validate_command.dart';

void main(List<String> args) {
  final Directory? root = _findRepositoryRoot();
  if (root == null) {
    print('Error: Cannot find repository root');
    io.exit(1);
  }
  final Directory packagesDir = root.childDirectory('packages');

  if (!packagesDir.existsSync()) {
    print('Error: Cannot find a "packages" sub-directory');
    io.exit(1);
  }

  final commandRunner =
      CommandRunner<void>(
          'dart pub global run flutter_plugin_tools',
          'Productivity utils for hosting multiple plugins within one repository.',
        )
        ..addCommand(AnalyzeCommand(packagesDir))
        ..addCommand(BranchesForBatchReleaseCommand(packagesDir))
        ..addCommand(BuildExamplesCommand(packagesDir))
        ..addCommand(CreateAllPackagesAppCommand(packagesDir))
        ..addCommand(CustomTestCommand(packagesDir))
        ..addCommand(DartTestCommand(packagesDir))
        ..addCommand(DriveExamplesCommand(packagesDir))
        ..addCommand(FederationSafetyCheckCommand(packagesDir))
        ..addCommand(FetchDepsCommand(packagesDir))
        ..addCommand(FirebaseTestLabCommand(packagesDir))
        ..addCommand(FixCommand(packagesDir))
        ..addCommand(FormatCommand(packagesDir))
        ..addCommand(LicenseCheckCommand(packagesDir))
        ..addCommand(ListCommand(packagesDir))
        ..addCommand(MakeDepsPathBasedCommand(packagesDir))
        ..addCommand(NativeTestCommand(packagesDir))
        ..addCommand(PodspecCheckCommand(packagesDir))
        ..addCommand(PublishCheckCommand(packagesDir))
        ..addCommand(PublishCommand(packagesDir))
        ..addCommand(RemoveDevDependenciesCommand(packagesDir))
        ..addCommand(UpdateDependencyCommand(packagesDir))
        ..addCommand(UpdateExcerptsCommand(packagesDir))
        ..addCommand(UpdateMinSdkCommand(packagesDir))
        ..addCommand(UpdateReleaseInfoCommand(packagesDir))
        ..addCommand(ValidateCommand(packagesDir));

  commandRunner.run(args).catchError((Object e) {
    final toolExit = e as ToolExit;
    int exitCode = toolExit.exitCode;
    // This should never happen; this check is here to guarantee that a ToolExit
    // never accidentally has code 0 thus causing CI to pass.
    if (exitCode == 0) {
      assert(false);
      exitCode = 255;
    }
    io.exit(exitCode);
  }, test: (Object e) => e is ToolExit);
}

/// Locates the root directory of the repository, assuming that the script is
/// being run from within the repository.
Directory? _findRepositoryRoot() {
  Directory current = const LocalFileSystem().currentDirectory;
  while (current != current.parent) {
    // The repository should contain both a .git directory and a packages/
    // directory, so use that as the heuristic. If this heuristic proves
    // insufficient, we could instead require the tool config to be present
    // to even try to run, and look for that.
    if ((current.childDirectory('.git').existsSync() || current.childFile('.git').existsSync()) &&
        current.childDirectory('packages').existsSync()) {
      return current;
    }
    current = current.parent;
  }
  return null;
}
