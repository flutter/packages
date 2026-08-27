// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(stuartmorgan): Consider merging this with messages_async.dart now that
//  they both use the Kotlin generator.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    input: 'pigeons/messages.dart',
    kotlinOut: 'android/src/main/kotlin/io/flutter/plugins/sharedpreferences/Messages.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.sharedpreferences',
      useJni: true,
      appDirectory: 'example/',
    ),
    dartOut: 'lib/src/messages.g.dart',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi()
abstract class SharedPreferencesApi {
  /// Removes property from shared preferences data set.
  bool remove(String key);

  /// Adds property to shared preferences data set of type `bool`.
  bool setBool(String key, bool value);

  /// Adds property to shared preferences data set of type `String`.
  bool setString(String key, String value);

  /// Adds property to shared preferences data set of type `int`.
  bool setInt(String key, int value);

  /// Adds property to shared preferences data set of type `double`.
  bool setDouble(String key, double value);

  /// Adds property to shared preferences data set of type `List<String>`.
  bool setEncodedStringList(String key, String value);

  /// Adds property to shared preferences data set of type `List<String>`.
  ///
  /// Deprecated, this is only here for testing purposes.
  bool setDeprecatedStringList(String key, List<String> value);

  /// Removes all properties from shared preferences data set with matching prefix.
  bool clear(String prefix, List<String>? allowList);

  /// Gets all properties from shared preferences data set with matching prefix.
  Map<String, Object> getAll(String prefix, List<String>? allowList);
}
