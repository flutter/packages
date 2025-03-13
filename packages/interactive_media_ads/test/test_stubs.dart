// Copyright 2013 The Flutter Authors. All rights reserved.
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
  });

  PlatformAdsLoader Function(PlatformAdsLoaderCreationParams params)
      onCreatePlatformAdsLoader;

  PlatformAdsManagerDelegate Function(
    PlatformAdsManagerDelegateCreationParams params,
  ) onCreatePlatformAdsManagerDelegate;

  PlatformAdDisplayContainer Function(
    PlatformAdDisplayContainerCreationParams params,
  ) onCreatePlatformAdDisplayContainer;

  PlatformContentProgressProvider Function(
    PlatformContentProgressProviderCreationParams params,
  ) onCreatePlatformContentProgressProvider;

  PlatformAdsRenderingSettings Function(
    PlatformAdsRenderingSettingsCreationParams params,
  )? onCreatePlatformAdsRenderingSettings;

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
}

final class TestPlatformAdDisplayContainer extends PlatformAdDisplayContainer {
  TestPlatformAdDisplayContainer(
    super.params, {
    required this.onBuild,
  }) : super.implementation();

  Widget Function(BuildContext context) onBuild;

  @override
  Widget build(BuildContext context) {
    return onBuild.call(context);
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
  TestContentProgressProvider(
    super.params, {
    this.onSetProgress,
  }) : super.implementation();

  Future<void> Function({
    required Duration progress,
    required Duration duration,
  })? onSetProgress;

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
