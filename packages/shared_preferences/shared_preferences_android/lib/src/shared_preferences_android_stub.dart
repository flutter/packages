// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

export 'shared_preferences_async_android_options.dart';

// Stub of the public API surface for platforms without FFI (e.g., web), where
// the real JNI-based implementation can't be compiled. The plugin classes are
// never registered on those platforms, so their methods should never actually
// be called.

/// The Android implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for Android.
class SharedPreferencesAndroid extends SharedPreferencesStorePlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesAndroid();

  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(_unsupportedMessage);
}

/// The Android implementation of [SharedPreferencesAsyncPlatform].
///
/// This class implements the `package:shared_preferences` functionality for Android.
base class SharedPreferencesAsyncAndroid extends SharedPreferencesAsyncPlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesAsyncAndroid();

  /// Registers this class as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(_unsupportedMessage);
}

const String _unsupportedMessage = 'shared_preferences_android is only supported on Android.';
