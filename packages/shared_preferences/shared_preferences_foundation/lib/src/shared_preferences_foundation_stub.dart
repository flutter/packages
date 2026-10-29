// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

export 'shared_preferences_async_foundation_options.dart';

// Stub of the public API surface for platforms without FFI (e.g., web), where
// the real FFI-based implementation can't be compiled. The plugin classes are
// never registered on those platforms, so their methods should never actually
// be called.

/// iOS and macOS implementation of shared_preferences.
class SharedPreferencesFoundation extends SharedPreferencesStorePlatform {
  /// Creates an instance of [SharedPreferencesFoundation].
  SharedPreferencesFoundation();

  /// Registers this class as the default instance of
  /// [SharedPreferencesStorePlatform].
  static void registerWith() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(_unsupportedMessage);
}

/// iOS and macOS implementation of shared_preferences.
base class SharedPreferencesAsyncFoundation extends SharedPreferencesAsyncPlatform {
  /// Creates a new plugin implementation instance.
  SharedPreferencesAsyncFoundation();

  /// Registers this class as the default instance of [SharedPreferencesAsyncPlatform].
  static void registerWith() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(_unsupportedMessage);
}

const String _unsupportedMessage =
    'shared_preferences_foundation is only supported on iOS and macOS.';
