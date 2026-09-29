// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.google.android.gms.maps.MapsInitializer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.googlemaps.ResultCompat.Companion.asContinuation
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.doNothing
import org.mockito.kotlin.mock
import org.mockito.kotlin.spy
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GoogleMapInitializerTest {
  private lateinit var googleMapInitializer: GoogleMapInitializer

  private var mockMessenger: BinaryMessenger = mock()

  @Before
  fun before() {
    val context = ApplicationProvider.getApplicationContext<Context?>()
    googleMapInitializer =
        spy(GoogleMapInitializer(context, mockMessenger))
  }

  @Test
  fun initializer_OnMapsSdkInitializedWithLatestRenderer() {
    doNothing()
        .whenever(googleMapInitializer)
        .initializeWithRendererRequest(MapsInitializer.Renderer.LATEST)
    val callbackCalled = arrayOfNulls<Boolean>(1)
    googleMapInitializer!!.initializeWithPreferredRenderer(
        PlatformRendererType.LATEST,
        asContinuation<PlatformRendererType?> { result: ResultCompat<PlatformRendererType?>? ->
          callbackCalled[0] = true
          val type = result!!.getOrNull()
          Assert.assertEquals(PlatformRendererType.LATEST, type)
          Unit
        })
    googleMapInitializer!!.onMapsSdkInitialized(MapsInitializer.Renderer.LATEST)

    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Suppress("deprecation")
  @Test
  fun initializer_OnMapsSdkInitializedWithLegacyRenderer() {
    doNothing()
        .whenever(googleMapInitializer)
        .initializeWithRendererRequest(MapsInitializer.Renderer.LEGACY)
    val callbackCalled = arrayOfNulls<Boolean>(1)
    googleMapInitializer!!.initializeWithPreferredRenderer(
        PlatformRendererType.LEGACY,
        asContinuation<PlatformRendererType?> { result: ResultCompat<PlatformRendererType?>? ->
          callbackCalled[0] = true
          val type = result!!.getOrNull()
          Assert.assertEquals(PlatformRendererType.LEGACY, type)
          Unit
        })
    googleMapInitializer!!.onMapsSdkInitialized(MapsInitializer.Renderer.LEGACY)

    Assert.assertTrue(callbackCalled[0]!!)
  }

  @Test
  fun initializer_onMethodCallWithNoRendererPreference() {
    doNothing()
        .whenever(googleMapInitializer)
        .initializeWithRendererRequest(null)
    val callbackCalled = arrayOfNulls<Boolean>(1)
    googleMapInitializer!!.initializeWithPreferredRenderer(
        null,
        asContinuation<PlatformRendererType?> { result: ResultCompat<PlatformRendererType?>? ->
          callbackCalled[0] = true
          val error = result!!.exceptionOrNull()
          Assert.assertNull(error)
          Unit
        })
    googleMapInitializer!!.onMapsSdkInitialized(MapsInitializer.Renderer.LATEST)

    Assert.assertTrue(callbackCalled[0]!!)
  }
}
