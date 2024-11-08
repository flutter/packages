// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'interactive_media_ads.g.dart';

/// Handles constructing objects and calling static methods for the iOS
/// Interactive Media Ads native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying iOS classes.
class InteractiveMediaAdsProxy {
  /// Constructs an [InteractiveMediaAdsProxy].
  const InteractiveMediaAdsProxy({
    this.newIMAAdDisplayContainer = IMAAdDisplayContainer.new,
    this.newUIViewController = UIViewController.new,
    this.newIMAContentPlayhead = IMAContentPlayhead.new,
    this.newIMAAdsLoader = IMAAdsLoader.new,
    this.newIMAAdsRequest = IMAAdsRequest.new,
    this.newIMAAdsLoaderDelegate = IMAAdsLoaderDelegate.new,
    this.newIMAAdsManagerDelegate = IMAAdsManagerDelegate.new,
    this.newIMAAdsRenderingSettings = IMAAdsRenderingSettings.new,
    this.newIMAFriendlyObstruction = IMAFriendlyObstruction.new,
    this.newIMACompanionAdSlot = IMACompanionAdSlot.new,
    this.sizeIMACompanionAdSlot = IMACompanionAdSlot.size,
    this.newIMACompanionDelegate = IMACompanionDelegate.new,
  });

  /// Constructs [IMAAdDisplayContainer].
  final IMAAdDisplayContainer Function({
    required UIView adContainer,
    UIViewController? adContainerViewController,
  }) newIMAAdDisplayContainer;

  /// Constructs [UIViewController].
  final UIViewController Function({
    void Function(UIViewController, bool)? viewDidAppear,
  }) newUIViewController;

  /// Constructs [IMAContentPlayhead].
  final IMAContentPlayhead Function() newIMAContentPlayhead;

  /// Constructs [IMAAdsLoader].
  final IMAAdsLoader Function({IMASettings? settings}) newIMAAdsLoader;

  /// Constructs [IMAAdsRequest].
  final IMAAdsRequest Function({
    required String adTagUrl,
    required IMAAdDisplayContainer adDisplayContainer,
    IMAContentPlayhead? contentPlayhead,
  }) newIMAAdsRequest;

  /// Constructs [IMAAdsLoaderDelegate].
  final IMAAdsLoaderDelegate Function({
    required void Function(IMAAdsLoaderDelegate, IMAAdsLoader, IMAAdsLoadedData)
        adLoaderLoadedWith,
    required void Function(
      IMAAdsLoaderDelegate,
      IMAAdsLoader,
      IMAAdLoadingErrorData,
    ) adsLoaderFailedWithErrorData,
  }) newIMAAdsLoaderDelegate;

  /// Constructs [IMAAdsManagerDelegate].
  final IMAAdsManagerDelegate Function({
    required void Function(IMAAdsManagerDelegate, IMAAdsManager, IMAAdEvent)
        didReceiveAdEvent,
    required void Function(IMAAdsManagerDelegate, IMAAdsManager, IMAAdError)
        didReceiveAdError,
    required void Function(IMAAdsManagerDelegate, IMAAdsManager)
        didRequestContentPause,
    required void Function(IMAAdsManagerDelegate, IMAAdsManager)
        didRequestContentResume,
  }) newIMAAdsManagerDelegate;

  /// Constructs [IMAAdsRenderingSettings].
  final IMAAdsRenderingSettings Function() newIMAAdsRenderingSettings;

  /// Constructs [IMAFriendlyObstruction].
  final IMAFriendlyObstruction Function({
    required UIView view,
    required FriendlyObstructionPurpose purpose,
    String? detailedReason,
  }) newIMAFriendlyObstruction;

  /// Constructs [IMACompanionAdSlot].
  final IMACompanionAdSlot Function({required UIView view})
      newIMACompanionAdSlot;

  /// Constructs [IMACompanionAdSlot].
  final IMACompanionAdSlot Function({
    required int width,
    required int height,
    required UIView view,
  }) sizeIMACompanionAdSlot;

  /// Constructs [IMACompanionDelegate].
  final IMACompanionDelegate Function() newIMACompanionDelegate;
}
