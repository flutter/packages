package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import kotlin.test.Test

class AdsRequestProxyApiTest {
  @Test
  fun setAdTagUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    api.setAdTagUrl(instance, "adTag")

    verify(instance).adTagUrl = "adTag"
  }

  @Test
  fun setContentProgressProvider() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val mockProvider = mock< ContentProgressProvider>()
    api.setContentProgressProvider(instance, mockProvider)

    verify(instance).contentProgressProvider = mockProvider
  }
}