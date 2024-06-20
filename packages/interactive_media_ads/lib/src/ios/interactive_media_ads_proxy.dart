// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'interactive_media_ads.g.dart';

/// Handles constructing objects and calling static methods for the iOS
/// Interactive Media Ads native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying Android classes.
///
/// By default each function calls the default constructor of the class it
/// intends to return.
class InteractiveMediaAdsProxy {
  /// Constructs an [InteractiveMediaAdsProxy].
  const InteractiveMediaAdsProxy({
    this.newIMAAdDisplayContainer = IMAAdDisplayContainer.new,
    this.newUIViewController = UIViewController.new,
    this.newIMAAdsLoader = IMAAdsLoader.new,
    this.newIMAAdsRequest = IMAAdsRequest.new,
    this.newIMAAdsLoaderDelegate = IMAAdsLoaderDelegate.new,
    this.newIMAAdsManagerDelegate = IMAAdsManagerDelegate.new,
    this.newIMAAdsRenderingSettings = IMAAdsRenderingSettings.new,
  });

  /// Constructs [IMAAdDisplayContainer].
  final IMAAdDisplayContainer Function({
  required UIView adContainer,
  UIViewController? adContainerViewController,
  }) newIMAAdDisplayContainer;

  /// Constructs [UIViewController].
  final UIViewController Function() newUIViewController;

  /// Constructs [IMAAdsLoader].
  final IMAAdsLoader Function({IMASettings? settings}) newIMAAdsLoader;

  /// Constructs [IMAAdsRequest].
  final IMAAdsRequest Function({
  required String adTagUrl,
  required IMAAdDisplayContainer adDisplayContainer,
  required IMAContentPlayhead contentPlayhead,
  }) newIMAAdsRequest;

  /// Constructs [IMAAdsLoaderDelegate].
  final IMAAdsLoaderDelegate Function({
  required void Function(
      IMAAdsLoaderDelegate,
      IMAAdsLoader,
      IMAAdsLoadedData,
      ) adLoaderLoadedWith,
  required void Function(
      IMAAdsLoaderDelegate,
      IMAAdsLoader,
      IMAAdLoadingErrorData,
      ) adsLoaderFailedWithErrorData,
  }) newIMAAdsLoaderDelegate;

  /// Constructs [IMAAdsManagerDelegate].
  final IMAAdsManagerDelegate Function({
  required void Function(
      IMAAdsManagerDelegate,
      IMAAdsManager,
      IMAAdEvent,
      ) didReceiveAdEvent,
  required void Function(
      IMAAdsManagerDelegate,
      IMAAdsManager,
      IMAAdError,
      ) didReceiveAdError,
  required void Function(
      IMAAdsManagerDelegate,
      IMAAdsManager,
      ) didRequestContentPause,
  required void Function(
      IMAAdsManagerDelegate,
      IMAAdsManager,
      ) didRequestContentResume,
  }) newIMAAdsManagerDelegate;

  /// Constructs [IMAAdsRenderingSettings].
  final IMAAdsRenderingSettings Function() newIMAAdsRenderingSettings;
}
