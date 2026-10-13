// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.google.android.gms.maps.MapsInitializer
import io.flutter.plugin.common.BinaryMessenger
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.async
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
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

  private val mockMessenger: BinaryMessenger = mock()

  @Before
  fun before() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    googleMapInitializer = spy(GoogleMapInitializer(context, mockMessenger))
  }

  @Test
  fun initializer_OnMapsSdkInitializedWithLatestRenderer() = runTest {
    doNothing()
        .whenever(googleMapInitializer)
        .initializeWithRendererRequest(MapsInitializer.Renderer.LATEST)
    val type =
        async(start = CoroutineStart.UNDISPATCHED) {
          googleMapInitializer.initializeWithPreferredRenderer(PlatformRendererType.LATEST)
        }
    googleMapInitializer.onMapsSdkInitialized(MapsInitializer.Renderer.LATEST)

    assertEquals(PlatformRendererType.LATEST, type.await())
  }

  @Suppress("deprecation")
  @Test
  fun initializer_OnMapsSdkInitializedWithLegacyRenderer() = runTest {
    doNothing()
        .whenever(googleMapInitializer)
        .initializeWithRendererRequest(MapsInitializer.Renderer.LEGACY)
    val type =
        async(start = CoroutineStart.UNDISPATCHED) {
          googleMapInitializer.initializeWithPreferredRenderer(PlatformRendererType.LEGACY)
        }
    googleMapInitializer.onMapsSdkInitialized(MapsInitializer.Renderer.LEGACY)

    assertEquals(PlatformRendererType.LEGACY, type.await())
  }

  @Test
  fun initializer_onMethodCallWithNoRendererPreference() = runTest {
    doNothing().whenever(googleMapInitializer).initializeWithRendererRequest(null)
    val type =
        async(start = CoroutineStart.UNDISPATCHED) {
          googleMapInitializer.initializeWithPreferredRenderer(null)
        }
    googleMapInitializer.onMapsSdkInitialized(MapsInitializer.Renderer.LATEST)

    assertNotNull(type.await())
  }
}
