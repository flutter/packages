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

class TestPlatformAdDisplayContainer extends PlatformAdDisplayContainer {
  TestPlatformAdDisplayContainer(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

class TestPlatformAdsLoader extends PlatformAdsLoader {
  TestPlatformAdsLoader(super.params) : super.implementation();
}

class TestPlatformAdsManagerDelegate extends PlatformAdsManagerDelegate {
  TestPlatformAdsManagerDelegate(super.params) : super.implementation();
}
