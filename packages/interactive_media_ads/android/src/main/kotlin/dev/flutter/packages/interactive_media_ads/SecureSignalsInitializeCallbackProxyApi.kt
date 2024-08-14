// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.signals.SecureSignalsInitializeCallback

/**
 * ProxyApi implementation for [SecureSignalsInitializeCallback].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class SecureSignalsInitializeCallbackProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiSecureSignalsInitializeCallback(pigeonRegistrar) {
  internal class SecureSignalsInitializeCallbackImpl(
      val api: SecureSignalsInitializeCallbackProxyApi
  ) : SecureSignalsInitializeCallback {
    override fun onFailure(error: Exception) {
      api.pigeonRegistrar.runOnMainThread {
        api.onFailure(this, error.javaClass.name, error.message) {}
      }
    }

    override fun onSuccess() {
      api.pigeonRegistrar.runOnMainThread { api.onSuccess(this) {} }
    }
  }

  override fun pigeon_defaultConstructor(): SecureSignalsInitializeCallback {
    return SecureSignalsInitializeCallbackImpl(this)
  }
}
