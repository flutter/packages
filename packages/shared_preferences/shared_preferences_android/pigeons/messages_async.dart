// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  input: 'pigeons/messages_async.dart',
  kotlinOut:
      'android/src/main/kotlin/com/flutter/plugins/shared_preferences/MessagesAsync.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.flutter.plugins.shared_preferences_async',
    errorClassName: 'SharedPreferencesError',
  ),
  dartOut: 'lib/src/messages_async.g.dart',
  copyrightHeader: 'pigeons/copyright.txt',
))
class SharedPreferencesPigeonOptions {
  SharedPreferencesPigeonOptions({
    this.fileKey,
  });
  String? fileKey;
}

@HostApi(dartHostTestHandler: 'TestSharedPreferencesAsyncApi')
abstract class SharedPreferencesAsyncApi {
  /// Adds property to shared preferences data set of type bool.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setBool(String key, bool value, SharedPreferencesPigeonOptions options);

  /// Adds property to shared preferences data set of type String.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setString(
    String key,
    String value,
    SharedPreferencesPigeonOptions options,
  );

  /// Adds property to shared preferences data set of type int.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setInt(
    String key,
    int value,
    SharedPreferencesPigeonOptions options,
  );

  /// Adds property to shared preferences data set of type double.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setDouble(
    String key,
    double value,
    SharedPreferencesPigeonOptions options,
  );

  /// Adds property to shared preferences data set of type List<String>.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setStringList(
    String key,
    List<String> value,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual String value stored with [key], if any.
  String? getString(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual bool value stored with [key], if any.
  bool? getBool(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual double value stored with [key], if any.
  double? getDouble(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual int value stored with [key], if any.
  int? getInt(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual List<String> value stored with [key], if any.
  List<String>? getStringList(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Removes all properties from shared preferences data set with matching prefix.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool clear(
    List<String>? allowList,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets all properties from shared preferences data set with matching prefix.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  Map<String, Object> getAll(
    List<String>? allowList,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets all properties from shared preferences data set with matching prefix.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  List<String> getKeys(
    List<String>? allowList,
    SharedPreferencesPigeonOptions options,
  );
}
