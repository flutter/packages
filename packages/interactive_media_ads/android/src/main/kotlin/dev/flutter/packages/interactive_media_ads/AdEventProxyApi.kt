// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdEvent

/**
 * ProxyApi implementation for [AdEvent].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdEventProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdEvent(pigeonRegistrar) {
  override fun type(pigeon_instance: AdEvent): AdEventType {
    return when (pigeon_instance.type) {
      AdEvent.AdEventType.ALL_ADS_COMPLETED -> AdEventType.ALL_ADS_COMPLETED
      AdEvent.AdEventType.AD_BREAK_FETCH_ERROR -> AdEventType.AD_BREAK_FETCH_ERROR
      AdEvent.AdEventType.CLICKED -> AdEventType.CLICKED
      AdEvent.AdEventType.COMPLETED -> AdEventType.COMPLETED
      AdEvent.AdEventType.CUEPOINTS_CHANGED -> AdEventType.CUEPOINTS_CHANGED
      AdEvent.AdEventType.CONTENT_PAUSE_REQUESTED -> AdEventType.CONTENT_PAUSE_REQUESTED
      AdEvent.AdEventType.CONTENT_RESUME_REQUESTED -> AdEventType.CONTENT_RESUME_REQUESTED
      AdEvent.AdEventType.FIRST_QUARTILE -> AdEventType.FIRST_QUARTILE
      AdEvent.AdEventType.LOG -> AdEventType.LOG
      AdEvent.AdEventType.AD_BREAK_READY -> AdEventType.AD_BREAK_READY
      AdEvent.AdEventType.MIDPOINT -> AdEventType.MIDPOINT
      AdEvent.AdEventType.PAUSED -> AdEventType.PAUSED
      AdEvent.AdEventType.RESUMED -> AdEventType.RESUMED
      AdEvent.AdEventType.SKIPPABLE_STATE_CHANGED -> AdEventType.SKIPPABLE_STATE_CHANGED
      AdEvent.AdEventType.SKIPPED -> AdEventType.SKIPPED
      AdEvent.AdEventType.STARTED -> AdEventType.STARTED
      AdEvent.AdEventType.TAPPED -> AdEventType.TAPPED
      AdEvent.AdEventType.ICON_TAPPED -> AdEventType.ICON_TAPPED
      AdEvent.AdEventType.ICON_FALLBACK_IMAGE_CLOSED -> AdEventType.ICON_FALLBACK_IMAGE_CLOSED
      AdEvent.AdEventType.THIRD_QUARTILE -> AdEventType.THIRD_QUARTILE
      AdEvent.AdEventType.LOADED -> AdEventType.LOADED
      AdEvent.AdEventType.AD_PROGRESS -> AdEventType.AD_PROGRESS
      AdEvent.AdEventType.AD_BUFFERING -> AdEventType.AD_BUFFERING
      AdEvent.AdEventType.AD_BREAK_STARTED -> AdEventType.AD_BREAK_STARTED
      AdEvent.AdEventType.AD_BREAK_ENDED -> AdEventType.AD_BREAK_ENDED
      AdEvent.AdEventType.AD_PERIOD_STARTED -> AdEventType.AD_PERIOD_STARTED
      AdEvent.AdEventType.AD_PERIOD_ENDED -> AdEventType.AD_PERIOD_ENDED
      else -> AdEventType.UNKNOWN
    }
  }

  override fun adData(pigeon_instance: AdEvent): Map<String, String>? {
    return pigeon_instance.adData
  }
}
