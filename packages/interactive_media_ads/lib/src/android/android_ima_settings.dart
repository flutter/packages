// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_ima_settings.dart';
import 'interactive_media_ads.g.dart';

/// Android implementation of [PlatformImaSettings].
final class AndroidImaSettings extends PlatformImaSettings {
  /// Constructs an [AndroidImaSettings].
  AndroidImaSettings(super.params) : super.implementation();

  /// The native Android ImaSdkSettings.
  ///
  /// Defines general SDK settings that are used when creating an `AdsLoader`.
  @internal
  late final Future<ImaSdkSettings> nativeSettingsFuture = _createSettings();

  @override
  Future<void> setAutoPlayAdBreaks(bool autoPlayAdBreaks) async {
    final ImaSdkSettings settings = await nativeSettingsFuture;
    await settings.setAutoPlayAdBreaks(autoPlayAdBreaks);
  }

  @override
  Future<void> setDebugMode(bool enabled) async {
    final ImaSdkSettings settings = await nativeSettingsFuture;
    await settings.setDebugMode(enabled);
  }

  @override
  Future<void> setFeatureFlags(Map<String, String> featureFlags) async {
    final ImaSdkSettings settings = await nativeSettingsFuture;
    await settings.setFeatureFlags(featureFlags);
  }

  @override
  Future<void> setMaxRedirects(int maxRedirects) async {
    final ImaSdkSettings settings = await nativeSettingsFuture;
    await settings.setMaxRedirects(maxRedirects);
  }

  @override
  Future<void> setPlayerType(String playerType) async {
    final ImaSdkSettings settings = await nativeSettingsFuture;
    await settings.setPlayerType(playerType);
  }

  @override
  Future<void> setPlayerVersion(String playerVersion) async {
    final ImaSdkSettings settings = await nativeSettingsFuture;
    await settings.setPlayerVersion(playerVersion);
  }

  @override
  Future<void> setPpid(String ppid) async {
    final ImaSdkSettings settings = await nativeSettingsFuture;
    await settings.setPpid(ppid);
  }

  @override
  Future<void> setSessionID(String sessionID) async {
    final ImaSdkSettings settings = await nativeSettingsFuture;
    await settings.setSessionId(sessionID);
  }

  Future<ImaSdkSettings> _createSettings() async {
    final ImaSdkSettings settings =
        await ImaSdkFactory.instance.createImaSdkSettings();
    if (params.language case final String language) {
      await settings.setLanguage(language);
    }
    return settings;
  }
}
