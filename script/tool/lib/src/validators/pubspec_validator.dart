// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

import '../common/core.dart';
import '../common/file_utils.dart';
import '../common/output_utils.dart';
import '../common/plugin_utils.dart';
import '../common/repository_package.dart';

// Section order for plugins. Because the 'flutter' section is critical
// information for plugins, and usually small, it goes near the top unlike in
// a normal app or package.
const List<String> _majorPluginSections = <String>[
  'environment:',
  'flutter:',
  'dependencies:',
  'dev_dependencies:',
  'topics:',
  'screenshots:',
  'false_secrets:',
];

const List<String> _majorPackageSections = <String>[
  'environment:',
  'dependencies:',
  'dev_dependencies:',
  'flutter:',
  'topics:',
  'screenshots:',
  'false_secrets:',
];

const String _expectedIssueLinkFormat =
    'https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A';

/// A set of packages that are allowed as dependencies.
typedef AllowPackageLists = ({
  /// Packages local to the repository.
  Set<String> local,

  /// Packages that are allowed only as pinned dependencies.
  Set<String> pinned,

  /// Packages that are allowed as unpinned dependencies.
  Set<String> unpinned,
});

/// Validates that pubspecs follow repository conventions.
class PubspecValidator {
  /// Creates a new instance of [PubspecValidator] with the given configuration.
  ///
  /// [allowedPackages] must contain all of the packages that are allowed as
  /// published dependencies.
  PubspecValidator({
    required path.Context path,
    required String indentation,
    required AllowPackageLists allowedPackages,
    required void Function(String) warningLogger,
    required Directory repoRoot,
    required String minMinFlutterVersion,
  }) : _path = path,
       _indentation = indentation,
       _allowedPackages = allowedPackages,
       _logWarning = warningLogger,
       _repoRoot = repoRoot,
       _minMinFlutterVersion = minMinFlutterVersion;

  final path.Context _path;
  final String _indentation;
  final AllowPackageLists _allowedPackages;
  final void Function(String) _logWarning;
  final Directory _repoRoot;
  final String _minMinFlutterVersion;

  /// Validates that the pubspec of a package follows repository conventions,
  /// returning a list of errors.
  ///
  /// If no errors are found, an empty list is returned.
  Future<List<String>> validatePubspec(RepositoryPackage package) async {
    if (!package.pubspecFile.existsSync()) {
      return [];
    }
    final String contents = package.pubspecFile.readAsStringSync();
    Pubspec pubspec;
    try {
      pubspec = Pubspec.parse(contents);
    } on Exception {
      printError('${_indentation}Unable to parse pubspec.yaml');
      return ['pubspec.yaml parse failure'];
    }

    final List<String> pubspecLines = contents.split('\n');
    final bool isPlugin = pubspec.flutter?.containsKey('plugin') ?? false;
    final List<String> sectionOrder = isPlugin
        ? _majorPluginSections
        : _majorPackageSections;
    bool passing = _checkSectionOrder(pubspecLines, sectionOrder);
    if (!passing) {
      printError(
        '${_indentation}Major sections should follow standard '
        'repository ordering:',
      );
      final String listIndentation = _indentation * 2;
      printError('$listIndentation${sectionOrder.join('\n$listIndentation')}');
    }

    final String? minVersionError = _checkForMinimumVersionError(
      pubspec,
      package,
      minMinFlutterVersion: _minMinFlutterVersion.isEmpty
          ? null
          : Version.parse(_minMinFlutterVersion),
    );
    if (minVersionError != null) {
      printError('$_indentation$minVersionError');
      passing = false;
    }

    if (isPlugin) {
      final String? implementsError = _checkForImplementsError(
        pubspec,
        package: package,
      );
      if (implementsError != null) {
        printError('$_indentation$implementsError');
        passing = false;
      }

      final String? defaultPackageError = _checkForDefaultPackageError(
        pubspec,
        package: package,
      );
      if (defaultPackageError != null) {
        printError('$_indentation$defaultPackageError');
        passing = false;
      }
    }

    final String? dependenciesError = _checkDependencies(pubspec);
    if (dependenciesError != null) {
      printError(
        dependenciesError
            .split('\n')
            .map((String line) => '$_indentation$line')
            .join('\n'),
      );
      passing = false;
    }

    // Ignore metadata that's only relevant for published packages if the
    // packages is not intended for publishing.
    if (pubspec.publishTo != 'none') {
      final List<String> repositoryErrors = _checkForRepositoryLinkErrors(
        pubspec,
        package: package,
      );
      if (repositoryErrors.isNotEmpty) {
        for (final error in repositoryErrors) {
          printError('$_indentation$error');
        }
        passing = false;
      }

      if (!_checkIssueLink(pubspec)) {
        printError(
          '${_indentation}A package should have an "issue_tracker" link to a '
          'search for open flutter/flutter bugs with the relevant label:\n'
          '${_indentation * 2}$_expectedIssueLinkFormat<package label>',
        );
        passing = false;
      }

      final String? topicsError = _checkTopics(pubspec, package: package);
      if (topicsError != null) {
        printError('$_indentation$topicsError');
        passing = false;
      }

      // Don't check descriptions for federated package components other than
      // the app-facing package, since they are unlisted, and are expected to
      // have short descriptions.
      if (!package.isPlatformInterface && !package.isPlatformImplementation) {
        final String? descriptionError = _checkDescription(
          pubspec,
          package: package,
        );
        if (descriptionError != null) {
          printError('$_indentation$descriptionError');
          passing = false;
        }
      }
    }

    return passing
        ? <String>[]
        : ['pubspec.yaml failed validation, see above for details'];
  }

  bool _checkSectionOrder(
    List<String> pubspecLines,
    List<String> sectionOrder,
  ) {
    var previousSectionIndex = 0;
    for (final line in pubspecLines) {
      final int index = sectionOrder.indexOf(line);
      if (index == -1) {
        continue;
      }
      if (index < previousSectionIndex) {
        return false;
      }
      previousSectionIndex = index;
    }
    return true;
  }

  List<String> _checkForRepositoryLinkErrors(
    Pubspec pubspec, {
    required RepositoryPackage package,
  }) {
    final errorMessages = <String>[];
    if (pubspec.repository == null) {
      errorMessages.add('Missing "repository"');
    } else {
      final String relativePackagePath = relativePosixPath(
        package.directory,
        from: _repoRoot,
        platformContext: _path,
      );
      if (!pubspec.repository!.path.endsWith(relativePackagePath)) {
        errorMessages.add(
          'The "repository" link should end with the package path.',
        );
      }

      if (!pubspec.repository!.toString().startsWith(
        'https://github.com/flutter/packages/tree/main',
      )) {
        errorMessages.add(
          'The "repository" link should start with the repository\'s '
          'main tree: "https://github.com/flutter/packages/tree/main".',
        );
      }
    }

    if (pubspec.homepage != null) {
      errorMessages.add(
        'Found a "homepage" entry; only "repository" should be used.',
      );
    }

    return errorMessages;
  }

  // Validates the "description" field for a package, returning an error
  // string if there are any issues.
  String? _checkDescription(
    Pubspec pubspec, {
    required RepositoryPackage package,
  }) {
    final String? description = pubspec.description;
    if (description == null) {
      return 'Missing "description"';
    }

    if (description.length < 60) {
      return '"description" is too short. pub.dev recommends package '
          'descriptions of 60-180 characters.';
    }
    if (description.length > 180) {
      return '"description" is too long. pub.dev recommends package '
          'descriptions of 60-180 characters.';
    }
    return null;
  }

  bool _checkIssueLink(Pubspec pubspec) {
    return pubspec.issueTracker?.toString().startsWith(
          _expectedIssueLinkFormat,
        ) ??
        false;
  }

  // Validates the "topics" keyword for a plugin, returning an error
  // string if there are any issues.
  String? _checkTopics(Pubspec pubspec, {required RepositoryPackage package}) {
    final List<String> topics = pubspec.topics ?? <String>[];
    if (topics.isEmpty) {
      return 'A published package should include "topics". '
          'See https://dart.dev/tools/pub/pubspec#topics.';
    }
    if (topics.length > 5) {
      return 'A published package should have maximum 5 topics. '
          'See https://dart.dev/tools/pub/pubspec#topics.';
    }
    if (isFlutterPlugin(package) && package.isFederated) {
      final String pluginName = package.directory.parent.basename;
      // '_' isn't allowed in topics, so convert to '-'.
      final String topicName = pluginName.replaceAll('_', '-');
      if (!topics.contains(topicName)) {
        return 'A federated plugin package should include its plugin name as '
            'a topic. Add "$topicName" to the "topics" section.';
      }
    }

    // Validates topic names according to https://dart.dev/tools/pub/pubspec#topics
    final expectedTopicFormat = RegExp(r'^[a-z](?:-?[a-z0-9]+)*$');
    final Iterable<String> invalidTopics = topics.where(
      (String topic) =>
          !expectedTopicFormat.hasMatch(topic) ||
          topic.length < 2 ||
          topic.length > 32,
    );
    if (invalidTopics.isNotEmpty) {
      return 'Invalid topic(s): ${invalidTopics.join(', ')} in "topics" section. '
          'Topics must consist of lowercase alphanumerical characters or dash (but no double dash), '
          'start with a-z and ending with a-z or 0-9, have a minimum of 2 characters '
          'and have a maximum of 32 characters.';
    }
    return null;
  }

  // Validates the "implements" keyword for a plugin, returning an error
  // string if there are any issues.
  //
  // Should only be called on plugin packages.
  String? _checkForImplementsError(
    Pubspec pubspec, {
    required RepositoryPackage package,
  }) {
    if (_isImplementationPackage(package)) {
      final pluginSection = pubspec.flutter!['plugin'] as YamlMap;
      final implements = pluginSection['implements'] as String?;
      final String expectedImplements = package.directory.parent.basename;
      if (implements == null) {
        return 'Missing "implements: $expectedImplements" in "plugin" section.';
      } else if (implements != expectedImplements) {
        return 'Expecetd "implements: $expectedImplements"; '
            'found "implements: $implements".';
      }
    }
    return null;
  }

  // Validates any "default_package" entries a plugin, returning an error
  // string if there are any issues.
  //
  // Should only be called on plugin packages.
  String? _checkForDefaultPackageError(
    Pubspec pubspec, {
    required RepositoryPackage package,
  }) {
    final pluginSection = pubspec.flutter!['plugin'] as YamlMap;
    final platforms = pluginSection['platforms'] as YamlMap?;
    if (platforms == null) {
      _logWarning('Does not implement any platforms');
      return null;
    }
    final String packageName = package.directory.basename;

    // Validate that the default_package entries look correct (e.g., no typos).
    final defaultPackages = <String>{};
    for (final MapEntry<Object?, Object?> platformEntry in platforms.entries) {
      final platformDetails = platformEntry.value! as YamlMap;
      final defaultPackage = platformDetails['default_package'] as String?;
      if (defaultPackage != null) {
        defaultPackages.add(defaultPackage);
        if (!defaultPackage.startsWith('${packageName}_')) {
          return '"$defaultPackage" is not an expected implementation name '
              'for "$packageName"';
        }
      }
    }

    // Validate that all default_packages are also dependencies.
    final Iterable<String> dependencies = pubspec.dependencies.keys;
    final Iterable<String> missingPackages = defaultPackages.where(
      (String package) => !dependencies.contains(package),
    );
    if (missingPackages.isNotEmpty) {
      return 'The following default_packages are missing '
          'corresponding dependencies:\n'
          '  ${missingPackages.join('\n  ')}';
    }

    return null;
  }

  // Returns true if [packageName] appears to be an implementation package
  // according to repository conventions.
  bool _isImplementationPackage(RepositoryPackage package) {
    if (!package.isFederated) {
      return false;
    }
    final String packageName = package.directory.basename;
    final String parentName = package.directory.parent.basename;
    // A few known package names are not implementation packages; assume
    // anything else is. (This is done instead of listing known implementation
    // suffixes to allow for non-standard suffixes; e.g., to put several
    // platforms in one package for code-sharing purposes.)
    const nonImplementationSuffixes = <String>{
      '', // App-facing package.
      '_platform_interface', // Platform interface package.
    };
    final String suffix = packageName.substring(parentName.length);
    return !nonImplementationSuffixes.contains(suffix);
  }

  /// Validates that a Flutter package has a minimum SDK version constraint of
  /// at least [minMinFlutterVersion] (if provided), or that a non-Flutter
  /// package has a minimum SDK version constraint of [minMinDartVersion]
  /// (if provided).
  ///
  /// Returns an error string if validation fails.
  String? _checkForMinimumVersionError(
    Pubspec pubspec,
    RepositoryPackage package, {
    Version? minMinFlutterVersion,
  }) {
    String unknownDartVersionError(Version flutterVersion) {
      return 'Dart SDK version for Flutter SDK version '
          '$flutterVersion is unknown. '
          'Please update the map for getDartSdkForFlutterSdk with the '
          'corresponding Dart version.';
    }

    Version? minMinDartVersion;
    if (minMinFlutterVersion != null) {
      minMinDartVersion = getDartSdkForFlutterSdk(minMinFlutterVersion);
      if (minMinDartVersion == null) {
        return unknownDartVersionError(minMinFlutterVersion);
      }
    }

    final Version? dartConstraintMin = _minimumForConstraint(
      pubspec.environment['sdk'],
    );
    final Version? flutterConstraintMin = _minimumForConstraint(
      pubspec.environment['flutter'],
    );

    // Validate the Flutter constraint, if any.
    if (flutterConstraintMin != null && minMinFlutterVersion != null) {
      if (flutterConstraintMin < minMinFlutterVersion) {
        return 'Minimum allowed Flutter version $flutterConstraintMin is less '
            'than $minMinFlutterVersion';
      }
    }

    // Validate the Dart constraint, if any.
    if (dartConstraintMin != null) {
      // Ensure that it satisfies the minimum.
      if (minMinDartVersion != null) {
        if (dartConstraintMin < minMinDartVersion) {
          return 'Minimum allowed Dart version $dartConstraintMin is less than $minMinDartVersion';
        }
      }

      // Ensure that if there is also a Flutter constraint, they are consistent.
      if (flutterConstraintMin != null) {
        final Version? dartVersionForFlutterMinimum = getDartSdkForFlutterSdk(
          flutterConstraintMin,
        );
        if (dartVersionForFlutterMinimum == null) {
          return unknownDartVersionError(flutterConstraintMin);
        }
        if (dartVersionForFlutterMinimum != dartConstraintMin) {
          return 'The minimum Dart version is $dartConstraintMin, but the '
              'minimum Flutter version of $flutterConstraintMin shipped with '
              'Dart $dartVersionForFlutterMinimum. Please use consistent lower '
              'SDK bounds';
        }
      }
    }

    return null;
  }

  /// Returns the minumum version allowed by [constraint], or null if the
  /// constraint is null.
  Version? _minimumForConstraint(VersionConstraint? constraint) {
    if (constraint == null) {
      return null;
    }
    Version? result;
    if (constraint is VersionRange) {
      result = constraint.min;
    }
    return result ?? Version.none;
  }

  // Validates the dependencies for a package, returning an error string if
  // there are any that aren't allowed.
  String? _checkDependencies(Pubspec pubspec) {
    final badDependencies = <String>{};
    final misplacedDevDependencies = <String>{};
    // Shipped dependencies.
    for (final dependencies in <Map<String, Dependency>>[
      pubspec.dependencies,
      pubspec.devDependencies,
    ]) {
      dependencies.forEach((String name, Dependency dependency) {
        if (!_shouldAllowDependency(name, dependency)) {
          badDependencies.add(name);
        }
      });
    }

    // Ensure that dev-only dependencies aren't in `dependencies`.
    const devOnlyDependencies = <String>{
      'build_runner',
      'integration_test',
      'flutter_test',
      'leak_tracker_flutter_testing',
      'mockito',
      'pigeon',
      'test',
    };
    // Non-published packages like pigeon subpackages are allowed to violate
    // the dev only dependencies rule, as are packages that end in `_test` (as
    // they are assumed to be intended to be used as dev_dependencies by
    // clients).
    if (pubspec.publishTo != 'none' && !pubspec.name.endsWith('_test')) {
      pubspec.dependencies.forEach((String name, Dependency dependency) {
        if (devOnlyDependencies.contains(name)) {
          misplacedDevDependencies.add(name);
        }
      });
    }

    final errors = <String>[
      if (badDependencies.isNotEmpty)
        '''
The following unexpected non-local dependencies were found:
${badDependencies.map((String name) => '  $name').join('\n')}
Please see https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#Dependencies
for more information and next steps.
''',
      if (misplacedDevDependencies.isNotEmpty)
        '''
The following dev dependencies were found in the dependencies section:
${misplacedDevDependencies.map((String name) => '  $name').join('\n')}
Please move them to dev_dependencies.
''',
    ];
    return errors.isEmpty ? null : errors.join('\n\n');
  }

  // Checks whether a given dependency is allowed.
  // Defaults to false.
  bool _shouldAllowDependency(String name, Dependency dependency) {
    if (dependency is PathDependency || dependency is SdkDependency) {
      return true;
    }
    if (_allowedPackages.local.contains(name) ||
        _allowedPackages.unpinned.contains(name)) {
      return true;
    }
    if (dependency is HostedDependency &&
        _allowedPackages.pinned.contains(name)) {
      final VersionConstraint constraint = dependency.version;
      if (constraint is VersionRange &&
          constraint.min != null &&
          constraint.max != null &&
          constraint.includeMin &&
          constraint.includeMax) {
        return true;
      }
    }
    return false;
  }
}
