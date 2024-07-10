// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AdsRequestProxyApi.pluginVersion matches pubspec version', () {
    final String pubspecVersion = _getPubspecVersion();

    final String adsRequestProxyApiPath =
        '${Directory.current.path}/android/src/main/kotlin/dev/flutter/packages/interactive_media_ads/AdsRequestProxyApi.kt';
    final String apiFileAsString =
        File(adsRequestProxyApiPath).readAsStringSync();

    expect(
      apiFileAsString,
      contains('const val pluginVersion = "$pubspecVersion"'),
    );
  });

  test('AdsRequestProxyAPIDelegate.pluginVersion matches pubspec version', () {
    final String pubspecVersion = _getPubspecVersion();

    final String adsRequestProxyApiDelegatePath =
        '${Directory.current.path}/ios/interactive_media_ads/Sources/interactive_media_ads/AdsRequestProxyAPIDelegate.swift';
    final String apiFileAsString =
        File(adsRequestProxyApiDelegatePath).readAsStringSync();

    expect(
      apiFileAsString,
      contains('static let pluginVersion = "$pubspecVersion"'),
    );
  });
}

String _getPubspecVersion() {
  final String pubspecPath = '${Directory.current.path}/pubspec.yaml';
  final String pubspec = File(pubspecPath).readAsStringSync();

  final RegExp regex = RegExp(r'version:\s*(.*?) #');
  final RegExpMatch? match = regex.firstMatch(pubspec);

  return match!.group(1)!.trim();
}
