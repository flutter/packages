// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsManager
import com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent

class AdsManagerLoadedEventProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdsManagerLoadedEvent(pigeonRegistrar) {
  override fun manager(pigeon_instance: AdsManagerLoadedEvent): AdsManager {
    return pigeon_instance.adsManager
  }
}
