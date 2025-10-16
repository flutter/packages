// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_ima_settings.dart';

import 'test_stubs.dart';

void main() {
  test('setAutoPlayAdBreaks', () async {
    const bool autoPlayAdBreaks = false;
    final TestImaSettings platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetAutoPlayAdBreaks: expectAsync1((bool value) {
        expect(autoPlayAdBreaks, value);
      }),
    );

    final ImaSettings settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setAutoPlayAdBreaks(autoPlayAdBreaks);
  });

  test('setDebugMode', () async {
    const bool debugMode = true;
    final TestImaSettings platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetDebugMode: expectAsync1((bool value) {
        expect(debugMode, value);
      }),
    );

    final ImaSettings settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setDebugMode(debugMode);
  });

  test('setFeatureFlags', () async {
    const Map<String, String> featureFlags = <String, String>{};
    final TestImaSettings platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetFeatureFlags: expectAsync1((Map<String, String> value) {
        expect(featureFlags, value);
      }),
    );

    final ImaSettings settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setFeatureFlags(featureFlags);
  });

  test('setMaxRedirects', () async {
    const int maxRedirects = 11;
    final TestImaSettings platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetMaxRedirects: expectAsync1((int value) {
        expect(maxRedirects, value);
      }),
    );

    final ImaSettings settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setMaxRedirects(maxRedirects);
  });

  test('setPlayerType', () async {
    const String playerType = 'playerType';
    final TestImaSettings platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetPlayerType: expectAsync1((String value) {
        expect(playerType, value);
      }),
    );

    final ImaSettings settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setPlayerType(playerType);
  });

  test('setPlayerVersion', () async {
    const String playerVersion = 'playerVersion';
    final TestImaSettings platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetPlayerVersion: expectAsync1((String value) {
        expect(playerVersion, value);
      }),
    );

    final ImaSettings settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setPlayerVersion(playerVersion);
  });

  test('setPpid', () async {
    const String ppid = 'ppid';
    final TestImaSettings platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetPpid: expectAsync1((String value) {
        expect(ppid, value);
      }),
    );

    final ImaSettings settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setPpid(ppid);
  });

  test('setSessionID', () async {
    const String sessionID = 'session';
    final TestImaSettings platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetSessionID: expectAsync1((String value) {
        expect(sessionID, value);
      }),
    );

    final ImaSettings settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setSessionID(sessionID);
  });
}
