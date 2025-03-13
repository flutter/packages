// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRenderingSettings
import com.google.ads.interactivemedia.v3.api.UiElement

/**
 * ProxyApi implementation for [AdsRenderingSettings].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdsRenderingSettingsProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdsRenderingSettings(pigeonRegistrar) {
  override fun getBitrateKbps(pigeon_instance: AdsRenderingSettings): Long {
    return pigeon_instance.bitrateKbps.toLong()
  }

  override fun getEnableCustomTabs(pigeon_instance: AdsRenderingSettings): Boolean {
    return pigeon_instance.enableCustomTabs
  }

  override fun getEnablePreloading(pigeon_instance: AdsRenderingSettings): Boolean {
    return pigeon_instance.enablePreloading
  }

  override fun getFocusSkipButtonWhenAvailable(pigeon_instance: AdsRenderingSettings): Boolean {
    return pigeon_instance.focusSkipButtonWhenAvailable
  }

  override fun getMimeTypes(pigeon_instance: AdsRenderingSettings): List<String> {
    return pigeon_instance.mimeTypes
  }

  override fun setBitrateKbps(pigeon_instance: AdsRenderingSettings, bitrate: Long) {
    pigeon_instance.bitrateKbps = bitrate.toInt()
  }

  override fun setEnableCustomTabs(
      pigeon_instance: AdsRenderingSettings,
      enableCustomTabs: Boolean
  ) {
    pigeon_instance.enableCustomTabs = enableCustomTabs
  }

  override fun setEnablePreloading(
      pigeon_instance: AdsRenderingSettings,
      enablePreloading: Boolean
  ) {
    pigeon_instance.enablePreloading = enablePreloading
  }

  override fun setFocusSkipButtonWhenAvailable(
      pigeon_instance: AdsRenderingSettings,
      enableFocusSkipButton: Boolean
  ) {
    pigeon_instance.focusSkipButtonWhenAvailable = enableFocusSkipButton
  }

  override fun setLoadVideoTimeout(pigeon_instance: AdsRenderingSettings, loadVideoTimeout: Long) {
    pigeon_instance.setLoadVideoTimeout(loadVideoTimeout.toInt())
  }

  override fun setMimeTypes(pigeon_instance: AdsRenderingSettings, mimeTypes: List<String>) {
    pigeon_instance.mimeTypes = mimeTypes
  }

  override fun setPlayAdsAfterTime(pigeon_instance: AdsRenderingSettings, time: Double) {
    pigeon_instance.setPlayAdsAfterTime(time)
  }

  override fun setUiElements(
      pigeon_instance: AdsRenderingSettings,
      uiElements: List<dev.flutter.packages.interactive_media_ads.UiElement>
  ) {
    val nativeUiElements =
        uiElements.map {
          when (it) {
            dev.flutter.packages.interactive_media_ads.UiElement.AD_ATTRIBUTION ->
                UiElement.AD_ATTRIBUTION
            dev.flutter.packages.interactive_media_ads.UiElement.COUNTDOWN -> UiElement.COUNTDOWN
            dev.flutter.packages.interactive_media_ads.UiElement.UNKNOWN ->
                throw UnsupportedOperationException("$it is not supported.")
          }
        }
    pigeon_instance.setUiElements(nativeUiElements.toSet())
  }
}
