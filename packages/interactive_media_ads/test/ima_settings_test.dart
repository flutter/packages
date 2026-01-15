// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_ima_settings.dart';

import 'test_stubs.dart';

void main() {
  test('setAutoPlayAdBreaks', () async {
    const autoPlayAdBreaks = false;
    final platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetAutoPlayAdBreaks: expectAsync1((bool value) {
        expect(autoPlayAdBreaks, value);
      }),
    );

    final settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setAutoPlayAdBreaks(autoPlayAdBreaks);
  });

  test('setDebugMode', () async {
    const debugMode = true;
    final platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetDebugMode: expectAsync1((bool value) {
        expect(debugMode, value);
      }),
    );

    final settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setDebugMode(debugMode);
  });

  test('setFeatureFlags', () async {
    const featureFlags = <String, String>{};
    final platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetFeatureFlags: expectAsync1((Map<String, String> value) {
        expect(featureFlags, value);
      }),
    );

    final settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setFeatureFlags(featureFlags);
  });

  test('setMaxRedirects', () async {
    const maxRedirects = 11;
    final platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetMaxRedirects: expectAsync1((int value) {
        expect(maxRedirects, value);
      }),
    );

    final settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setMaxRedirects(maxRedirects);
  });

  test('setPlayerType', () async {
    const playerType = 'playerType';
    final platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetPlayerType: expectAsync1((String value) {
        expect(playerType, value);
      }),
    );

    final settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setPlayerType(playerType);
  });

  test('setPlayerVersion', () async {
    const playerVersion = 'playerVersion';
    final platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetPlayerVersion: expectAsync1((String value) {
        expect(playerVersion, value);
      }),
    );

    final settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setPlayerVersion(playerVersion);
  });

  test('setPpid', () async {
    const ppid = 'ppid';
    final platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetPpid: expectAsync1((String value) {
        expect(ppid, value);
      }),
    );

    final settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setPpid(ppid);
  });

  test('setSessionID', () async {
    const sessionID = 'session';
    final platformSettings = TestImaSettings(
      const PlatformImaSettingsCreationParams(),
      onSetSessionID: expectAsync1((String value) {
        expect(sessionID, value);
      }),
    );

    final settings = ImaSettings.fromPlatform(platformSettings);
    await settings.setSessionID(sessionID);
  });
}
