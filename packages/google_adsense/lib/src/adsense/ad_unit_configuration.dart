// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ad_unit_params.dart';

/// Configuration to customize the [AdUnitWidget].
///
/// Contains named constructors for the following supported ad unit types:
///
/// * Display (see: [AdUnitConfiguration.displayAdUnit])
/// * In-feed (see: [AdUnitConfiguration.inFeedAdUnit])
/// * In-article (see: [AdUnitConfiguration.inArticleAdUnit])
/// * Multiplex (see: [AdUnitConfiguration.multiplexAdUnit])
///
/// Each constructor will use one or more of the following arguments:
///
/// {@template pkg_google_adsense_parameter_adSlot}
/// * [adSlot]: Identifies a specific ad unit from the AdSense console.
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_adFormat}
/// * [adFormat]: (Desktop only) Specifies a general shape (horizontal, vertical,
///   and/or rectangle) that this ad unit should conform to. To learn more, check:
///   [How to use responsive ad tag parameters](https://support.google.com/adsense/answer/9183460).
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_adLayout}
/// * [adLayout]: Customizes the layout of this ad unit. See:
///   [Customize your in-feed ad](https://support.google.com/adsense/answer/9189957).
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_adLayoutKey}
/// * [adLayoutKey]: The key identifying the layout for this ad unit.
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_matchedContentUiType}
/// * [matchedContentUiType]: Controls the arrangement of the text and images in
///   this Multiplex ad unit. For example, you can choose to have the image and
///   text side by side, the image above the text, etc. More information:
///   [How to customize your responsive Multiplex ad unit](https://support.google.com/adsense/answer/7533385)
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_rowsNum}
/// * [rowsNum]: Specifies how many rows to show within the Multiplex ad unit grid.
///   Requires [matchedContentUiType] to be set.
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_columnsNum}
/// * [columnsNum]: Specifies how many columns to show within the Multiplex ad unit grid.
///   Requires [matchedContentUiType] to be set.
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_isFullWidthResponsive}
/// * [isFullWidthResponsive]: Determines whether this responsive ad unit expands
///   to use the full width of a visitor's mobile device screen. See:
///   [How to use responsive ad tag parameters](https://support.google.com/adsense/answer/9183460).
/// {@endtemplate}
/// {@template pkg_google_adsense_parameter_isAdTest}
/// * [isAdTest]: Whether this ad will be shown in a test environment. Defaults to `true` in debug mode.
/// {@endtemplate}
///
/// For more information about ad units, check the
/// [Ad formats FAQ](https://support.google.com/adsense/answer/10734935)
/// in the Google AdSense Help.
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
    bool? isAdTest,
  }) : _adUnitParams = <String, String>{
          AdUnitParams.AD_SLOT: adSlot,
          if (adFormat != null) AdUnitParams.AD_FORMAT: adFormat.toString(),
          if (adLayout != null) AdUnitParams.AD_LAYOUT: adLayout.toString(),
          if (adLayoutKey != null) AdUnitParams.AD_LAYOUT_KEY: adLayoutKey,
          if (isFullWidthResponsive != null)
            AdUnitParams.FULL_WIDTH_RESPONSIVE:
                isFullWidthResponsive.toString(),
          if (matchedContentUiType != null)
            AdUnitParams.MATCHED_CONTENT_UI_TYPE:
                matchedContentUiType.toString(),
          if (columnsNum != null)
            AdUnitParams.MATCHED_CONTENT_COLUMNS_NUM: columnsNum.toString(),
          if (rowsNum != null)
            AdUnitParams.MATCHED_CONTENT_ROWS_NUM: rowsNum.toString(),
          if (isAdTest != null && isAdTest) AdUnitParams.AD_TEST: 'on',
        };

  /// Creates a configuration object for a Multiplex ad.
  ///
  /// Arguments:
  ///
  /// {@macro pkg_google_adsense_parameter_adSlot}
  /// {@macro pkg_google_adsense_parameter_adFormat}
  /// {@macro pkg_google_adsense_parameter_matchedContentUiType}
  /// {@macro pkg_google_adsense_parameter_rowsNum}
  /// {@macro pkg_google_adsense_parameter_columnsNum}
  /// {@macro pkg_google_adsense_parameter_isFullWidthResponsive}
  /// {@macro pkg_google_adsense_parameter_isAdTest}
  AdUnitConfiguration.multiplexAdUnit({
    required String adSlot,
    required AdFormat adFormat,
    MatchedContentUiType? matchedContentUiType,
    int? rowsNum,
    int? columnsNum,
    bool isFullWidthResponsive = true,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            matchedContentUiType: matchedContentUiType,
            rowsNum: rowsNum,
            columnsNum: columnsNum,
            isFullWidthResponsive: isFullWidthResponsive,
            isAdTest: isAdTest);

  /// Creates a configuration object for an In-feed ad.
  ///
  /// Arguments:
  ///
  /// {@macro pkg_google_adsense_parameter_adSlot}
  /// {@macro pkg_google_adsense_parameter_adLayoutKey}
  /// {@macro pkg_google_adsense_parameter_adFormat}
  /// {@macro pkg_google_adsense_parameter_isFullWidthResponsive}
  /// {@macro pkg_google_adsense_parameter_isAdTest}
  AdUnitConfiguration.inFeedAdUnit({
    required String adSlot,
    required String adLayoutKey,
    AdFormat? adFormat,
    bool isFullWidthResponsive = true,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            adLayoutKey: adLayoutKey,
            isFullWidthResponsive: isFullWidthResponsive,
            isAdTest: isAdTest);

  /// Creates a configuration object for an In-article ad.
  ///
  /// Arguments:
  ///
  /// {@macro pkg_google_adsense_parameter_adSlot}
  /// {@macro pkg_google_adsense_parameter_adFormat}
  /// {@macro pkg_google_adsense_parameter_adLayout}
  /// {@macro pkg_google_adsense_parameter_isFullWidthResponsive}
  /// {@macro pkg_google_adsense_parameter_isAdTest}
  AdUnitConfiguration.inArticleAdUnit({
    required String adSlot,
    AdFormat? adFormat,
    AdLayout adLayout = AdLayout.IN_ARTICLE,
    bool isFullWidthResponsive = true,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            adLayout: adLayout,
            isFullWidthResponsive: isFullWidthResponsive,
            isAdTest: isAdTest);

  /// Creates a configuration object for a Display ad.
  ///
  /// Arguments:
  ///
  /// {@macro pkg_google_adsense_parameter_adSlot}
  /// {@macro pkg_google_adsense_parameter_adFormat}
  /// {@macro pkg_google_adsense_parameter_isFullWidthResponsive}
  /// {@macro pkg_google_adsense_parameter_isAdTest}
  AdUnitConfiguration.displayAdUnit({
    required String adSlot,
    AdFormat? adFormat,
    bool isFullWidthResponsive = true,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            isFullWidthResponsive: isFullWidthResponsive,
            isAdTest: isAdTest);

  Map<String, String> _adUnitParams;

  /// `Map` representation of this configuration object.
  Map<String, String> get params => _adUnitParams;
}
