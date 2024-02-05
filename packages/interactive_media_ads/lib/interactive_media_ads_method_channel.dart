// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'interactive_media_ads_platform_interface.dart';

/// An implementation of [InteractiveMediaAdsPlatform] that uses method channels.
class MethodChannelInteractiveMediaAds extends InteractiveMediaAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('interactive_media_ads');

  @override
  Future<String?> getPlatformVersion() async {
    final String? version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
