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

/// Possible values for [AdUnitParams.AD_FORMAT]
/// See [docs](https://support.google.com/adsense/answer/9183460?hl=en&ref_topic=9183242&sjid=2004567335727763076-EU#:~:text=Specify%20a%20general%20shape%20(desktop%20only)) for details
enum AdFormatType {
  /// Default which enables the auto-sizing behavior for the responsive ad unit
  AUTO,
  /// Use horizontal shape
  HORIZONTAL,
  /// Use rectangle shape
  RECTANGLE,
  /// Use vertical shape
  VERTICAL,
  /// Use horizontal and rectangle shape
  HORIZONTAL_RECTANGLE,
  /// Use horizontal and vertical shape
  HORIZONTAL_VERTICAL,
  /// Use rectangle and vertical shape
  RECTANGLE_VERTICAL,
  /// Use horizontal, rectangle and vertical shape
  HORIZONTAL_RECTANGLE_VERTICAL,
  /// Fluid ads have no fixed size, but rather adapt to fit the creative content they display
  FLUID
}

/// Possible values for [AdUnitParams.MATCHED_CONTENT_UI_TYPE]
/// See [docs](https://support.google.com/adsense/answer/7533385?hl=en#:~:text=Change%20the%20layout%20of%20your%20Multiplex%20ad%20unit)
enum MultiplexLayout {
  /// In this layout, the image and text appear alongside each other.
  IMAGE_CARD_SIDEBYSIDE,
  /// In this layout, the image and text appear alongside each other within a card.
  IMAGE_SIDEBYSIDE,
  /// In this layout, the image and text are arranged one on top of the other.
  IMAGE_STACKED,
  /// In this layout, the image and text are arranged one on top of the other within a card.
  IMAGE_CARD_STACKED,
  /// A text-only layout with no image.
  TEXT,
  /// A text-only layout within a card.
  TEXT_CARD
}

/// Extension to convert [AdFormatType] enum options into <ins> tag data-attribute names
extension GetCommaSeparatedNames on AdFormatType {
  /// Returns corresponding data-attribute
  String getAttribute() {
    return name.toLowerCase().split('_').join(',');
  }
}

/// Extension to convert [Multiplex] enum options into <ins> tag data-attribute names
extension GetLowerCaseName on MultiplexLayout {
  /// Returns corresponding data-attribute
  String getAttribute() {
    return name.toLowerCase();
  }
}
