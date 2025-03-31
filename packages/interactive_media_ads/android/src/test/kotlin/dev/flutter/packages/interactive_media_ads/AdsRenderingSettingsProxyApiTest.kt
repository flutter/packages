// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRenderingSettings
import com.google.ads.interactivemedia.v3.api.UiElement
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class AdsRenderingSettingsProxyApiTest {
  @Test
  fun getBitrateKbps() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val value = 0
    whenever(instance.bitrateKbps).thenReturn(value)

    assertEquals(value.toLong(), api.getBitrateKbps(instance))
  }

  @Test
  fun getEnableCustomTabs() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val value = true
    whenever(instance.enableCustomTabs).thenReturn(value)

    assertEquals(value, api.getEnableCustomTabs(instance))
  }

  @Test
  fun getEnablePreloading() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val value = true
    whenever(instance.enablePreloading).thenReturn(value)

    assertEquals(value, api.getEnablePreloading(instance))
  }

  @Test
  fun getFocusSkipButtonWhenAvailable() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val value = true
    whenever(instance.focusSkipButtonWhenAvailable).thenReturn(value)

    assertEquals(value, api.getFocusSkipButtonWhenAvailable(instance))
  }

  @Test
  fun getMimeTypes() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val value = listOf("myString")
    whenever(instance.mimeTypes).thenReturn(value)

    assertEquals(value, api.getMimeTypes(instance))
  }

  @Test
  fun setBitrateKbps() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val bitrate = 0L
    api.setBitrateKbps(instance, bitrate)

    verify(instance).bitrateKbps = bitrate.toInt()
  }

  @Test
  fun setEnableCustomTabs() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val enableCustomTabs = true
    api.setEnableCustomTabs(instance, enableCustomTabs)

    verify(instance).enableCustomTabs = enableCustomTabs
  }

  @Test
  fun setEnablePreloading() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val enablePreloading = true
    api.setEnablePreloading(instance, enablePreloading)

    verify(instance).enablePreloading = enablePreloading
  }

  @Test
  fun setFocusSkipButtonWhenAvailable() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val enableFocusSkipButton = true
    api.setFocusSkipButtonWhenAvailable(instance, enableFocusSkipButton)

    verify(instance).focusSkipButtonWhenAvailable = enableFocusSkipButton
  }

  @Test
  fun setLoadVideoTimeout() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val loadVideoTimeout = 0L
    api.setLoadVideoTimeout(instance, loadVideoTimeout)

    verify(instance).setLoadVideoTimeout(loadVideoTimeout.toInt())
  }

  @Test
  fun setMimeTypes() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val mimeTypes = listOf("myString")
    api.setMimeTypes(instance, mimeTypes)

    verify(instance).mimeTypes = mimeTypes
  }

  @Test
  fun setPlayAdsAfterTime() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val time = 1.0
    api.setPlayAdsAfterTime(instance, time)

    verify(instance).setPlayAdsAfterTime(time)
  }

  @Test
  fun setUiElements() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRenderingSettings()

    val instance = mock<AdsRenderingSettings>()
    val uiElements = listOf(dev.flutter.packages.interactive_media_ads.UiElement.AD_ATTRIBUTION)
    api.setUiElements(instance, uiElements)

    verify(instance).setUiElements(setOf(UiElement.AD_ATTRIBUTION))
  }
}
