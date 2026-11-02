// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:shared_preferences_platform_interface/types.dart';

/// Used to identify which Android library should be used on the backend of this call.
enum SharedPreferencesAndroidBackendLibrary {
  /// Represents the newer DataStore Preferences library.
  DataStore,

  /// Represents the older SharedPreferences library.
  SharedPreferences,
}

/// Options for the Android specific SharedPreferences plugin.
class SharedPreferencesAsyncAndroidOptions extends SharedPreferencesOptions {
  /// Constructor for SharedPreferencesAsyncAndroidOptions.
  const SharedPreferencesAsyncAndroidOptions({
    this.backend = SharedPreferencesAndroidBackendLibrary.DataStore,
    this.originalSharedPreferencesOptions,
  });

  /// Which backend should be used for this method call.
  final SharedPreferencesAndroidBackendLibrary backend;

  /// These options define how the `SharedPreferences` backend should behave.
  ///
  /// Any options in this field will be ignored unless the backend that is selected
  /// is `SharedPreferences`.
  final AndroidSharedPreferencesStoreOptions? originalSharedPreferencesOptions;
}

/// Options necessary for defining the use of the original `SharedPreferences`
/// library.
///
/// These options are only ever used with the original `SharedPreferences` and
/// have no purpose when using the default DataStore Preferences.
class AndroidSharedPreferencesStoreOptions {
  /// Constructor for AndroidSharedPreferencesStoreOptions.
  const AndroidSharedPreferencesStoreOptions({this.fileName});

  /// The name of the file in which the preferences are stored.
  final String? fileName;
}
