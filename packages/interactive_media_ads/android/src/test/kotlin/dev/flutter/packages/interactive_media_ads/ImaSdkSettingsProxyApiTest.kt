// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.ImaSdkSettings
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class ImaSdkSettingsProxyApiTest {
  @Test
  fun getAutoPlayAdBreaks() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = true
    whenever(instance.autoPlayAdBreaks).thenReturn(value)

    assertEquals(value, api.getAutoPlayAdBreaks(instance))
  }

  @Test
  fun getFeatureFlags() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = mapOf("myString" to "myString")
    whenever(instance.featureFlags).thenReturn(value)

    assertEquals(value, api.getFeatureFlags(instance))
  }

  @Test
  fun getLanguage() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = "myString"
    whenever(instance.language).thenReturn(value)

    assertEquals(value, api.getLanguage(instance))
  }

  @Test
  fun getMaxRedirects() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = 0
    whenever(instance.maxRedirects).thenReturn(value)

    assertEquals(value.toLong(), api.getMaxRedirects(instance))
  }

  @Test
  fun getPlayerType() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = "myString"
    whenever(instance.playerType).thenReturn(value)

    assertEquals(value, api.getPlayerType(instance))
  }

  @Test
  fun getPlayerVersion() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = "myString"
    whenever(instance.playerVersion).thenReturn(value)

    assertEquals(value, api.getPlayerVersion(instance))
  }

  @Test
  fun getPpid() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = "myString"
    whenever(instance.ppid).thenReturn(value)

    assertEquals(value, api.getPpid(instance))
  }

  @Test
  fun getSessionId() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = "myString"
    whenever(instance.sessionId).thenReturn(value)

    assertEquals(value, api.getSessionId(instance))
  }

  @Test
  fun isDebugMode() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkSettings()

    val instance = mock<ImaSdkSettings>()
    val value = true
    whenever(instance.isDebugMode).thenReturn(value)

    assertEquals(value, api.isDebugMode(instance))
  }

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
    val featureFlags = mapOf("myString" to "myString1")
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
