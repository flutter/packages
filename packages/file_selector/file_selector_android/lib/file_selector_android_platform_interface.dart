// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'file_selector_android_method_channel.dart';

abstract class FileSelectorAndroidPlatform extends PlatformInterface {
  /// Constructs a FileSelectorAndroidPlatform.
  FileSelectorAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static FileSelectorAndroidPlatform _instance =
      MethodChannelFileSelectorAndroid();

  /// The default instance of [FileSelectorAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelFileSelectorAndroid].
  static FileSelectorAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FileSelectorAndroidPlatform] when
  /// they register themselves.
  static set instance(FileSelectorAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
