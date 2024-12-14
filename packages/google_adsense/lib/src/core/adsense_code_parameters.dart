// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Configuration for various settings for game ads.
///
/// These are set as `data`-attributes in the adsense script tag.
///
/// For more information about these parameters, check
/// [AdSense code parameter descriptions](https://support.google.com/adsense/answer/9955214#adsense_code_parameter_descriptions).
class AdSenseCodeParameters {
  /// Builds an AdSense code parameters object.
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
