// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.VersionInfo
import com.google.ads.interactivemedia.v3.api.signals.SecureSignalsAdapter
import com.google.ads.interactivemedia.v3.api.signals.SecureSignalsCollectSignalsCallback
import com.google.ads.interactivemedia.v3.api.signals.SecureSignalsInitializeCallback
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class SecureSignalsAdapterProxyApiTest {
  @Test
  fun collectSignals() {
    val registrar = TestProxyApiRegistrar()
    val api = registrar.getPigeonApiSecureSignalsAdapter()

    val instance = mock<SecureSignalsAdapter>()
    val callback = mock<SecureSignalsCollectSignalsCallback>()
    api.collectSignals(instance, callback)

    verify(instance).collectSignals(registrar.context, callback)
  }

  @Test
  fun getSDKVersion() {
    val api = TestProxyApiRegistrar().getPigeonApiSecureSignalsAdapter()

    val instance = mock<SecureSignalsAdapter>()
    val value = mock<VersionInfo>()
    whenever(instance.sdkVersion).thenReturn(value)

    assertEquals(value, api.getSDKVersion(instance))
  }

  @Test
  fun getVersion() {
    val api = TestProxyApiRegistrar().getPigeonApiSecureSignalsAdapter()

    val instance = mock<SecureSignalsAdapter>()
    val value = mock<VersionInfo>()
    whenever(instance.version).thenReturn(value)

    assertEquals(value, api.getVersion(instance))
  }

  @Test
  fun initialize() {
    val registrar = TestProxyApiRegistrar()
    val api = registrar.getPigeonApiSecureSignalsAdapter()

    val instance = mock<SecureSignalsAdapter>()
    val callback = mock<SecureSignalsInitializeCallback>()
    api.initialize(instance, callback)

    verify(instance).initialize(registrar.context, callback)
  }
}
