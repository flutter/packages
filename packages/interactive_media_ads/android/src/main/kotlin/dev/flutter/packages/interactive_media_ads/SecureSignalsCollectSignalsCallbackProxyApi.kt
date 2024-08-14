// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.signals.SecureSignalsCollectSignalsCallback

/**
 * ProxyApi implementation for [SecureSignalsCollectSignalsCallback].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class SecureSignalsCollectSignalsCallbackProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiSecureSignalsCollectSignalsCallback(pigeonRegistrar) {
  internal class SecureSignalsCollectSignalsCallbackImpl(
      val api: SecureSignalsCollectSignalsCallbackProxyApi
  ) : SecureSignalsCollectSignalsCallback {
    override fun onFailure(error: Exception) {
      api.pigeonRegistrar.runOnMainThread {
        api.onFailure(this, error.javaClass.name, error.message) {}
      }
    }

    override fun onSuccess(signals: String) {
      api.pigeonRegistrar.runOnMainThread { api.onSuccess(this, signals) {} }
    }
  }

  override fun pigeon_defaultConstructor(): SecureSignalsCollectSignalsCallback {
    return SecureSignalsCollectSignalsCallbackImpl(this)
  }
}
