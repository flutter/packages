// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.BaseRequest
import com.google.ads.interactivemedia.v3.api.signals.SecureSignals

/**
 * ProxyApi implementation for [BaseRequest].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class BaseRequestProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) : PigeonApiBaseRequest(pigeonRegistrar) {

  override fun getContentUrl(pigeon_instance: BaseRequest): String {
    return pigeon_instance.contentUrl
  }

  override fun getSecureSignals(pigeon_instance: BaseRequest): SecureSignals? {
    return pigeon_instance.secureSignals
  }

  override fun getUserRequestContext(pigeon_instance: BaseRequest): Any {
    return pigeon_instance.userRequestContext
  }

  override fun setContentUrl(pigeon_instance: BaseRequest,url: String) {
    return pigeon_instance.setContentUrl(url)
  }

  override fun setSecureSignals(pigeon_instance: BaseRequest,signal: com.google.ads.interactivemedia.v3.api.signals.SecureSignals?) {
    return pigeon_instance.setSecureSignals(signal)
  }

  override fun setUserRequestContext(pigeon_instance: BaseRequest,userRequestContext: Any) {
    return pigeon_instance.setUserRequestContext(userRequestContext)
  }
}
