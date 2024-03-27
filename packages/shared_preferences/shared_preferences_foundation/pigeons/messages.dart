// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/messages.g.dart',
  dartTestOut: 'test/test_api.g.dart',
  swiftOut: 'darwin/Classes/messages.g.swift',
  copyrightHeader: 'pigeons/copyright_header.txt',
))
@HostApi(dartHostTestHandler: 'TestUserDefaultsApi')
abstract class DeprecatedUserDefaultsApi {
  void remove(String key);
  void setBool(String key, bool value);
  void setDouble(String key, double value);
  void setValue(String key, Object value);
  Map<String?, Object?> getAll(String prefix, List<String>? allowList);
  bool clear(String prefix, List<String>? allowList);
}

class SharedPreferencesPigeonOptions {
  SharedPreferencesPigeonOptions({
    this.suiteName,
  });
  String? suiteName;
}

@HostApi(dartHostTestHandler: 'TestSharedPreferencesAsyncApi')
abstract class UserDefaultsApi {
  /// Adds property to shared preferences data set of type String.
  void setValue(
    String key,
    Object value,
    SharedPreferencesPigeonOptions options,
  );

  /// Removes all properties from shared preferences data set with matching prefix.
  void clear(
    List<String>? allowList,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets all properties from shared preferences data set with matching prefix.
  Map<String, Object> getAll(
    List<String>? allowList,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual value stored with [key], if any.
  Object? getValue(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual String value stored with [key], if any.
  String? getString(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual List<String> value stored with [key], if any.
  List<String>? getStringList(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets all properties from shared preferences data set with matching prefix.
  List<String> getKeys(
    List<String>? allowList,
    SharedPreferencesPigeonOptions options,
  );
}
