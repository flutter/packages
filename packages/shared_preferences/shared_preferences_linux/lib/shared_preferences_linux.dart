// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show json;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:path/path.dart' as path;
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

const String _defaultFileName = 'shared_preferences';

const String _defaultPrefix = 'flutter.';

/// The Linux implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for Linux.
class SharedPreferencesLinux extends SharedPreferencesStorePlatform {
  /// Deprecated instance of [SharedPreferencesLinux].
  /// Use [SharedPreferencesStorePlatform.instance] instead.
  @Deprecated('Use `SharedPreferencesStorePlatform.instance` instead.')
  static SharedPreferencesLinux instance = SharedPreferencesLinux();

  /// Registers the Linux implementation.
  static void registerWith() {
    SharedPreferencesStorePlatform.instance = SharedPreferencesLinux();
    // A temporary work-around for having two plugins contained in a single package.
    SharedPreferencesAsyncLinux.registerWith();
  }

  /// Local copy of preferences
  Map<String, Object>? _cachedPreferences;

  /// File system used to store to disk. Exposed for testing only.
  @visibleForTesting
  FileSystem fs = const LocalFileSystem();

  /// The path_provider_linux instance used to find the support directory.
  @visibleForTesting
  PathProviderLinux pathProvider = PathProviderLinux();

  /// Checks for cached preferences and returns them or loads preferences from
  /// file and returns and caches them.
  Future<Map<String, Object>> _readPreferences() async {
    _cachedPreferences ??= await _reload(
      _defaultFileName,
      fs: fs,
      pathProvider: pathProvider,
    );
    return _cachedPreferences!;
  }

  @override
  Future<bool> clear() async {
    return clearWithParameters(
      ClearParameters(
        filter: PreferencesFilter(prefix: _defaultPrefix),
      ),
    );
  }

  @override
  Future<bool> clearWithPrefix(String prefix) async {
    return clearWithParameters(
        ClearParameters(filter: PreferencesFilter(prefix: prefix)));
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async {
    final PreferencesFilter filter = parameters.filter;

    final Map<String, Object> preferences = await _readPreferences();
    preferences.removeWhere((String key, _) =>
        key.startsWith(filter.prefix) &&
        (filter.allowList == null || filter.allowList!.contains(key)));
    return _writePreferences(
      preferences,
      _defaultFileName,
      fs: fs,
      pathProvider: pathProvider,
    );
  }

  @override
  Future<Map<String, Object>> getAll() async {
    return getAllWithParameters(
      GetAllParameters(
        filter: PreferencesFilter(prefix: _defaultPrefix),
      ),
    );
  }

  @override
  Future<Map<String, Object>> getAllWithPrefix(String prefix) async {
    return getAllWithParameters(
        GetAllParameters(filter: PreferencesFilter(prefix: prefix)));
  }

  @override
  Future<Map<String, Object>> getAllWithParameters(
      GetAllParameters parameters) async {
    final PreferencesFilter filter = parameters.filter;
    final Map<String, Object> withPrefix =
        Map<String, Object>.from(await _readPreferences());
    withPrefix.removeWhere((String key, _) => !(key.startsWith(filter.prefix) &&
        (filter.allowList?.contains(key) ?? true)));
    return withPrefix;
  }

  @override
  Future<bool> remove(String key) async {
    final Map<String, Object> preferences = await _readPreferences();
    preferences.remove(key);
    return _writePreferences(
      preferences,
      _defaultFileName,
      fs: fs,
      pathProvider: pathProvider,
    );
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    final Map<String, Object> preferences = await _readPreferences();
    preferences[key] = value;
    return _writePreferences(
      preferences,
      _defaultFileName,
      fs: fs,
      pathProvider: pathProvider,
    );
  }
}

/// The Linux implementation of [SharedPreferencesAsyncPlatform].
///
/// This class implements the `package:shared_preferences` functionality for Linux.
base class SharedPreferencesAsyncLinux extends SharedPreferencesAsyncPlatform {
  /// Registers the Linux implementation.
  static void registerWith() {
    SharedPreferencesAsyncPlatform.instance = SharedPreferencesAsyncLinux();
  }

  /// Local copy of preferences
  Map<String, Object>? _cachedPreferences;

  /// File system used to store to disk. Exposed for testing only.
  @visibleForTesting
  FileSystem fs = const LocalFileSystem();

  /// The path_provider_linux instance used to find the support directory.
  @visibleForTesting
  PathProviderLinux pathProvider = PathProviderLinux();

  @override
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    return (await getPreferences(parameters, options)).keys.toSet();
  }

  @override
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  ) {
    return _setValue(key, value, options);
  }

  @override
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data = await _readAll(<String>{key}, options);
    return data[key] as String?;
  }

  @override
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data = await _readAll(<String>{key}, options);
    return data[key] as bool?;
  }

  @override
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data = await _readAll(<String>{key}, options);
    return data[key] as double?;
  }

  @override
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data = await _readAll(<String>{key}, options);
    return data[key] as int?;
  }

  @override
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  ) async {
    final Map<String, Object> data = await _readAll(<String>{key}, options);
    return (data[key] as List<Object?>?)?.cast<String>().toList();
  }

  @override
  Future<void> clear(ClearPreferencesParameters parameters,
      SharedPreferencesOptions options) async {
    final SharedPreferencesLinuxOptions linuxOptions =
        SharedPreferencesLinuxOptions.fromSharedPreferencesOptions(options);
    final PreferencesFilters filter = parameters.filter;
    final Map<String, Object> preferences =
        await _readPreferences(linuxOptions.fileName);
    preferences.removeWhere((String key, _) =>
        filter.allowList == null || filter.allowList!.contains(key));
    await _writePreferences(
      preferences,
      linuxOptions.fileName,
      fs: fs,
      pathProvider: pathProvider,
    );
  }

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) async {
    return _readAll(parameters.filter.allowList, options);
  }

  /// Reloads preferences from file.
  @visibleForTesting
  Future<void> reload(
    SharedPreferencesLinuxOptions options,
  ) async {
    _cachedPreferences = await _reload(options.fileName);
  }

  Future<Map<String, Object>> _readAll(
    Set<String>? allowList,
    SharedPreferencesOptions options,
  ) async {
    final SharedPreferencesLinuxOptions linuxOptions =
        SharedPreferencesLinuxOptions.fromSharedPreferencesOptions(options);
    final Map<String, Object> prefs =
        Map<String, Object>.from(await _readPreferences(linuxOptions.fileName));
    prefs.removeWhere((String key, _) => !(allowList?.contains(key) ?? true));
    return prefs;
  }

  Future<void> _setValue(
      String key, Object value, SharedPreferencesOptions options) async {
    final SharedPreferencesLinuxOptions linuxOptions =
        SharedPreferencesLinuxOptions.fromSharedPreferencesOptions(options);
    final Map<String, Object> preferences =
        await _readPreferences(linuxOptions.fileName);
    preferences[key] = value;
    await _writePreferences(
      preferences,
      linuxOptions.fileName,
      fs: fs,
      pathProvider: pathProvider,
    );
  }

  /// Checks for cached preferences and returns them or loads preferences from
  /// file and returns and caches them.
  Future<Map<String, Object>> _readPreferences(String fileName) async {
    _cachedPreferences ??= await _reload(
      fileName,
      fs: fs,
      pathProvider: pathProvider,
    );
    return _cachedPreferences!;
  }
}

/// Gets the file where the preferences are stored.
Future<File?> _getLocalDataFile(
  String fileName, {
  FileSystem fs = const LocalFileSystem(),
  PathProviderLinux? pathProvider,
}) async {
  pathProvider = pathProvider ?? PathProviderLinux();
  final String? directory = await pathProvider.getApplicationSupportPath();
  if (directory == null) {
    return null;
  }
  final String fileLocation = path.join(directory, '$fileName.json');
  return fs.file(fileLocation);
}

/// Gets the preferences from the stored file and saves them in cache.
Future<Map<String, Object>> _reload(
  String fileName, {
  FileSystem fs = const LocalFileSystem(),
  PathProviderLinux? pathProvider,
}) async {
  Map<String, Object> preferences = <String, Object>{};
  final File? localDataFile = await _getLocalDataFile(
    fileName,
    fs: fs,
    pathProvider: pathProvider,
  );
  if (localDataFile != null && localDataFile.existsSync()) {
    final String stringMap = localDataFile.readAsStringSync();
    if (stringMap.isNotEmpty) {
      final Object? data = json.decode(stringMap);
      if (data is Map) {
        preferences = data.cast<String, Object>();
      }
    }
  }
  return preferences;
}

/// Writes the cached preferences to disk. Returns [true] if the operation
/// succeeded.
Future<bool> _writePreferences(
  Map<String, Object> preferences,
  String fileName, {
  FileSystem fs = const LocalFileSystem(),
  PathProviderLinux? pathProvider,
}) async {
  try {
    final File? localDataFile = await _getLocalDataFile(
      fileName,
      fs: fs,
      pathProvider: pathProvider,
    );
    if (localDataFile == null) {
      debugPrint('Unable to determine where to write preferences.');
      return false;
    }
    if (!localDataFile.existsSync()) {
      localDataFile.createSync(recursive: true);
    }
    final String stringMap = json.encode(preferences);
    localDataFile.writeAsStringSync(stringMap);
  } catch (e) {
    debugPrint('Error saving preferences to disk: $e');
    return false;
  }
  return true;
}

/// Linux specific SharedPreferences Options.
class SharedPreferencesLinuxOptions extends SharedPreferencesOptions {
  /// Constructor for SharedPreferencesLinuxOptions.
  const SharedPreferencesLinuxOptions({
    this.fileName = 'shared_preferences',
  });

  /// The name of the file to store preferences in.
  final String fileName;

  /// Returns a new instance of [SharedPreferencesLinuxOptions] from an existing
  /// [SharedPreferencesOptions].
  static SharedPreferencesLinuxOptions fromSharedPreferencesOptions(
      SharedPreferencesOptions options) {
    if (options is SharedPreferencesLinuxOptions) {
      return options;
    }
    return const SharedPreferencesLinuxOptions();
  }
}
