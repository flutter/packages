package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsRequest
import org.mockito.Mockito
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import kotlin.test.Test

class AdsLoaderProxyApiTest {
  @Test
  fun addAdErrorListener() {
    val api = ProxyApiRegistrar(Mockito.mock(), Mockito.mock()).getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val mockListener = mock<AdErrorEvent.AdErrorListener>()
    api.addAdErrorListener(instance, mockListener)

    verify(instance).addAdErrorListener(mockListener)
  }

  @Test
  fun addAdsLoadedListener() {
    val api = ProxyApiRegistrar(Mockito.mock(), Mockito.mock()).getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val mockListener = mock<AdsLoader.AdsLoadedListener>()
    api.addAdsLoadedListener(instance, mockListener)

    verify(instance).addAdsLoadedListener(mockListener)
  }

  @Test
  fun requestAds() {
    val api = ProxyApiRegistrar(Mockito.mock(), Mockito.mock()).getPigeonApiAdsLoader()

    val instance = mock<AdsLoader>()
    val mockRequest = mock<AdsRequest>()
    api.requestAds(instance, mockRequest)

    verify(instance).requestAds(mockRequest)
  }
}