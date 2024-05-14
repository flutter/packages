package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdError
import com.google.ads.interactivemedia.v3.api.player.AdMediaInfo
import org.mockito.Mockito
import org.mockito.kotlin.whenever
import kotlin.test.Test
import kotlin.test.assertEquals

class AdMediaInfoProxyApiTest {
  @Test
  fun url() {
    val api = ProxyApiRegistrar(Mockito.mock(), Mockito.mock()).getPigeonApiAdMediaInfo()

    val instance = Mockito.mock<AdMediaInfo>()
    whenever(instance.url).thenReturn("url")

    assertEquals("url", api.url(instance))
  }
}