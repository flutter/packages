// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AdsRequestProxyApi.pluginVersion matches pubspec version', () {
    final String pubspecPath = '${Directory.current.path}/pubspec.yaml';
    final String pubspec = File(pubspecPath).readAsStringSync();
    final RegExp regex = RegExp(r'version:\s*(.*?) #');
    final RegExpMatch? match = regex.firstMatch(pubspec);
    final String pubspecVersion = match!.group(1)!.trim();

    final String adsRequestProxyApiPath =
        '${Directory.current.path}/android/src/main/kotlin/dev/flutter/packages/interactive_media_ads/AdsRequestProxyApi.kt';
    final String apiFileAsString =
        File(adsRequestProxyApiPath).readAsStringSync();

    expect(
      apiFileAsString,
      contains('const val pluginVersion = "$pubspecVersion"'),
    );
  });
}
