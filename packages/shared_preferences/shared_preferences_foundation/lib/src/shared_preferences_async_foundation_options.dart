// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences_platform_interface/types.dart';

/// Options for the Foundation specific SharedPreferences plugin.
@immutable
class SharedPreferencesAsyncFoundationOptions extends SharedPreferencesOptions {
  /// Creates a new instance with the given options.
  SharedPreferencesAsyncFoundationOptions({this.suiteName}) {
    // Ensure that use of suite is compliant with required reason API category 1C8F.1; see
    // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api
    if (Platform.isIOS && !(suiteName?.startsWith('group.') ?? true)) {
      throw ArgumentError('iOS suite name must begin with "group."');
    }
  }

  /// Name of Foundation suite to get/set to.
  ///
  /// On iOS this represents a container ID which must begin with `group.`
  /// followed by a custom string in reverse DNS notation.
  ///
  /// If this option is not set, the default NSUserDefaults will be used.
  final String? suiteName;

  /// Returns a new instance of [SharedPreferencesAsyncFoundationOptions] from an existing
  /// [SharedPreferencesOptions].
  static SharedPreferencesAsyncFoundationOptions fromSharedPreferencesOptions(
    SharedPreferencesOptions options,
  ) {
    if (options is SharedPreferencesAsyncFoundationOptions) {
      return options;
    }
    return SharedPreferencesAsyncFoundationOptions();
  }
}
