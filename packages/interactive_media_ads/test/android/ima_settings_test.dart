// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ima_settings.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/platform_interface/platform_ima_settings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ima_settings_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.ImaSdkFactory>(),
  MockSpec<ima.ImaSdkSettings>(),
])
void main() {
  group('AndroidImaSettings', () {
    setUp(() {
      ima.PigeonOverrides.pigeon_reset();
    });

    test('language', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const language = 'en';
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(language: language),
      );

      await settings.nativeSettingsFuture;
      verify(mockImaSdkSettings.setLanguage(language));
    });

    test('setAutoPlayAdBreaks', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const autoPlayAdBreaks = true;
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setAutoPlayAdBreaks(autoPlayAdBreaks);

      verify(mockImaSdkSettings.setAutoPlayAdBreaks(autoPlayAdBreaks));
    });

    test('setDebugMode', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const debugMode = false;
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setDebugMode(debugMode);

      verify(mockImaSdkSettings.setDebugMode(debugMode));
    });

    test('setFeatureFlags', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const featureFlags = <String, String>{'a': 'flag'};
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setFeatureFlags(featureFlags);

      verify(mockImaSdkSettings.setFeatureFlags(featureFlags));
    });

    test('setMaxRedirects', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const maxRedirects = 12;
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setMaxRedirects(maxRedirects);

      verify(mockImaSdkSettings.setMaxRedirects(maxRedirects));
    });

    test('setPlayerType', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const playerType = 'playerType';
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setPlayerType(playerType);

      verify(mockImaSdkSettings.setPlayerType(playerType));
    });

    test('setPlayerVersion', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const playerVersion = 'playerVersion';
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setPlayerVersion(playerVersion);

      verify(mockImaSdkSettings.setPlayerVersion(playerVersion));
    });

    test('setPpid', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const ppid = 'ppid';
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setPpid(ppid);

      verify(mockImaSdkSettings.setPpid(ppid));
    });

    test('setSessionID', () async {
      final MockImaSdkSettings mockImaSdkSettings = _mockImaSdkSettings();

      const sessionID = 'sessionID';
      final settings = AndroidImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setSessionID(sessionID);

      verify(mockImaSdkSettings.setSessionId(sessionID));
    });
  });
}

MockImaSdkSettings _mockImaSdkSettings() {
  final mockImaSdkFactory = MockImaSdkFactory();
  final mockImaSdkSettings = MockImaSdkSettings();
  when(
    mockImaSdkFactory.createImaSdkSettings(),
  ).thenAnswer((_) async => mockImaSdkSettings);
  ima.PigeonOverrides.imaSdkFactory_instance = mockImaSdkFactory;

  return mockImaSdkSettings;
}
