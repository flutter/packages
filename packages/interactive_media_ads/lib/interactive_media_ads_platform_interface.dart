// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'interactive_media_ads_method_channel.dart';

abstract class InteractiveMediaAdsPlatform extends PlatformInterface {
  /// Constructs a InteractiveMediaAdsPlatform.
  InteractiveMediaAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  static InteractiveMediaAdsPlatform _instance =
      MethodChannelInteractiveMediaAds();

  /// The default instance of [InteractiveMediaAdsPlatform] to use.
  ///
  /// Defaults to [MethodChannelInteractiveMediaAds].
  static InteractiveMediaAdsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InteractiveMediaAdsPlatform] when
  /// they register themselves.
  static set instance(InteractiveMediaAdsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
