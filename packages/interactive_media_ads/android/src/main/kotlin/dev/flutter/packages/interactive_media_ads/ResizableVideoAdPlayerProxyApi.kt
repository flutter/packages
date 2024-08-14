// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.ResizablePlayer

/**
 * ProxyApi implementation for `ResizableVideoAdPlayer`.
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ResizableVideoAdPlayerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiResizableVideoAdPlayer(pigeonRegistrar) {
  class ResizableVideoAdPlayer(private val resizableApi: ResizableVideoAdPlayerProxyApi) :
      VideoAdPlayerProxyApi.VideoAdPlayerImpl(
          resizableApi.pigeon_getPigeonApiVideoAdPlayer() as VideoAdPlayerProxyApi),
      ResizablePlayer {

    override fun resize(leftMargin: Int, topMargin: Int, rightMargin: Int, bottomMargin: Int) {
      resizableApi.pigeonRegistrar.runOnMainThread {
        resizableApi.pigeon_getPigeonApiResizablePlayer().resize(
            this,
            leftMargin.toLong(),
            topMargin.toLong(),
            rightMargin.toLong(),
            bottomMargin.toLong()) {}
      }
    }
  }

  override fun pigeon_defaultConstructor(): ResizableVideoAdPlayer {
    return ResizableVideoAdPlayer(this)
  }
}
