package dev.flutter.packages.interactive_media_ads

import android.media.MediaPlayer
import com.google.ads.interactivemedia.v3.api.AdsManager
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

import kotlin.test.Test
import kotlin.test.assertEquals

class MediaPlayerProxyApiTest {
  @Test
  fun getDuration() {
    val api = TestProxyApiRegistrar().getPigeonApiMediaPlayer()

    val instance = mock<MediaPlayer>()
    whenever(instance.duration).thenReturn(0)

    assertEquals(0, api.getDuration(instance))
  }

  @Test
  fun seekTo() {
    val api = TestProxyApiRegistrar().getPigeonApiMediaPlayer()

    val instance = mock<MediaPlayer>()
    api.seekTo(instance, 0)

    verify(instance).seekTo(0)
  }

  @Test
  fun start() {
    val api = TestProxyApiRegistrar().getPigeonApiMediaPlayer()

    val instance = mock<MediaPlayer>()
    api.start(instance)

    verify(instance).start()
  }

  @Test
  fun pause() {
    val api = TestProxyApiRegistrar().getPigeonApiMediaPlayer()

    val instance = mock<MediaPlayer>()
    api.pause(instance)

    verify(instance).pause()
  }

  @Test
  fun stop() {
    val api = TestProxyApiRegistrar().getPigeonApiMediaPlayer()

    val instance = mock<MediaPlayer>()
    api.stop(instance)

    verify(instance).stop()
  }
}