// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.View
import com.google.ads.interactivemedia.v3.api.FriendlyObstruction
import com.google.ads.interactivemedia.v3.api.FriendlyObstructionPurpose

/**
 * ProxyApi implementation for [FriendlyObstruction].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class FriendlyObstructionProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiFriendlyObstruction(pigeonRegistrar) {
  override fun detailedReason(pigeon_instance: FriendlyObstruction): String? {
    return pigeon_instance.detailedReason
  }

  override fun purpose(
      pigeon_instance: FriendlyObstruction
  ): dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose {
    return when (pigeon_instance.purpose) {
      FriendlyObstructionPurpose.CLOSE_AD ->
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.CLOSE_AD
      FriendlyObstructionPurpose.NOT_VISIBLE ->
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.NOT_VISIBLE
      FriendlyObstructionPurpose.OTHER ->
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.OTHER
      FriendlyObstructionPurpose.VIDEO_CONTROLS ->
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.VIDEO_CONTROLS
      else -> dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.UNKNOWN
    }
  }

  override fun view(pigeon_instance: FriendlyObstruction): android.view.View {
    return pigeon_instance.view
  }
}
