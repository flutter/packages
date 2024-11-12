import 'package:flutter/foundation.dart';

import '../google_adsense.dart';

/// AdUnit configuration object<br>
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
    AdFormatType? adFormat,
    String? adLayout,
    String? adLayoutKey,
    MultiplexLayout? multiplexLayout,
    int? rowsNum,
    int? columnsNum,
    bool isFullWidthResponsive = true,
    this.isAdTest = kDebugMode,
    this.cssText,
  }) : _adUnitParams = _buildParams(<String, String?>{
          AdUnitParams.AD_SLOT: adSlot,
          AdUnitParams.AD_FORMAT: adFormat?.getAttribute(),
          AdUnitParams.AD_LAYOUT: adLayout,
          AdUnitParams.AD_LAYOUT_KEY: adLayoutKey,
          AdUnitParams.FULL_WIDTH_RESPONSIVE: isFullWidthResponsive.toString(),
          AdUnitParams.MATCHED_CONTENT_UI_TYPE: multiplexLayout?.getAttribute(),
          AdUnitParams.MATCHED_CONTENT_COLUMNS_NUM: columnsNum?.toString(),
          AdUnitParams.MATCHED_CONTENT_ROWS_NUM: rowsNum?.toString(),
        });

  /// Creates In-article ad unit configuration object
  AdUnitConfiguration.multiplexAdUnit({
    required String adSlot,
    required AdFormatType adFormat,
    MultiplexLayout? multiplexLayout,
    int? rowsNum,
    int? columnsNum,
    bool isFullWidthResponsive = true,
    String? cssText,
    bool isAdTest = kDebugMode,
  }) : this._internal(
            adSlot: adSlot,
            adFormat: adFormat,
            multiplexLayout: multiplexLayout,
            rowsNum: rowsNum,
            columnsNum: columnsNum,
            isFullWidthResponsive: isFullWidthResponsive,
            cssText: cssText,
            isAdTest: isAdTest);

  /// Creates In-feed ad unit configuration object
  AdUnitConfiguration.inFeedAdUnit({
    required String adSlot,
    AdFormatType? adFormat,
    required String adLayoutKey,
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
    AdFormatType? adFormat,
    String adLayout = 'in-article',
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
    AdFormatType? adFormat,
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

  static Map<String, String> _buildParams(Map<String, String?> inputParams) {
    final Map<String, String?> paramsMap =
        Map<String, String?>.from(inputParams);
    paramsMap.removeWhere((String key, String? value) => value == null);

    return paramsMap.cast<String, String>();
  }
}
