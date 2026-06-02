// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'platform_interface/platform_interface.dart';

/// Data object representing a single ad.
class Ad {
  /// Constructs an [Ad] from a specific platform implementation.
  Ad.fromPlatform(this.platform);

  /// Implementation of [PlatformAd] for the current platform.
  final PlatformAd platform;

  /// The ad ID as specified in the VAST response.
  String get adId => platform.adId;

  /// The pod metadata object.
  AdPodInfo get adPodInfo => AdPodInfo.fromPlatform(platform.adPodInfo);

  /// The ad system as specified in the VAST response.
  String get adSystem => platform.adSystem;

  /// The IDs of the ads' creatives, starting with the first wrapper ad.
  List<String> get wrapperCreativeIds => platform.wrapperCreativeIds;

  /// The wrapper ad IDs as specified in the VAST response.
  List<String> get wrapperIds => platform.wrapperIds;

  /// The wrapper ad systems as specified in the VAST response.
  List<String> get wrapperSystems => platform.wrapperSystems;

  /// The advertiser name as defined by the serving party.
  String get advertiserName => platform.advertiserName;

  /// The companions for the current ad while using DAI.
  ///
  /// Returns an empty list in any other scenario.
  List<CompanionAd> get companionAds => List<CompanionAd>.unmodifiable(
    platform.companionAds.map(CompanionAd.fromPlatform),
  );

  /// The content type of the currently selected creative, or null if no
  /// creative is selected or the content type is unavailable.
  String? get contentType => platform.contentType;

  /// The ISCI (Industry Standard Commercial Identifier) code for an ad.
  String get creativeAdId => platform.creativeAdId;

  /// The ID of the selected creative for the ad,
  String get creativeId => platform.creativeId;

  /// The first deal ID present in the wrapper chain for the current ad,
  /// starting from the top.
  String get dealId => platform.dealId;

  /// The description of this ad from the VAST response.
  String? get description => platform.description;

  /// The duration of the ad.
  Duration? get duration => platform.duration;

  /// The width of the selected creative if non-linear, else returns 0.
  int get width => platform.width;

  /// The height of the selected creative if non-linear, else returns 0.
  int get height => platform.height;

  /// The playback time before the ad becomes skippable.
  ///
  /// The value is null for non-skippable ads, or if the value is unavailable.
  Duration? get skipTimeOffset => platform.skipTimeOffset;

  /// The URL associated with the survey for the given ad.
  String? get surveyUrl => platform.surveyUrl;

  /// The title of this ad from the VAST response.
  String? get title => platform.title;

  /// The custom parameters associated with the ad at the time of ad
  /// trafficking.
  String get traffickingParameters => platform.traffickingParameters;

  /// The set of ad UI elements rendered by the IMA SDK for this ad.
  Set<AdUIElement> get uiElements => platform.uiElements;

  /// The list of all universal ad IDs for this ad.
  List<UniversalAdId> get universalAdIds => List<UniversalAdId>.unmodifiable(
    platform.universalAdIds.map(UniversalAdId.fromPlatform),
  );

  /// The VAST bitrate in Kbps of the selected creative.
  int get vastMediaBitrate => platform.vastMediaBitrate;

  /// The VAST media height in pixels of the selected creative.
  int get vastMediaHeight => platform.vastMediaHeight;

  /// The VAST media width in pixels of the selected creative.
  int get vastMediaWidth => platform.vastMediaWidth;

  /// Indicates whether the ad’s current mode of operation is linear or
  /// non-linear.
  bool get isLinear => platform.isLinear;

  /// Indicates whether the ad can be skipped by the user.
  bool get isSkippable => platform.isSkippable;
}

/// Simple data object containing podding metadata.
class AdPodInfo {
  /// Constructs an [AdPodInfo] from a specific platform implementation.
  AdPodInfo.fromPlatform(this.platform);

  /// Implementation of [PlatformAdPodInfo] for the current platform.
  final PlatformAdPodInfo platform;

  /// The position of the ad within the pod.
  ///
  /// The value returned is one-based, for example, 1 of 2, 2 of 2, etc. If the
  /// ad is not part of a pod, this will return 1.
  int get adPosition => platform.adPosition;

  /// The maximum duration of the pod.
  ///
  /// For unknown duration, null.
  Duration? get maxDuration => platform.maxDuration;

  /// Returns the index of the ad pod.
  ///
  /// Client side: For a preroll pod, returns 0. For midrolls, returns 1, 2,…,
  /// N. For a postroll pod, returns -1. Defaults to 0 if this ad is not part of
  /// a pod, or this pod is not part of a playlist.
  ///
  /// DAI VOD: Returns the index of the ad pod. For a preroll pod, returns 0.
  /// For midrolls, returns 1, 2,…,N. For a postroll pod, returns N+1…N+X.
  /// Defaults to 0 if this ad is not part of a pod, or this pod is not part of
  /// a playlist.
  ///
  /// DAI live stream: For a preroll pod, returns 0. For midrolls, returns the
  /// break ID. Returns -2 if pod index cannot be determined (internal error).
  int get podIndex => platform.podIndex;

  /// The content time offset at which the current ad pod was scheduled.
  ///
  /// For preroll pod, 0 is returned. For midrolls, the scheduled time is
  /// returned. For postroll, -1 is returned. Defaults to 0 if this ad is not
  /// part of a pod, or the pod is not part of an ad playlist.
  Duration get timeOffset => platform.timeOffset;

  /// Total number of ads in the pod this ad belongs to, including bumpers.
  ///
  /// Will be 1 for standalone ads.
  int get totalAds => platform.totalAds;

  /// Specifies whether the ad is a bumper.
  ///
  /// Bumpers are short videos used to open and close ad breaks.
  bool get isBumper => platform.isBumper;
}

/// An object that holds data corresponding to the companion Ad.
class CompanionAd {
  /// Constructs a [CompanionAd] from a specific platform implementation.
  CompanionAd.fromPlatform(this.platform);

  /// Implementation of [PlatformCompanionAd] for the current platform.
  final PlatformCompanionAd platform;

  /// The width of the companion in pixels.
  ///
  /// `null` if unavailable.
  int? get width => platform.width;

  /// The height of the companion in pixels.
  ///
  /// `null` if unavailable.
  int? get height => platform.height;

  /// The API needed to execute this ad, or null if unavailable.
  String? get apiFramework => platform.apiFramework;

  /// The URL for the static resource of this companion.
  String? get resourceValue => platform.resourceValue;
}

/// Simple data object containing universal ad ID information.
class UniversalAdId {
  /// Constructs an [UniversalAdId] from a specific platform implementation.
  UniversalAdId.fromPlatform(this.platform);

  /// Implementation of [PlatformUniversalAdId] for the current platform.
  final PlatformUniversalAdId platform;

  /// The universal ad ID value.
  ///
  /// This will be null if it isn’t defined by the ad.
  String? get adIdValue => platform.adIdValue;

  /// The universal ad ID registry with which the value is registered.
  ///
  /// This will be null if it isn’t defined by the ad.
  String? get adIdRegistry => platform.adIdRegistry;
}
