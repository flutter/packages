// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.ImaSdkSettings
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class ImaSdkSettingsProxyApiTest {
  @Test
  fun setAutoPlayAdBreaks() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val autoPlayAdBreaks = true
    api.setAutoPlayAdBreaks(instance, autoPlayAdBreaks)

    verify(instance).autoPlayAdBreaks = autoPlayAdBreaks
  }

  @Test
  fun setDebugMode() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val debugMode = true
    api.setDebugMode(instance, debugMode)

    verify(instance).isDebugMode = debugMode
  }

  @Test
  fun setFeatureFlags() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val featureFlags = mapOf("myString" to "myString2")
    api.setFeatureFlags(instance, featureFlags)

    verify(instance).featureFlags = featureFlags
  }

  @Test
  fun setLanguage() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val language = "myString"
    api.setLanguage(instance, language)

    verify(instance).language = language
  }

  @Test
  fun setMaxRedirects() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val maxRedirects = 0
    api.setMaxRedirects(instance, maxRedirects.toLong())

    verify(instance).maxRedirects = maxRedirects
  }

  @Test
  fun setPlayerType() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val playerType = "myString"
    api.setPlayerType(instance, playerType)

    verify(instance).playerType = playerType
  }

  @Test
  fun setPlayerVersion() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val playerVersion = "myString"
    api.setPlayerVersion(instance, playerVersion)

    verify(instance).playerVersion = playerVersion
  }

  @Test
  fun setPpid() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val ppid = "myString"
    api.setPpid(instance, ppid)

    verify(instance).ppid = ppid
  }

  @Test
  fun setSessionId() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val sessionId = "myString"
    api.setSessionId(instance, sessionId)

    verify(instance).sessionId = sessionId
  }
}
