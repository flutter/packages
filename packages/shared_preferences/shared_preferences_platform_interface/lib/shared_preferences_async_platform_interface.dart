// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'types.dart';

/// The interface that implementations of shared_preferences_async must implement.
abstract base class SharedPreferencesAsyncPlatform {
  /// Constructs a SharedPreferencesAsyncPlatform.
  SharedPreferencesAsyncPlatform();

  /// The instance of [SharedPreferencesAsyncPlatform] to use.
  static SharedPreferencesAsyncPlatform? instance;

  /// Stores the String [value] associated with the [key].
  Future<void> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  );

  /// Stores the bool [value] associated with the [key].
  Future<void> setBool(
    String key,
    bool value,
    SharedPreferencesOptions options,
  );

  /// Stores the double [value] associated with the [key].
  Future<void> setDouble(
    String key,
    double value,
    SharedPreferencesOptions options,
  );

  /// Stores the int [value] associated with the [key].
  Future<void> setInt(
    String key,
    int value,
    SharedPreferencesOptions options,
  );

  /// Stores the List<String> [value] associated with the [key].
  Future<void> setStringList(
    String key,
    List<String> value,
    SharedPreferencesOptions options,
  );

  /// Retrieves the String [value] associated with the [key], if any.
  ///
  /// Throws a [TypeError] if the returned type is not a String.
  /// May return null for unsupported types.
  Future<String?> getString(
    String key,
    SharedPreferencesOptions options,
  );

  /// Retrieves the bool [value] associated with the [key], if any.
  ///
  /// Throws a [TypeError] if the returned type is not a bool.
  /// May return null for unsupported types.
  Future<bool?> getBool(
    String key,
    SharedPreferencesOptions options,
  );

  /// Retrieves the double [value] associated with the [key], if any.
  ///
  /// Throws a [TypeError] if the returned type is not a double.
  /// May return null for unsupported types.
  Future<double?> getDouble(
    String key,
    SharedPreferencesOptions options,
  );

  /// Retrieves the int [value] associated with the [key], if any.
  ///
  /// Throws a [TypeError] if the returned type is not an int.
  /// May return null for unsupported types.
  Future<int?> getInt(
    String key,
    SharedPreferencesOptions options,
  );

  /// Retrieves the List<String> [value] associated with the [key], if any.
  ///
  /// Throws a [TypeError] if the returned type is not a List<String>.
  /// May return null for unsupported types.
  Future<List<String>?> getStringList(
    String key,
    SharedPreferencesOptions options,
  );

  /// Removes all keys and values in the store that match the given [parameters].
  Future<void> clear(
    ClearPreferencesParameters parameters,
    SharedPreferencesOptions options,
  );

  /// Returns all key/value pairs persisting in this store that match the given [parameters].
  ///
  /// Does not return unsupported types, or lists containing unsupported types.
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  );

  /// Returns all keys persisting in this store that match the given [parameters].
  ///
  /// Does not return keys for values that are unsupported types, or lists containing
  /// unsupported types.
  Future<Set<String>> getKeys(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  );
}
