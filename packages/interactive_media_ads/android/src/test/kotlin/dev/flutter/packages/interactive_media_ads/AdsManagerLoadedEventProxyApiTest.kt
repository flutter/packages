package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdError
import com.google.ads.interactivemedia.v3.api.AdsManager
import com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent
import org.mockito.Mockito
import org.mockito.kotlin.whenever
import kotlin.test.Test
import kotlin.test.assertEquals

class AdsManagerLoadedEventProxyApiTest {
  @Test
  fun manager() {
    val api = ProxyApiRegistrar(Mockito.mock(), Mockito.mock()).getPigeonApiAdsManagerLoadedEvent()

    val instance = Mockito.mock<AdsManagerLoadedEvent>()
    val mockManager = Mockito.mock<AdsManager>()
    whenever(instance.adsManager).thenReturn(mockManager)

    assertEquals(mockManager, api.manager(instance))
  }
}