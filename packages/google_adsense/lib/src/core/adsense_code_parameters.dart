// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Configuration for various settings for game ads.
///
/// These are set as `data`-attributes in the AdSense script tag.
class AdSenseCodeParameters {
  /// Builds an AdSense code parameters object.
  ///
  /// The following parameters are available:
  ///
  /// * [adHost]: If you share your revenue with a host platform, use this parameter
  ///   to specify the host platform.
  /// * [admobInterstitialSlot]: If your game runs in a mobile app, use this parameter
  ///   to request interstitial ads.
  /// * [admobRewardedSlot]: If your game runs in a mobile app, use this parameter
  ///   to request rewarded ads.
  /// * [adChannel]: You may include a
  ///   [custom channel ID](https://support.google.com/adsense/answer/10078316)
  ///   for tracking the performance of your ads.
  /// * [adbreakTest]: Set this parameter to `'on'` to enable testing mode. This
  ///   lets you test your placements using fake ads.
  /// * [tagForChildDirectedTreatment]: Use this parameter if you want to tag your
  ///   ad requests for treatment as child directed. For more information, refer to:
  ///   [Tag a site or ad request for child-directed treatment](https://support.google.com/adsense/answer/3248194).
  /// * [tagForUnderAgeOfConsent]: Use this parameter if you want to tag your
  ///   European Economic Area (EEA), Switzerland, and UK ad requests for restricted
  ///   data processing treatment. For more information, refer to:
  ///   [Tag an ad request for EEA and UK users under the age of consent (TFUA)](https://support.google.com/adsense/answer/9009582).
  /// * [adFrequencyHint]: The minimum average time interval between ads expressed
  ///   in seconds. If this value is `'120s'` then ads will not be shown more
  ///   frequently than once every two minutes on average. Note that this is a hint
  ///   that could be ignored or overridden by a server control in future.
  ///
  /// For more information about these parameters, check
  /// [AdSense code parameter descriptions](https://support.google.com/adsense/answer/9955214#adsense_code_parameter_descriptions).
  AdSenseCodeParameters({
    String? adHost,
    String? admobInterstitialSlot,
    String? admobRewardedSlot,
    String? adChannel,
    String? adbreakTest,
    String? tagForChildDirectedTreatment,
    String? tagForUnderAgeOfConsent,
    String? adFrequencyHint,
  }) : _adSenseCodeParameters = <String, String>{
          if (adHost != null) 'adHost': adHost,
          if (admobInterstitialSlot != null)
            'admobInterstitialSlot': admobInterstitialSlot,
          if (admobRewardedSlot != null) 'admobRewardedSlot': admobRewardedSlot,
          if (adChannel != null) 'adChannel': adChannel,
          if (adbreakTest != null) 'adbreakTest': adbreakTest,
          if (tagForChildDirectedTreatment != null)
            'tagForChildDirectedTreatment': tagForChildDirectedTreatment,
          if (tagForUnderAgeOfConsent != null)
            'tagForUnderAgeOfConsent': tagForUnderAgeOfConsent,
          if (adFrequencyHint != null) 'adFrequencyHint': adFrequencyHint,
        };

  final Map<String, String> _adSenseCodeParameters;

  /// `Map` representation of this configuration object.
  Map<String, String> get toMap => _adSenseCodeParameters;
}
