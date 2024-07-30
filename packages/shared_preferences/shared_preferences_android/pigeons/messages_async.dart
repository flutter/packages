// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  input: 'pigeons/messages_async.dart',
  kotlinOut:
      'android/src/main/kotlin/io/flutter/plugins/sharedpreferences/MessagesAsync.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'io.flutter.plugins.sharedpreferences',
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
  void setBool(String key, bool value, SharedPreferencesPigeonOptions options);

  /// Adds property to shared preferences data set of type String.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void setString(
    String key,
    String value,
    SharedPreferencesPigeonOptions options,
  );

  /// Adds property to shared preferences data set of type int.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void setInt(
    String key,
    int value,
    SharedPreferencesPigeonOptions options,
  );

  /// Adds property to shared preferences data set of type double.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void setDouble(
    String key,
    double value,
    SharedPreferencesPigeonOptions options,
  );

  /// Adds property to shared preferences data set of type List<String>.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void setStringList(
    String key,
    List<String> value,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual String value stored with [key], if any.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  String? getString(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual  void value stored with [key], if any.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool? getBool(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual double value stored with [key], if any.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  double? getDouble(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual int value stored with [key], if any.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  int? getInt(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Gets individual List<String> value stored with [key], if any.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  List<String>? getStringList(
    String key,
    SharedPreferencesPigeonOptions options,
  );

  /// Removes all properties from shared preferences data set with matching prefix.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void clear(
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
