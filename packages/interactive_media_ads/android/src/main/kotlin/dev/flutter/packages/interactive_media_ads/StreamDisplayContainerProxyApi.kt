// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.StreamDisplayContainer
import com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer

/**
 * ProxyApi implementation for [StreamDisplayContainer].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class StreamDisplayContainerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiStreamDisplayContainer(pigeonRegistrar) {

  override fun getVideoStreamPlayer(pigeon_instance: StreamDisplayContainer): VideoStreamPlayer? {
    return pigeon_instance.videoStreamPlayer
  }
}
