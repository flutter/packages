package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdEvent
import com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.whenever
import kotlin.test.Test
import kotlin.test.assertTrue

class AdsLoadedListenerProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = ProxyApiRegistrar(Mockito.mock(), Mockito.mock()).getPigeonApiAdsLoadedListener()

    assertTrue(api.pigeon_defaultConstructor() is AdsLoadedListenerProxyApi.AdsLoadedListenerImpl)
  }

  @Test
  fun onAdsManagerLoaded() {
    val mockApi = Mockito.mock<AdsLoadedListenerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = AdsLoadedListenerProxyApi.AdsLoadedListenerImpl(mockApi)
    val mockEvent = Mockito.mock<AdsManagerLoadedEvent>()
    instance.onAdsManagerLoaded(mockEvent)

    Mockito.verify(mockApi).onAdsManagerLoaded(eq(instance), eq(mockEvent), any())
  }
}