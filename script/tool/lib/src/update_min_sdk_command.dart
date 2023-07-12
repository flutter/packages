// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

const int _exitUnknownVersion = 3;

/// A command to update the minimum Flutter and Dart SDKs of packages.
class UpdateMinSdkCommand extends PackageLoopingCommand {
  /// Creates a publish metadata updater command instance.
  UpdateMinSdkCommand(super.packagesDir) {
    argParser.addOption(_flutterMinFlag,
        mandatory: true,
        help: 'The minimum version of Flutter to set SDK constraints to.');
  }

  static const String _flutterMinFlag = 'flutter-min';

  late final Version _flutterMinVersion;
  late final Version _dartMinVersion;

  @override
  final String name = 'update-min-sdk';

  @override
  final String description = 'Updates the Flutter and Dart SDK minimums '
      'in pubspec.yaml to match the given Flutter version.';

  @override
  final PackageLoopingType packageLoopingType =
      PackageLoopingType.includeAllSubpackages;

  @override
  bool get hasLongOutput => false;

  @override
  Future<void> initializeRun() async {
    _flutterMinVersion = Version.parse(getStringArg(_flutterMinFlag));
    final Version? dartMinVersion = getDartSdkForFlutterSdk(_flutterMinVersion);
    if (dartMinVersion == null) {
      printError('Dart SDK version for Fluter SDK version '
          '$_flutterMinVersion is unknown. '
          'Please update the map for getDartSdkForFlutterSdk with the '
          'corresponding Dart version.');
      throw ToolExit(_exitUnknownVersion);
    }
    _dartMinVersion = dartMinVersion;
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final Pubspec pubspec = package.parsePubspec();

    const String environmentKey = 'environment';
    const String dartSdkKey = 'sdk';
    const String flutterSdkKey = 'flutter';

    final VersionRange? dartRange = _sdkRange(pubspec, dartSdkKey);
    final VersionRange? flutterRange = _sdkRange(pubspec, flutterSdkKey);

    final YamlEditor editablePubspec =
        YamlEditor(package.pubspecFile.readAsStringSync());
    if (dartRange != null &&
        (dartRange.min ?? Version.none) < _dartMinVersion) {
      Version upperBound = _dartMinVersion.nextMajor;
      // pub special-cases 3.0.0 as an upper bound to be treated as 4.0.0, and
      // using 3.0.0 is now an error at upload time, so special case it here.
      if (upperBound.major == 3) {
        upperBound = upperBound.nextMajor;
      }
      editablePubspec.update(
          <String>[environmentKey, dartSdkKey],
          VersionRange(min: _dartMinVersion, includeMin: true, max: upperBound)
              .toString());
      print('${indentation}Updating Dart minimum to $_dartMinVersion');
    }
    if (flutterRange != null &&
        (flutterRange.min ?? Version.none) < _flutterMinVersion) {
      editablePubspec.update(<String>[environmentKey, flutterSdkKey],
          VersionRange(min: _flutterMinVersion, includeMin: true).toString());
      print('${indentation}Updating Flutter minimum to $_flutterMinVersion');
    }
    package.pubspecFile.writeAsStringSync(editablePubspec.toString());

    return PackageResult.success();
  }

  /// Returns the given "environment" section's [key] constraint as a range,
  /// if the key is present and has a range.
  VersionRange? _sdkRange(Pubspec pubspec, String key) {
    final VersionConstraint? constraint = pubspec.environment?[key];
    if (constraint is VersionRange) {
      return constraint;
    }
    return null;
  }
}
