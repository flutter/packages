// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.ImaSdkSettings

/**
 * ProxyApi implementation for [com.google.ads.interactivemedia.v3.api.ImaSdkSettings].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ImaSdkSettingsProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiImaSdkSettings(pigeonRegistrar) {
  override fun getAutoPlayAdBreaks(pigeon_instance: ImaSdkSettings): Boolean {
    return pigeon_instance.autoPlayAdBreaks
  }

  override fun getFeatureFlags(pigeon_instance: ImaSdkSettings): Map<String, String> {
    return pigeon_instance.featureFlags
  }

  override fun getLanguage(pigeon_instance: ImaSdkSettings): String {
    return pigeon_instance.language
  }

  override fun getMaxRedirects(pigeon_instance: ImaSdkSettings): Long {
    return pigeon_instance.maxRedirects.toLong()
  }

  override fun getPlayerType(pigeon_instance: ImaSdkSettings): String {
    return pigeon_instance.playerType
  }

  override fun getPlayerVersion(pigeon_instance: ImaSdkSettings): String {
    return pigeon_instance.playerVersion
  }

  override fun getPpid(pigeon_instance: ImaSdkSettings): String {
    return pigeon_instance.ppid
  }

  override fun getSessionId(pigeon_instance: ImaSdkSettings): String? {
    return pigeon_instance.sessionId
  }

  override fun isDebugMode(pigeon_instance: ImaSdkSettings): Boolean {
    return pigeon_instance.isDebugMode
  }

  override fun setAutoPlayAdBreaks(pigeon_instance: ImaSdkSettings, autoPlayAdBreaks: Boolean) {
    pigeon_instance.autoPlayAdBreaks = autoPlayAdBreaks
  }

  override fun setDebugMode(pigeon_instance: ImaSdkSettings, debugMode: Boolean) {
    pigeon_instance.isDebugMode = debugMode
  }

  override fun setFeatureFlags(pigeon_instance: ImaSdkSettings, featureFlags: Map<String, String>) {
    pigeon_instance.featureFlags = featureFlags
  }

  override fun setLanguage(pigeon_instance: ImaSdkSettings, language: String) {
    pigeon_instance.language = language
  }

  override fun setMaxRedirects(pigeon_instance: ImaSdkSettings, maxRedirects: Long) {
    pigeon_instance.maxRedirects = maxRedirects.toInt()
  }

  override fun setPlayerType(pigeon_instance: ImaSdkSettings, playerType: String) {
    pigeon_instance.playerType = playerType
  }

  override fun setPlayerVersion(pigeon_instance: ImaSdkSettings, playerVersion: String) {
    pigeon_instance.playerVersion = playerVersion
  }

  override fun setPpid(pigeon_instance: ImaSdkSettings, ppid: String) {
    pigeon_instance.ppid = ppid
  }

  override fun setSessionId(pigeon_instance: ImaSdkSettings, sessionId: String) {
    pigeon_instance.sessionId = sessionId
  }
}
