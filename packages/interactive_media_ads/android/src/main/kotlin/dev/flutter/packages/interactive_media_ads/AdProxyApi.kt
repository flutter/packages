// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.Ad
import com.google.ads.interactivemedia.v3.api.AdPodInfo
import com.google.ads.interactivemedia.v3.api.CompanionAd
import com.google.ads.interactivemedia.v3.api.UniversalAdId

/**
 * ProxyApi implementation for [Ad].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) : PigeonApiAd(pigeonRegistrar) {
  override fun adId(pigeon_instance: Ad): String {
    return pigeon_instance.adId
  }

  override fun adPodInfo(pigeon_instance: Ad): AdPodInfo {
    return pigeon_instance.adPodInfo
  }

  override fun adSystem(pigeon_instance: Ad): String {
    return pigeon_instance.adSystem
  }

  override fun adWrapperCreativeIds(pigeon_instance: Ad): List<String> {
    return pigeon_instance.adWrapperCreativeIds.asList()
  }

  override fun adWrapperIds(pigeon_instance: Ad): List<String> {
    return pigeon_instance.adWrapperIds.asList()
  }

  override fun adWrapperSystems(pigeon_instance: Ad): List<String> {
    return pigeon_instance.adWrapperSystems.asList()
  }

  override fun advertiserName(pigeon_instance: Ad): String {
    return pigeon_instance.advertiserName
  }

  override fun companionAds(pigeon_instance: Ad): List<CompanionAd> {
    return pigeon_instance.companionAds
  }

  override fun contentType(pigeon_instance: Ad): String? {
    return pigeon_instance.contentType
  }

  override fun creativeAdId(pigeon_instance: Ad): String {
    return pigeon_instance.creativeAdId
  }

  override fun creativeId(pigeon_instance: Ad): String {
    return pigeon_instance.creativeId
  }

  override fun dealId(pigeon_instance: Ad): String {
    return pigeon_instance.dealId
  }

  override fun description(pigeon_instance: Ad): String? {
    return pigeon_instance.description
  }

  override fun duration(pigeon_instance: Ad): Double {
    return pigeon_instance.duration
  }

  override fun height(pigeon_instance: Ad): Long {
    return pigeon_instance.height.toLong()
  }

  override fun skipTimeOffset(pigeon_instance: Ad): Double {
    return pigeon_instance.skipTimeOffset
  }

  override fun surveyUrl(pigeon_instance: Ad): String? {
    return pigeon_instance.surveyUrl
  }

  override fun title(pigeon_instance: Ad): String? {
    return pigeon_instance.title
  }

  override fun traffickingParameters(pigeon_instance: Ad): String {
    return pigeon_instance.traffickingParameters
  }

  override fun uiElements(pigeon_instance: Ad): List<UiElement> {
    return pigeon_instance.uiElements.map {
      when (it) {
        com.google.ads.interactivemedia.v3.api.UiElement.AD_ATTRIBUTION -> UiElement.AD_ATTRIBUTION
        com.google.ads.interactivemedia.v3.api.UiElement.COUNTDOWN -> UiElement.COUNTDOWN
        else -> UiElement.UNKNOWN
      }
    }
  }

  override fun universalAdIds(pigeon_instance: Ad): List<UniversalAdId> {
    return pigeon_instance.universalAdIds.toList()
  }

  override fun vastMediaBitrate(pigeon_instance: Ad): Long {
    return pigeon_instance.vastMediaBitrate.toLong()
  }

  override fun vastMediaHeight(pigeon_instance: Ad): Long {
    return pigeon_instance.vastMediaHeight.toLong()
  }

  override fun vastMediaWidth(pigeon_instance: Ad): Long {
    return pigeon_instance.vastMediaWidth.toLong()
  }

  override fun width(pigeon_instance: Ad): Long {
    return pigeon_instance.width.toLong()
  }

  override fun isLinear(pigeon_instance: Ad): Boolean {
    return pigeon_instance.isLinear
  }

  override fun isSkippable(pigeon_instance: Ad): Boolean {
    return pigeon_instance.isSkippable
  }
}
