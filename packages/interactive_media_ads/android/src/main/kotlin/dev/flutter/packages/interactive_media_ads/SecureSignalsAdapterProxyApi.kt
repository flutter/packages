// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.VersionInfo
import com.google.ads.interactivemedia.v3.api.signals.SecureSignalsAdapter
import com.google.ads.interactivemedia.v3.api.signals.SecureSignalsCollectSignalsCallback
import com.google.ads.interactivemedia.v3.api.signals.SecureSignalsInitializeCallback

/**
 * ProxyApi implementation for [SecureSignalsAdapter].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class SecureSignalsAdapterProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiSecureSignalsAdapter(pigeonRegistrar) {

  override fun collectSignals(
      pigeon_instance: SecureSignalsAdapter,
      callback: SecureSignalsCollectSignalsCallback
  ) {
    pigeon_instance.collectSignals(pigeonRegistrar.context, callback)
  }

  override fun getSDKVersion(pigeon_instance: SecureSignalsAdapter): VersionInfo {
    return pigeon_instance.sdkVersion
  }

  override fun getVersion(pigeon_instance: SecureSignalsAdapter): VersionInfo {
    return pigeon_instance.version
  }

  override fun initialize(
      pigeon_instance: SecureSignalsAdapter,
      callback: SecureSignalsInitializeCallback
  ) {
    pigeon_instance.initialize(pigeonRegistrar.context, callback)
  }
}
