// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    input: 'pigeons/messages_async.dart',
    kotlinOut: 'android/src/main/kotlin/io/flutter/plugins/sharedpreferences/MessagesAsync.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.sharedpreferences',
      errorClassName: 'SharedPreferencesError',
      useJni: true,
      appDirectory: 'example/',
    ),
    dartOut: 'lib/src/messages_async.g.dart',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Possible types found during a getStringList call.
enum StringListLookupResultType {
  /// A deprecated platform-side encoding string list.
  platformEncoded,

  /// A JSON-encoded string list.
  jsonEncoded,

  /// A string that doesn't have the expected encoding prefix.
  unexpectedString,

  // There is no type for non-string values, as those will throw an exception
  // on the native side, so don't need a return value.
}

class SharedPreferencesPigeonOptions {
  SharedPreferencesPigeonOptions({this.fileName, this.useDataStore = true});
  String? fileName;
  bool useDataStore;
}

class StringListResult {
  StringListResult({required this.jsonEncodedValue, required this.type});

  /// The JSON-encoded stored value, or null if something else was found.
  String? jsonEncodedValue;

  /// The type of value found.
  StringListLookupResultType type;
}

@HostApi()
abstract class SharedPreferencesAsyncApi {
  /// Adds property to shared preferences data set of type `bool`.
  @async
  void setBool(String key, bool value, SharedPreferencesPigeonOptions options);

  /// Adds property to shared preferences data set of type `String`.
  @async
  void setString(String key, String value, SharedPreferencesPigeonOptions options);

  /// Adds property to shared preferences data set of type `int`.
  @async
  void setInt(String key, int value, SharedPreferencesPigeonOptions options);

  /// Adds property to shared preferences data set of type `double`.
  @async
  void setDouble(String key, double value, SharedPreferencesPigeonOptions options);

  /// Adds property to shared preferences data set of type `List<String>`.
  @async
  void setEncodedStringList(String key, String value, SharedPreferencesPigeonOptions options);

  /// Adds property to shared preferences data set of type `List<String>`.
  ///
  /// Deprecated, this is only here for testing purposes.
  @async
  void setDeprecatedStringList(
    String key,
    List<String> value,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual String value stored with [key], if any.
  @async
  String? getString(String key, SharedPreferencesPigeonOptions options);

  /// Gets individual  void value stored with [key], if any.
  @async
  bool? getBool(String key, SharedPreferencesPigeonOptions options);

  /// Gets individual double value stored with [key], if any.
  @async
  double? getDouble(String key, SharedPreferencesPigeonOptions options);

  /// Gets individual int value stored with [key], if any.
  @async
  int? getInt(String key, SharedPreferencesPigeonOptions options);

  /// Gets individual `List<String>` value stored with [key], if any.
  @async
  List<String>? getPlatformEncodedStringList(String key, SharedPreferencesPigeonOptions options);

  /// Gets the JSON-encoded `List<String>` value stored with [key], if any.
  @async
  StringListResult? getStringList(String key, SharedPreferencesPigeonOptions options);

  /// Removes all properties from shared preferences data set with matching prefix.
  @async
  void clear(List<String>? allowList, SharedPreferencesPigeonOptions options);

  /// Gets all properties from shared preferences data set with matching prefix.
  @async
  Map<String, Object> getAll(List<String>? allowList, SharedPreferencesPigeonOptions options);

  /// Gets all properties from shared preferences data set with matching prefix.
  @async
  List<String> getKeys(List<String>? allowList, SharedPreferencesPigeonOptions options);
}
