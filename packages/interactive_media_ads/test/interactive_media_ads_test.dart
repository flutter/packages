// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/interactive_media_ads_method_channel.dart';
import 'package:interactive_media_ads/interactive_media_ads_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  final InteractiveMediaAdsPlatform initialPlatform =
      InteractiveMediaAdsPlatform.instance;

  test('$MethodChannelInteractiveMediaAds is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInteractiveMediaAds>());
  });

  test('getPlatformVersion', () async {
  });
}
