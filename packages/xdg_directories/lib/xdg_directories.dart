library xdg_directories;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:process/process.dart';

typedef EnvironmentOverride = String Function(String envVar);

@visibleForTesting
set xdgEnvironmentOverride(EnvironmentOverride override) => _getenv = override ?? _productionGetEnv;
EnvironmentOverride _productionGetEnv = (String value) => Platform.environment[value];
EnvironmentOverride _getenv = _productionGetEnv;

@visibleForTesting
set xdgProcessManager(ProcessManager processManager) {
  _processManager = processManager;
}

ProcessManager _processManager = const LocalProcessManager();

List<Directory> _directoryListFromEnvironment(String envVar, String fallback) {
  assert(envVar != null);
  assert(fallback != null);
  String value = _getenv(envVar);
  if (value == null || value.isEmpty) {
    value = fallback;
  }
  return value.split(':').where((String value) {
    return value.isNotEmpty;
  }).map<Directory>((String entry) {
    return Directory(entry);
  }).toList();
}

Directory _directoryFromEnvironment(String envVar, String fallback) {
  assert(envVar != null);
  final String value = _getenv(envVar);
  if (value == null || value.isEmpty) {
    if (fallback == null) {
      return null;
    }
    return _getDefaultDir(fallback);
  }
  return Directory(value);
}

Directory _getDefaultDir(String suffix) {
  assert(suffix != null);
  assert(suffix.isNotEmpty);
  final String homeDir = _getenv('HOME');
  if (homeDir == null || homeDir.isEmpty) {
    throw StateError('The "HOME" environment variable is not set. This package (and POSIX) '
        'requires that HOME be set.');
  }
  return Directory(path.joinAll(<String>[homeDir, suffix]));
}

/// The base directory relative to which user-specific
/// non-essential (cached) data should be written. (Corresponds to
/// `$XDG_CACHE_HOME`).
///
/// Throws [StateError] if the HOME environment variable is not set.
Directory get cacheHome => _directoryFromEnvironment('XDG_CACHE_HOME', '.cache');

/// The list of preference-ordered base directories relative to
/// which configuration files should be searched. (Corresponds to
/// `$XDG_CONFIG_DIRS`).
///
/// Throws [StateError] if the HOME environment variable is not set.
List<Directory> get configDirs => _directoryListFromEnvironment('XDG_CONFIG_DIRS', '/etc/xdg');

/// The a single base directory relative to which user-specific
/// configuration files should be written. (Corresponds to `$XDG_CONFIG_HOME`).
///
/// Throws [StateError] if the HOME environment variable is not set.
Directory get configHome => _directoryFromEnvironment('XDG_CONFIG_HOME', '.config');

/// The list of preference-ordered base directories relative to
/// which data files should be searched. (Corresponds to `$XDG_DATA_DIRS`).
///
/// Throws [StateError] if the HOME environment variable is not set.
List<Directory> get dataDirs => _directoryListFromEnvironment('XDG_DATA_DIRS', '/usr/local/share:/usr/share');

/// The base directory relative to which user-specific data files should be
/// written. (Corresponds to `$XDG_DATA_HOME`).
///
/// Throws [StateError] if the HOME environment variable is not set.
Directory get dataHome => _directoryFromEnvironment('XDG_DATA_HOME', '.local/share');

/// The base directory relative to which user-specific runtime
/// files and other file objects should be placed. (Corresponds to
/// `$XDG_RUNTIME_DIR`).
///
/// Throws [StateError] if the HOME environment variable is not set.
Directory get runtimeDir => _directoryFromEnvironment('XDG_RUNTIME_DIR', null);

Directory _getUserDir(String dirName) {
  final ProcessResult result = _processManager.runSync(
    <String>['xdg-user-dir', dirName],
    // Copy these env vars from the override so that the tests can override them.
    environment: <String, String>{
      'HOME': _getenv('HOME'),
      'XDG_CONFIG_HOME': _getenv('XDG_CONFIG_HOME'),
    },
    includeParentEnvironment: true,
    stdoutEncoding: Encoding.getByName('utf8'),
  );
  final String path = utf8.decode(result.stdout).split('\n')[0];
  return Directory(path);
}

/// The list of user directories defined in the `xdg`
/// configuration files.
///
/// Reads the file [configHome]`/user-dirs.dirs` to get the information from it.
///
/// The map keys are the name of the configuration variable, with `XDG_`
/// stripped from the beginning of the name, and `_DIR` stripped from the
/// end. They are typically uppercase.
///
/// Throws [StateError] if the HOME environment variable is not set.
Map<String, Directory> getUserDirs() {
  final File configFile = File(path.join(configHome.path, 'user-dirs.dirs'));
  List<String> contents;
  try {
    contents = configFile.readAsLinesSync();
  } on FileSystemException catch (e) {
    return const <String, Directory>{};
  }
  final Map<String, Directory> result = <String, Directory>{};
  final RegExp dirRegExp = RegExp(r'^\s*XDG_(?<dirname>.*)_DIR\s*=\s*(?<dir>.*)\s*$');
  for (String line in contents) {
    final RegExpMatch match = dirRegExp.firstMatch(line);
    if (match == null) {
      continue;
    }
    result[match.namedGroup('dirname')] = _getUserDir(match.namedGroup('dirname'));
  }
  return result;
}
