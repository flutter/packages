// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(stuartmorgan): Consider merging this with messages_async.dart now that
// they both use the Kotlin generator.

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
  @async
  bool remove(String key);

  /// Adds property to shared preferences data set of type `bool`.
  @async
  bool setBool(String key, bool value);

  /// Adds property to shared preferences data set of type `String`.
  @async
  bool setString(String key, String value);

  /// Adds property to shared preferences data set of type `int`.
  @async
  bool setInt(String key, int value);

  /// Adds property to shared preferences data set of type `double`.
  @async
  bool setDouble(String key, double value);

  /// Adds property to shared preferences data set of type `List<String>`.
  @async
  bool setEncodedStringList(String key, String value);

  /// Adds property to shared preferences data set of type `List<String>`.
  ///
  /// Deprecated, this is only here for testing purposes.
  @async
  bool setDeprecatedStringList(String key, List<String> value);

  /// Removes all properties from shared preferences data set with matching prefix.
  @async
  bool clear(String prefix, List<String>? allowList);

  /// Gets all properties from shared preferences data set with matching prefix.
  @async
  Map<String, Object> getAll(String prefix, List<String>? allowList);
}
