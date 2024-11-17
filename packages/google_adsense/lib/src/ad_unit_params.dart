// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Contains some of the possible adUnitParams keys constants for convenience and documentation
class AdUnitParams {
  /// Identifies AdSense publisher account. Should be passed on initialization
  static const String AD_CLIENT = 'adClient';

  /// Identified specific ad unit from AdSense console. Can be taken from the ad unit HTML snippet under `data-ad-slot` parameter
  static const String AD_SLOT = 'adSlot';

  /// (Optional) Specify a general shape (desktop only) (horizontal, vertical, and/or rectangle) that your ad unit should conform to
  /// See [docs](https://support.google.com/adsense/answer/9183460?hl=en&ref_topic=9183242&sjid=2004567335727763076-EU#:~:text=Specify%20a%20general%20shape%20(desktop%20only)) for details
  static const String AD_FORMAT = 'adFormat';

  /// (Optional) The data-full-width-responsive parameter determines whether your responsive ad unit expands to use the full width of your visitor's mobile device screen.
  /// See [docs](https://support.google.com/adsense/answer/9183460?hl=en&ref_topic=9183242&sjid=2004567335727763076-EU#:~:text=Set%20the%20behavior%20of%20full%2Dwidth%20responsive%20ads%20on%20mobile%20devices) for details
  static const String FULL_WIDTH_RESPONSIVE = 'fullWidthResponsive';

  /// (Optional) Use value provided in the AdSense code generated in AdSense Console
  static const String AD_LAYOUT_KEY = 'adLayoutKey';

  /// (Optional) Use value provided in the AdSense code generated in AdSense Console
  static const String AD_LAYOUT = 'adLayout';

  /// (Optional) This parameter lets you control the arrangement of the text and images in your Multiplex ad units. For example, you can choose to have the image and text side by side, the image above the text, etc.
  /// See [MultiplexLayout]
  /// See [docs](https://support.google.com/adsense/answer/7533385?hl=en#:~:text=Change%20the%20layout%20of%20your%20Multiplex%20ad%20unit)
  static const String MATCHED_CONTENT_UI_TYPE = 'matchedContentUiType';

  /// The ads inside a Multiplex ad unit are arranged in a grid. You can specify how many rows and columns you want to show within that grid<br>
  /// Sets the number of rows<br>
  /// Requires setting [AdUnitParams.MATCHED_CONTENT_UI_TYPE]
  static const String MATCHED_CONTENT_ROWS_NUM = 'macthedContentRowsNum';

  /// The ads inside a Multiplex ad unit are arranged in a grid. You can specify how many rows and columns you want to show within that grid<br>
  /// Sets the number of columns<br>
  /// Requires setting [AdUnitParams.MATCHED_CONTENT_UI_TYPE]
  static const String MATCHED_CONTENT_COLUMNS_NUM = 'macthedContentColumnsNum';

  /// testing environment flag, defaults to kIsDebug
  static const String AD_TEST = 'adtest';
}

/// Possible values for [AdUnitParams.AD_FORMAT].
///
/// See [docs](https://support.google.com/adsense/answer/9183460?hl=en&ref_topic=9183242&sjid=2004567335727763076-EU#:~:text=Specify%20a%20general%20shape%20(desktop%20only)) for details
enum AdFormat {
  /// Default which enables the auto-sizing behavior for the responsive ad unit
  AUTO('auto'),

  /// Use horizontal shape
  HORIZONTAL('horizontal'),

  /// Use rectangle shape
  RECTANGLE('rectangle'),

  /// Use vertical shape
  VERTICAL('vertical'),

  /// Use horizontal and rectangle shape
  HORIZONTAL_RECTANGLE('horizontal,rectangle'),

  /// Use horizontal and vertical shape
  HORIZONTAL_VERTICAL('horizontal,vertical'),

  /// Use rectangle and vertical shape
  RECTANGLE_VERTICAL('rectangle,vertical'),

  /// Use horizontal, rectangle and vertical shape
  HORIZONTAL_RECTANGLE_VERTICAL('horizontal,rectangle,vertical'),

  /// Fluid ads have no fixed size, but rather adapt to fit the creative content they display
  FLUID('fluid');

  const AdFormat(this._adFormat);
  final String _adFormat;

  @override
  String toString() => _adFormat;
}

/// Possible values for [AdUnitParams.AD_LAYOUT].
///
// TODO(sokoloff06): find docs link!
enum AdLayout {
  ///
  IMAGE_TOP('image-top'),

  ///
  IMAGE_MIDDLE('image-middle'),

  ///
  IMAGE_SIDE('image-side'),

  ///
  TEXT_ONLY('text-only'),

  ///
  IN_ARTICLE('in-article');

  const AdLayout(this._adLayout);
  final String _adLayout;

  @override
  String toString() => _adLayout;
}

/// Possible values for [AdUnitParams.MATCHED_CONTENT_UI_TYPE].
///
/// See [docs](https://support.google.com/adsense/answer/7533385?hl=en#:~:text=Change%20the%20layout%20of%20your%20Multiplex%20ad%20unit)
enum MatchedContentUiType {
  /// In this layout, the image and text appear alongside each other.
  IMAGE_CARD_SIDEBYSIDE('image_card_sidebyside'),

  /// In this layout, the image and text appear alongside each other within a card.
  IMAGE_SIDEBYSIDE('image_sidebyside'),

  /// In this layout, the image and text are arranged one on top of the other.
  IMAGE_STACKED('image_stacked'),

  /// In this layout, the image and text are arranged one on top of the other within a card.
  IMAGE_CARD_STACKED('image_card_stacked'),

  /// A text-only layout with no image.
  TEXT('text'),

  /// A text-only layout within a card.
  TEXT_CARD('text_card');

  const MatchedContentUiType(this._uiType);
  final String _uiType;

  @override
  String toString() => _uiType;
}

/// After an ad unit has finished requesting an ad, AdSense adds a parameter to the <ins> element called data-ad-status. Note: data-ad-status should not be confused with data-adsbygoogle-status, which is used by our ad code for ads processing purposes.
/// See [docs](https://support.google.com/adsense/answer/10762946?hl=en) for more information
class AdStatus {
  /// Indicates ad slot was filled
  static const String FILLED = 'filled';

  /// Indicates ad slot was not filled
  static const String UNFILLED = 'unfilled';
}
