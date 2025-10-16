// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/ios_ima_settings.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_ima_settings.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ima_settings_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<IMASettings>()])
void main() {
  group('IOSImaSettings', () {
    setUp(() {
      PigeonOverrides.pigeon_reset();
    });

    test('language', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const String language = 'en';
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(language: language),
      );

      // Trigger lazy initialization.
      // ignore: unnecessary_statements
      settings.nativeSettings;

      verify(mockIMASettings.setLanguage(language));
    });

    test('setAutoPlayAdBreaks', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const bool autoPlayAdBreaks = true;
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setAutoPlayAdBreaks(autoPlayAdBreaks);

      verify(mockIMASettings.setAutoPlayAdBreaks(autoPlayAdBreaks));
    });

    test('setDebugMode', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const bool debugMode = false;
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setDebugMode(debugMode);

      verify(mockIMASettings.setEnableDebugMode(debugMode));
    });

    test('setFeatureFlags', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const Map<String, String> featureFlags = <String, String>{'a': 'flag'};
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setFeatureFlags(featureFlags);

      verify(mockIMASettings.setFeatureFlags(featureFlags));
    });

    test('setMaxRedirects', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const int maxRedirects = 12;
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setMaxRedirects(maxRedirects);

      verify(mockIMASettings.setMaxRedirects(maxRedirects));
    });

    test('setPlayerType', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const String playerType = 'playerType';
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setPlayerType(playerType);

      verify(mockIMASettings.setPlayerType(playerType));
    });

    test('setPlayerVersion', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const String playerVersion = 'playerVersion';
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setPlayerVersion(playerVersion);

      verify(mockIMASettings.setPlayerVersion(playerVersion));
    });

    test('setPpid', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const String ppid = 'ppid';
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setPpid(ppid);

      verify(mockIMASettings.setPPID(ppid));
    });

    test('setSessionID', () async {
      final MockIMASettings mockIMASettings = _mockIMASettings();

      const String sessionID = 'sessionID';
      final IOSImaSettings settings = IOSImaSettings(
        const PlatformImaSettingsCreationParams(),
      );
      await settings.setSessionID(sessionID);

      verify(mockIMASettings.setSessionID(sessionID));
    });
  });
}

MockIMASettings _mockIMASettings() {
  final MockIMASettings mockIMASettings = MockIMASettings();
  PigeonOverrides.iMASettings_new = () => mockIMASettings;

  return mockIMASettings;
}
