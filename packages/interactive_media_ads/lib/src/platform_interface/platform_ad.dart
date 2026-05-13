// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ad_ui_element.dart';
import 'platform_ad_pod_info.dart';
import 'platform_companion_ad.dart';
import 'platform_universal_ad_id.dart';

/// Data object representing a single ad.
base class PlatformAd {
  /// Constructs a [PlatformAd].
  PlatformAd({
    required this.adId,
    required this.adPodInfo,
    required this.adSystem,
    required this.wrapperCreativeIds,
    required this.wrapperIds,
    required this.wrapperSystems,
    required this.advertiserName,
    required this.companionAds,
    required this.contentType,
    required this.creativeAdId,
    required this.creativeId,
    required this.dealId,
    required this.description,
    required this.duration,
    required this.width,
    required this.height,
    required this.skipTimeOffset,
    required this.surveyUrl,
    required this.title,
    required this.traffickingParameters,
    required this.uiElements,
    required this.universalAdIds,
    required this.vastMediaBitrate,
    required this.vastMediaWidth,
    required this.vastMediaHeight,
    required this.isLinear,
    required this.isSkippable,
  });

  /// The ad ID as specified in the VAST response.
  final String adId;

  /// The pod metadata object.
  final PlatformAdPodInfo adPodInfo;

  /// The ad system as specified in the VAST response.
  final String adSystem;

  /// The IDs of the ads' creatives, starting with the first wrapper ad.
  final List<String> wrapperCreativeIds;

  /// The wrapper ad IDs as specified in the VAST response.
  final List<String> wrapperIds;

  /// The wrapper ad systems as specified in the VAST response.
  final List<String> wrapperSystems;

  /// The advertiser name as defined by the serving party.
  final String advertiserName;

  /// The companions for the current ad while using DAI.
  ///
  /// Returns an empty list in any other scenario.
  final List<PlatformCompanionAd> companionAds;

  /// The content type of the currently selected creative, or null if no
  /// creative is selected or the content type is unavailable.
  final String? contentType;

  /// The ISCI (Industry Standard Commercial Identifier) code for an ad.
  final String creativeAdId;

  /// The ID of the selected creative for the ad,
  final String creativeId;

  /// The first deal ID present in the wrapper chain for the current ad,
  /// starting from the top.
  final String dealId;

  /// The description of this ad from the VAST response.
  final String? description;

  /// The duration of the ad.
  final Duration? duration;

  /// The width of the selected creative if non-linear, else returns 0.
  final int width;

  /// The height of the selected creative if non-linear, else returns 0.
  final int height;

  /// The playback time before the ad becomes skippable.
  final Duration? skipTimeOffset;

  /// The URL associated with the survey for the given ad.
  final String? surveyUrl;

  /// The title of this ad from the VAST response.
  final String? title;

  /// The custom parameters associated with the ad at the time of ad
  /// trafficking.
  final String traffickingParameters;

  /// The set of ad UI elements rendered by the IMA SDK for this ad.
  final Set<AdUIElement> uiElements;

  /// The list of all universal ad IDs for this ad.
  final List<PlatformUniversalAdId> universalAdIds;

  /// The VAST bitrate in Kbps of the selected creative.
  final int vastMediaBitrate;

  /// The VAST media width in pixels of the selected creative.
  final int vastMediaWidth;

  /// The VAST media height in pixels of the selected creative.
  final int vastMediaHeight;

  /// Indicates whether the ad’s current mode of operation is linear or
  /// non-linear.
  final bool isLinear;

  /// Indicates whether the ad can be skipped by the user.
  final bool isSkippable;
}
