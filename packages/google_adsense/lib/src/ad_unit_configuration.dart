// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../google_adsense.dart';

/// AdUnit configuration object.
///
/// Arguments:
/// - `adSlot`: See [AdUnitParams.AD_SLOT]
/// - `adFormat`: See [AdUnitParams.AD_FORMAT]
/// - `adLayout`: See [AdUnitParams.AD_LAYOUT]
/// - `adLayoutKey`: See [AdUnitParams.AD_LAYOUT_KEY]
/// - `multiplexLayout`: See [AdUnitParams.MATCHED_CONTENT_UI_TYPE]
/// - `rowsNum`: See [AdUnitParams.MATCHED_CONTENT_ROWS_NUM]
/// - `columnsNum`: See [AdUnitParams.MATCHED_CONTENT_COLUMNS_NUM]
/// - `isFullWidthResponsive`: See [AdUnitParams.FULL_WIDTH_RESPONSIVE]
/// - `isAdTest`: See [AdUnitParams.AD_TEST]
/// - `cssText`: See [AdUnitConfiguration.cssText]
class AdUnitConfiguration {
  AdUnitConfiguration._internal({
    required String adSlot,
    AdFormat? adFormat,
    AdLayout? adLayout,
    String? adLayoutKey,
    MatchedContentUiType? matchedContentUiType,
    int? rowsNum,
    int? columnsNum,
    bool? isFullWidthResponsive = true,
    this.isAdTest = kDebugMode,
    this.cssText,
  }) : _adUnitParams = <String, String>{
          AdUnitParams.AD_SLOT: adSlot,
          if (adFormat != null)
            AdUnitParams.AD_FORMAT: adFormat.toString(),
          if (adLayout != null)
            AdUnitParams.AD_LAYOUT: adLayout.toString(),
          if (adLayoutKey != null)
            AdUnitParams.AD_LAYOUT_KEY: adLayoutKey,
          if (isFullWidthResponsive != null)
            AdUnitParams.FULL_WIDTH_RESPONSIVE: isFullWidthResponsive.toString(),
          if (matchedContentUiType != null)
            AdUnitParams.MATCHED_CONTENT_UI_TYPE: matchedContentUiType.toString(),
          if (columnsNum != null)
            AdUnitParams.MATCHED_CONTENT_COLUMNS_NUM: columnsNum.toString(),
          if (rowsNum != null)
            AdUnitParams.MATCHED_CONTENT_ROWS_NUM: rowsNum.toString(),
        };

  /// Creates In-article ad unit configuration object
  AdUnitConfiguration.multiplexAdUnit({
    required String adSlot,
    required AdFormat adFormat,
    MatchedContentUiType? matchedContentUiType,
    int? rowsNum,
    int? columnsNum,
    bool isFullWidthResponsive = true,
    String? cssText,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            matchedContentUiType: matchedContentUiType,
            rowsNum: rowsNum,
            columnsNum: columnsNum,
            isFullWidthResponsive: isFullWidthResponsive,
            cssText: cssText,
            isAdTest: isAdTest);

  /// Creates In-feed ad unit configuration object
  AdUnitConfiguration.inFeedAdUnit({
    required String adSlot,
    required String adLayoutKey,
    AdFormat? adFormat,
    bool isFullWidthResponsive = true,
    String? cssText,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            adLayoutKey: adLayoutKey,
            isFullWidthResponsive: isFullWidthResponsive,
            cssText: cssText,
            isAdTest: isAdTest);

  /// Creates In-article ad unit configuration object
  AdUnitConfiguration.inArticleAdUnit({
    required String adSlot,
    AdFormat? adFormat,
    AdLayout adLayout = AdLayout.IN_ARTICLE,
    bool isFullWidthResponsive = true,
    String? cssText,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            adLayout: adLayout,
            isFullWidthResponsive: isFullWidthResponsive,
            cssText: cssText,
            isAdTest: isAdTest);

  /// Creates Display ad unit configuration object
  AdUnitConfiguration.displayAdUnit({
    required String adSlot,
    AdFormat? adFormat,
    bool isFullWidthResponsive = true,
    String? cssText,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            isFullWidthResponsive: isFullWidthResponsive,
            cssText: cssText,
            isAdTest: isAdTest);

  Map<String, String> _adUnitParams;

  /// See [AdUnitParams.AD_TEST]
  final bool isAdTest;

  /// CSS rules to be applied to the generated <ins> element. E.g. `border: 5px solid red; display: block; padding: 20px`
  final String? cssText;

  /// See [AdUnitParams.AD_CLIENT]
  String get adClient => _adUnitParams[AdUnitParams.AD_CLIENT]!;

  /// See [AdUnitParams.AD_SLOT]
  String get adSlot => _adUnitParams[AdUnitParams.AD_SLOT]!;

  /// Map containing all additional parameters of this configuration
  Map<String, String> get params => _adUnitParams;
}
