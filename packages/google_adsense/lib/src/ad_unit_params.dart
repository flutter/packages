class AdUnitParams {
  /// /// (Optional) Can be provided in adUnitParams. If not provided, value passed on initialization will be used
  /// @value Numeric String
  static const String AD_CLIENT = 'adClient';

  /// Required parameter passed as a named argument to adUnitParams
  /// @value Numeric String
  static const String AD_SLOT = 'adSlot';

  /// (Optional) Use value provided in the AdSense code generated in AdSense Console
  static const String AD_LAYOUT = 'adLayout';

  /// (Optional) Use value provided in the AdSense code generated in AdSense Console
  static const String AD_LAYOUT_KEY = 'adLayoutKey';

  /// (Optional) Specify a general shape (desktop only) (horizontal, vertical, and/or rectangle) that your ad unit should conform to
  /// See [docs](https://support.google.com/adsense/answer/9183460?hl=en&ref_topic=9183242&sjid=2004567335727763076-EU#:~:text=Specify%20a%20general%20shape%20(desktop%20only)) for details
  static const String AD_FORMAT = 'adFormat';

  /// (Optional) The data-full-width-responsive parameter determines whether your responsive ad unit expands to use the full width of your visitor's mobile device screen.
  /// See [docs](https://support.google.com/adsense/answer/9183460?hl=en&ref_topic=9183242&sjid=2004567335727763076-EU#:~:text=Set%20the%20behavior%20of%20full%2Dwidth%20responsive%20ads%20on%20mobile%20devices) for details
  static const String FULL_WIDTH_RESPONSIVE = 'fullWidthResponsive';
}
