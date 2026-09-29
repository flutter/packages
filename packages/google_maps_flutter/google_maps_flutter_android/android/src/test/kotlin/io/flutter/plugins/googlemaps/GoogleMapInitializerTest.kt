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
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.MockitoAnnotations
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class GoogleMapInitializerTest {
  private var googleMapInitializer: GoogleMapInitializer? = null

  @Mock var mockMessenger: BinaryMessenger? = null

  @Before
  fun before() {
    MockitoAnnotations.openMocks(this)
    val context = ApplicationProvider.getApplicationContext<Context?>()
    googleMapInitializer =
        Mockito.spy<GoogleMapInitializer>(GoogleMapInitializer(context, mockMessenger))
  }

  @Test
  fun initializer_OnMapsSdkInitializedWithLatestRenderer() {
    Mockito.doNothing()
        .`when`<GoogleMapInitializer?>(googleMapInitializer)
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
    Mockito.doNothing()
        .`when`<GoogleMapInitializer?>(googleMapInitializer)
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
    Mockito.doNothing()
        .`when`<GoogleMapInitializer?>(googleMapInitializer)
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
