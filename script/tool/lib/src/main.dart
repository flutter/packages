// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';

import 'analyze_command.dart';
import 'branch_for_batch_release_command.dart';
import 'build_examples_command.dart';
import 'common/core.dart';
import 'create_all_packages_app_command.dart';
import 'custom_test_command.dart';
import 'dart_test_command.dart';
import 'dependabot_check_command.dart';
import 'drive_examples_command.dart';
import 'federation_safety_check_command.dart';
import 'fetch_deps_command.dart';
import 'firebase_test_lab_command.dart';
import 'fix_command.dart';
import 'format_command.dart';
import 'gradle_check_command.dart';
import 'license_check_command.dart';
import 'list_command.dart';
import 'make_deps_path_based_command.dart';
import 'native_test_command.dart';
import 'podspec_check_command.dart';
import 'publish_check_command.dart';
import 'publish_command.dart';
import 'pubspec_check_command.dart';
import 'readme_check_command.dart';
import 'remove_dev_dependencies_command.dart';
import 'repo_package_info_check_command.dart';
import 'update_dependency_command.dart';
import 'update_excerpts_command.dart';
import 'update_min_sdk_command.dart';
import 'update_release_info_command.dart';
import 'version_check_command.dart';

void main(List<String> args) {
  const FileSystem fileSystem = LocalFileSystem();
  final Directory scriptDir =
      fileSystem.file(io.Platform.script.toFilePath()).parent;
  // Support running either via directly invoking main.dart, or the wrapper in
  // bin/.
  final Directory toolsDir =
      scriptDir.basename == 'bin' ? scriptDir.parent : scriptDir.parent.parent;
  final Directory root = toolsDir.parent.parent;
  final Directory packagesDir = root.childDirectory('packages');

  if (!packagesDir.existsSync()) {
    print('Error: Cannot find a "packages" sub-directory');
    io.exit(1);
  }

  final CommandRunner<void> commandRunner = CommandRunner<void>(
      'dart pub global run flutter_plugin_tools',
      'Productivity utils for hosting multiple plugins within one repository.')
    ..addCommand(AnalyzeCommand(packagesDir))
    ..addCommand(BuildExamplesCommand(packagesDir))
    ..addCommand(CreateAllPackagesAppCommand(packagesDir))
    ..addCommand(CustomTestCommand(packagesDir))
    ..addCommand(DependabotCheckCommand(packagesDir))
    ..addCommand(DriveExamplesCommand(packagesDir))
    ..addCommand(FederationSafetyCheckCommand(packagesDir))
    ..addCommand(FetchDepsCommand(packagesDir))
    ..addCommand(FirebaseTestLabCommand(packagesDir))
    ..addCommand(FixCommand(packagesDir))
    ..addCommand(FormatCommand(packagesDir))
    ..addCommand(GradleCheckCommand(packagesDir))
    ..addCommand(LicenseCheckCommand(packagesDir))
    ..addCommand(PodspecCheckCommand(packagesDir))
    ..addCommand(ListCommand(packagesDir))
    ..addCommand(NativeTestCommand(packagesDir))
    ..addCommand(MakeDepsPathBasedCommand(packagesDir))
    ..addCommand(PublishCheckCommand(packagesDir))
    ..addCommand(PublishCommand(packagesDir))
    ..addCommand(PubspecCheckCommand(packagesDir))
    ..addCommand(ReadmeCheckCommand(packagesDir))
    ..addCommand(RemoveDevDependenciesCommand(packagesDir))
    ..addCommand(RepoPackageInfoCheckCommand(packagesDir))
    ..addCommand(DartTestCommand(packagesDir))
    ..addCommand(UpdateDependencyCommand(packagesDir))
    ..addCommand(UpdateExcerptsCommand(packagesDir))
    ..addCommand(UpdateMinSdkCommand(packagesDir))
    ..addCommand(UpdateReleaseInfoCommand(packagesDir))
    ..addCommand(VersionCheckCommand(packagesDir))
    ..addCommand(BranchForBatchReleaseCommand(packagesDir));

  commandRunner.run(args).catchError((Object e) {
    final ToolExit toolExit = e as ToolExit;
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
