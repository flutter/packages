// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

final class TestInteractiveMediaAdsPlatform
    extends InteractiveMediaAdsPlatform {
  TestInteractiveMediaAdsPlatform({
    required this.onCreatePlatformAdsLoader,
    required this.onCreatePlatformAdsManagerDelegate,
    required this.onCreatePlatformAdDisplayContainer,
    required this.onCreatePlatformContentProgressProvider,
    this.onCreatePlatformAdsRenderingSettings,
    this.onCreatePlatformCompanionAdSlot,
  });

  PlatformAdsLoader Function(PlatformAdsLoaderCreationParams params)
  onCreatePlatformAdsLoader;

  PlatformAdsManagerDelegate Function(
    PlatformAdsManagerDelegateCreationParams params,
  )
  onCreatePlatformAdsManagerDelegate;

  PlatformAdDisplayContainer Function(
    PlatformAdDisplayContainerCreationParams params,
  )
  onCreatePlatformAdDisplayContainer;

  PlatformContentProgressProvider Function(
    PlatformContentProgressProviderCreationParams params,
  )
  onCreatePlatformContentProgressProvider;

  PlatformAdsRenderingSettings Function(
    PlatformAdsRenderingSettingsCreationParams params,
  )?
  onCreatePlatformAdsRenderingSettings;

  PlatformCompanionAdSlot Function(
    PlatformCompanionAdSlotCreationParams params,
  )?
  onCreatePlatformCompanionAdSlot;

  PlatformImaSettings Function(PlatformImaSettingsCreationParams params)?
  onCreatePlatformImaSettings;

  @override
  PlatformAdsLoader createPlatformAdsLoader(
    PlatformAdsLoaderCreationParams params,
  ) {
    return onCreatePlatformAdsLoader(params);
  }

  @override
  PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    return onCreatePlatformAdsManagerDelegate(params);
  }

  @override
  PlatformAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    return onCreatePlatformAdDisplayContainer(params);
  }

  @override
  PlatformContentProgressProvider createPlatformContentProgressProvider(
    PlatformContentProgressProviderCreationParams params,
  ) {
    return onCreatePlatformContentProgressProvider(params);
  }

  @override
  PlatformAdsRenderingSettings createPlatformAdsRenderingSettings(
    PlatformAdsRenderingSettingsCreationParams params,
  ) {
    return onCreatePlatformAdsRenderingSettings?.call(params) ??
        TestAdsRenderingSettings(params);
  }

  @override
  PlatformCompanionAdSlot createPlatformCompanionAdSlot(
    PlatformCompanionAdSlotCreationParams params,
  ) {
    return onCreatePlatformCompanionAdSlot?.call(params) ??
        TestCompanionAdSlot(params, onBuildWidget: (_) => Container());
  }

  @override
  PlatformImaSettings createPlatformImaSettings(
    PlatformImaSettingsCreationParams params,
  ) {
    return onCreatePlatformImaSettings?.call(params) ?? TestImaSettings(params);
  }
}

final class TestPlatformAdDisplayContainer extends PlatformAdDisplayContainer {
  TestPlatformAdDisplayContainer(super.params, {required this.onBuild})
    : super.implementation();

  Widget Function(BuildContext context) onBuild;

  @override
  Widget build(BuildContext context) {
    return onBuild(context);
  }
}

final class TestPlatformAdsLoader extends PlatformAdsLoader {
  TestPlatformAdsLoader(
    super.params, {
    required this.onContentComplete,
    required this.onRequestAds,
  }) : super.implementation();

  Future<void> Function() onContentComplete;

  Future<void> Function(PlatformAdsRequest request) onRequestAds;

  @override
  Future<void> contentComplete() async {
    return onContentComplete();
  }

  @override
  Future<void> requestAds(PlatformAdsRequest request) async {
    return onRequestAds(request);
  }
}

final class TestPlatformAdsManagerDelegate extends PlatformAdsManagerDelegate {
  TestPlatformAdsManagerDelegate(super.params) : super.implementation();
}

class TestAdsManager extends PlatformAdsManager {
  TestAdsManager({
    this.onInit,
    this.onSetAdsManagerDelegate,
    this.onStart,
    this.onDestroy,
    this.onDiscardAdBreak,
    this.onPause,
    this.onResume,
    this.onSkip,
    super.adCuePoints = const <Duration>[],
  });

  Future<void> Function({PlatformAdsRenderingSettings? settings})? onInit;

  Future<void> Function(PlatformAdsManagerDelegate delegate)?
  onSetAdsManagerDelegate;

  Future<void> Function(AdsManagerStartParams params)? onStart;

  Future<void> Function()? onDiscardAdBreak;

  Future<void> Function()? onPause;

  Future<void> Function()? onResume;

  Future<void> Function()? onSkip;

  Future<void> Function()? onDestroy;

  @override
  Future<void> init({PlatformAdsRenderingSettings? settings}) async {
    return onInit?.call(settings: settings);
  }

  @override
  Future<void> setAdsManagerDelegate(
    PlatformAdsManagerDelegate delegate,
  ) async {
    return onSetAdsManagerDelegate?.call(delegate);
  }

  @override
  Future<void> start(AdsManagerStartParams params) async {
    return onStart?.call(params);
  }

  @override
  Future<void> destroy() async {
    return onDestroy?.call();
  }

  @override
  Future<void> discardAdBreak() async {
    return onDiscardAdBreak?.call();
  }

  @override
  Future<void> pause() async {
    return onPause?.call();
  }

  @override
  Future<void> resume() async {
    return onResume?.call();
  }

  @override
  Future<void> skip() async {
    return onSkip?.call();
  }
}

class TestContentProgressProvider extends PlatformContentProgressProvider {
  TestContentProgressProvider(super.params, {this.onSetProgress})
    : super.implementation();

  Future<void> Function({
    required Duration progress,
    required Duration duration,
  })?
  onSetProgress;

  @override
  Future<void> setProgress({
    required Duration progress,
    required Duration duration,
  }) async {
    return onSetProgress?.call(progress: progress, duration: duration);
  }
}

final class TestAdsRenderingSettings extends PlatformAdsRenderingSettings {
  TestAdsRenderingSettings(super.params) : super.implementation();
}

final class TestCompanionAdSlot extends PlatformCompanionAdSlot {
  TestCompanionAdSlot(super.params, {required this.onBuildWidget})
    : super.implementation();

  Widget Function(BuildWidgetCreationParams params) onBuildWidget;

  @override
  Widget buildWidget(BuildWidgetCreationParams params) {
    return onBuildWidget(params);
  }
}

final class TestImaSettings extends PlatformImaSettings {
  TestImaSettings(
    super.params, {
    this.onSetPpid,
    this.onSetMaxRedirects,
    this.onSetFeatureFlags,
    this.onSetAutoPlayAdBreaks,
    this.onSetPlayerType,
    this.onSetPlayerVersion,
    this.onSetSessionID,
    this.onSetDebugMode,
  }) : super.implementation();

  void Function(String ppid)? onSetPpid;

  void Function(int maxRedirects)? onSetMaxRedirects;

  void Function(Map<String, String> featureFlags)? onSetFeatureFlags;

  void Function(bool autoPlayAdBreaks)? onSetAutoPlayAdBreaks;

  void Function(String playerType)? onSetPlayerType;

  void Function(String playerVersion)? onSetPlayerVersion;

  void Function(String sessionID)? onSetSessionID;

  void Function(bool enableDebugMode)? onSetDebugMode;

  @override
  Future<void> setPpid(String ppid) async => onSetPpid?.call(ppid);

  @override
  Future<void> setMaxRedirects(int maxRedirects) async {
    onSetMaxRedirects?.call(maxRedirects);
  }

  @override
  Future<void> setFeatureFlags(Map<String, String> featureFlags) async {
    onSetFeatureFlags?.call(featureFlags);
  }

  @override
  Future<void> setAutoPlayAdBreaks(bool autoPlayAdBreaks) async {
    onSetAutoPlayAdBreaks?.call(autoPlayAdBreaks);
  }

  @override
  Future<void> setPlayerType(String playerType) async {
    onSetPlayerType?.call(playerType);
  }

  @override
  Future<void> setPlayerVersion(String playerVersion) async {
    onSetPlayerVersion?.call(playerVersion);
  }

  @override
  Future<void> setSessionID(String sessionID) async {
    onSetSessionID?.call(sessionID);
  }

  @override
  Future<void> setDebugMode(bool enableDebugMode) async {
    onSetDebugMode?.call(enableDebugMode);
  }
}
