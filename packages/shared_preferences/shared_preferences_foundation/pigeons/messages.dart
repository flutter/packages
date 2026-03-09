// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut:
        'darwin/shared_preferences_foundation/Sources/shared_preferences_foundation/messages.g.swift',
    copyrightHeader: 'pigeons/copyright_header.txt',
  ),
)
@HostApi()
abstract class LegacyUserDefaultsApi {
  void remove(String key);
  void setBool(String key, bool value);
  void setDouble(String key, double value);
  void setValue(String key, Object value);
  Map<String, Object> getAll(String prefix, List<String>? allowList);
  bool clear(String prefix, List<String>? allowList);
}

@HostApi()
abstract class UserDefaultsApi {
  /// Adds property to shared preferences data set of type String.
  @SwiftFunction('set(key:value:options:)')
  void set(String key, Object value, String? suiteName);

  /// Removes all properties from shared preferences data set with matching prefix.
  void clear(List<String>? allowList, String? suiteName);

  /// Gets all properties from shared preferences data set with matching prefix.
  Map<String, Object> getAll(List<String>? allowList, String? suiteName);

  /// Gets individual value stored with [key], if any.
  Object? getValue(String key, String? suiteName);

  /// Gets all properties from shared preferences data set with matching prefix.
  List<String> getKeys(List<String>? allowList, String? suiteName);
}
