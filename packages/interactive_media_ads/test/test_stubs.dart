// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

final class TestInteractiveMediaAdsPlatform
    extends InteractiveMediaAdsPlatform {
  TestInteractiveMediaAdsPlatform({
    this.onCreatePlatformAdsLoader,
    this.onCreatePlatformAdsManagerDelegate,
    this.onCreatePlatformAdDisplayContainer,
  });

  PlatformAdsLoader Function(PlatformAdsLoaderCreationParams params)?
      onCreatePlatformAdsLoader;

  PlatformAdsManagerDelegate Function(
    PlatformAdsManagerDelegateCreationParams params,
  )? onCreatePlatformAdsManagerDelegate;

  PlatformAdDisplayContainer Function(
    PlatformAdDisplayContainerCreationParams params,
  )? onCreatePlatformAdDisplayContainer;

  @override
  PlatformAdsLoader createPlatformAdsLoader(
    PlatformAdsLoaderCreationParams params,
  ) {
    return onCreatePlatformAdsLoader?.call(params) ??
        super.createPlatformAdsLoader(params);
  }

  @override
  PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    return onCreatePlatformAdsManagerDelegate?.call(params) ??
        super.createPlatformAdsManagerDelegate(params);
  }

  @override
  PlatformAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    return onCreatePlatformAdDisplayContainer?.call(params) ??
        super.createPlatformAdDisplayContainer(params);
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
    this.onContentComplete,
    this.onRequestAds,
  }) : super.implementation();

  Future<void> Function()? onContentComplete;

  Future<void> Function(AdsRequest request)? onRequestAds;

  @override
  Future<void> contentComplete() async {
    return onContentComplete?.call();
  }

  @override
  Future<void> requestAds(AdsRequest request) async {
    return onRequestAds?.call(request);
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
  });

  Future<void> Function(AdsManagerInitParams params)? onInit;

  Future<void> Function(PlatformAdsManagerDelegate delegate)?
      onSetAdsManagerDelegate;

  Future<void> Function(AdsManagerStartParams params)? onStart;

  Future<void> Function()? onDestroy;

  @override
  Future<void> init(AdsManagerInitParams params) async {
    return onInit?.call(params);
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
}
