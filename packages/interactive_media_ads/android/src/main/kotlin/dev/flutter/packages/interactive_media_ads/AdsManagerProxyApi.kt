// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsManager

class AdsManagerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdsManager(pigeonRegistrar) {
  override fun discardAdBreak(pigeon_instance: AdsManager) {
    pigeon_instance.discardAdBreak()
  }

  override fun pause(pigeon_instance: AdsManager) {
    pigeon_instance.pause()
  }

  override fun start(pigeon_instance: AdsManager) {
    pigeon_instance.start()
  }
}
