// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdErrorEvent

class AdErrorListenerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdErrorListener(pigeonRegistrar) {
  internal class AdErrorListenerImpl(val api: AdErrorListenerProxyApi) :
      AdErrorEvent.AdErrorListener {
    override fun onAdError(event: AdErrorEvent) {
      api.pigeonRegistrar.runOnMainThread { api.onAdError(this, event) {} }
    }
  }

  override fun pigeon_defaultConstructor(): AdErrorEvent.AdErrorListener {
    return AdErrorListenerImpl(this)
  }
}
