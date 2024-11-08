// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider
import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate

/**
 * ProxyApi implementation for [ContentProgressProvider].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ContentProgressProviderProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiContentProgressProvider(pigeonRegistrar) {
  internal class ContentProgressProviderImpl(val api: ContentProgressProviderProxyApi) :
      ContentProgressProvider {
    var currentProgress = VideoProgressUpdate.VIDEO_TIME_NOT_READY

    override fun getContentProgress(): VideoProgressUpdate {
      return currentProgress
    }
  }

  override fun pigeon_defaultConstructor(): ContentProgressProvider {
    return ContentProgressProviderImpl(this)
  }

  override fun setContentProgress(
      pigeon_instance: ContentProgressProvider,
      update: VideoProgressUpdate
  ) {
    (pigeon_instance as ContentProgressProviderImpl).currentProgress = update
  }
}
