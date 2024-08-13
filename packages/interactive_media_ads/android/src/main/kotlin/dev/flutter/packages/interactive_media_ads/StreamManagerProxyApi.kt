// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.CuePoint
import com.google.ads.interactivemedia.v3.api.StreamManager

/**
 * ProxyApi implementation for [StreamManager].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class StreamManagerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiStreamManager(pigeonRegistrar) {

  override fun getContentTimeMsForStreamTimeMs(
      pigeon_instance: StreamManager,
      streamTimeMs: Long
  ): Long {
    return pigeon_instance.getContentTimeMsForStreamTimeMs(streamTimeMs)
  }

  override fun getCuePoints(
      pigeon_instance: StreamManager
  ): List<CuePoint> {
    return pigeon_instance.cuePoints
  }

  override fun getPreviousCuePointForStreamTimeMs(
      pigeon_instance: StreamManager,
      streamTimeMs: Long
  ): CuePoint? {
    return pigeon_instance.getPreviousCuePointForStreamTimeMs(streamTimeMs)
  }

  override fun getStreamId(pigeon_instance: StreamManager): String {
    return pigeon_instance.streamId
  }

  override fun getStreamTimeMsForContentTimeMs(
      pigeon_instance: StreamManager,
      contentTimeMs: Long
  ): Long {
    return pigeon_instance.getStreamTimeMsForContentTimeMs(contentTimeMs)
  }

  override fun loadThirdPartyStream(
      pigeon_instance: StreamManager,
      streamUrl: String,
      streamSubtitles: List<Map<String, String>>
  ) {
    pigeon_instance.loadThirdPartyStream(streamUrl, streamSubtitles)
  }

  override fun replaceAdTagParameters(
      pigeon_instance: StreamManager,
      adTagParameters: Map<String, String>
  ) {
    pigeon_instance.replaceAdTagParameters(adTagParameters)
  }
}
