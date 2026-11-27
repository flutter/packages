// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.test.utils.FakeMediaSourceFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewRegistry
import io.flutter.plugins.videoplayer.platformview.PlatformViewVideoPlayer
import io.flutter.plugins.videoplayer.texture.TextureVideoPlayer
import io.flutter.view.TextureRegistry
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.eq
import org.mockito.ArgumentMatchers.isNull
import org.mockito.Mockito.doThrow
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class VideoPlayerAndroidExternalApiTest {
  private val bindings = mutableListOf<FlutterPluginBinding>()
  private val createdAssets = mutableListOf<VideoAsset>()
  private val context: Context = mock(Context::class.java)
  private lateinit var binding: FlutterPluginBinding

  @Before
  fun setUp() {
    binding = createMockBinding()
  }

  @After
  fun tearDown() {
    // The registry is process-wide, so providers would otherwise leak into other tests.
    for (binding in bindings) {
      VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding, null)
    }
  }

  private fun createMockBinding(): FlutterPluginBinding {
    val textureRegistry = mock(TextureRegistry::class.java)
    `when`(textureRegistry.createSurfaceProducer())
        .thenReturn(mock(TextureRegistry.SurfaceProducer::class.java))
    val binding = mock(FlutterPluginBinding::class.java)
    `when`(binding.applicationContext).thenReturn(context)
    `when`(binding.textureRegistry).thenReturn(textureRegistry)
    `when`(binding.binaryMessenger).thenReturn(mock(BinaryMessenger::class.java))
    `when`(binding.platformViewRegistry).thenReturn(mock(PlatformViewRegistry::class.java))
    bindings.add(binding)
    return binding
  }

  private fun createPlugin(
      createPlatformViewPlayer: PlatformViewPlayerConstructor = { _, _, asset, _ ->
        createdAssets.add(asset)
        mock(PlatformViewVideoPlayer::class.java)
      },
      createTexturePlayer: TexturePlayerConstructor = { _, _, _, asset, _ ->
        createdAssets.add(asset)
        mock(TextureVideoPlayer::class.java)
      }
  ): VideoPlayerPlugin {
    val plugin = VideoPlayerPlugin(createPlatformViewPlayer, createTexturePlayer)
    plugin.onAttachedToEngine(binding)
    return plugin
  }

  private fun createOptions(
      uri: String = URL,
      formatHint: PlatformVideoFormat? = null,
      httpHeaders: Map<String, String> = emptyMap(),
      userAgent: String? = null
  ) = CreationOptions(uri, formatHint, httpHeaders, userAgent, null)

  private fun setConfigProvider(
      binding: FlutterPluginBinding = this.binding,
      mediaItem: MediaItem = MediaItem.fromUri(URL)
  ) {
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) {
      VideoPlayerAndroidExternalApi.MediaConfig(mediaItem, FakeMediaSourceFactory())
    }
  }

  @Test
  fun providerConfiguresTexturePlayer() {
    val mediaItem = MediaItem.fromUri(URL)
    val mediaSourceFactory = FakeMediaSourceFactory()
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) {
      VideoPlayerAndroidExternalApi.MediaConfig(mediaItem, mediaSourceFactory)
    }

    createPlugin().createForTextureView(createOptions())

    val asset = createdAssets.single()
    assertSame(mediaItem, asset.mediaItem)
    assertSame(mediaSourceFactory, asset.getMediaSourceFactory(context))
  }

  @Test
  fun providerConfiguresPlatformViewPlayer() {
    val mediaItem = MediaItem.fromUri(URL)
    val mediaSourceFactory = FakeMediaSourceFactory()
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) {
      VideoPlayerAndroidExternalApi.MediaConfig(mediaItem, mediaSourceFactory)
    }

    createPlugin().createForPlatformView(createOptions())

    val asset = createdAssets.single()
    assertSame(mediaItem, asset.mediaItem)
    assertSame(mediaSourceFactory, asset.getMediaSourceFactory(context))
  }

  @Test
  fun providerReceivesCreationOptions() {
    val requests = mutableListOf<VideoPlayerAndroidExternalApi.MediaConfigRequest>()
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) { request ->
      requests.add(request)
      null
    }
    val httpHeaders = mapOf("Authorization" to "Bearer token")

    createPlugin()
        .createForTextureView(createOptions(httpHeaders = httpHeaders, userAgent = "agent"))

    val request = requests.single()
    assertSame(context, request.context)
    assertEquals(URL, request.uri)
    assertNull(request.mimeType)
    assertEquals(httpHeaders, request.httpHeaders)
    assertEquals("agent", request.userAgent)
  }

  @Test
  fun providerReceivesMimeTypeOfFormatHint() {
    val mimeTypes = mutableListOf<String?>()
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) { request ->
      mimeTypes.add(request.mimeType)
      null
    }
    val plugin = createPlugin()

    plugin.createForTextureView(createOptions(formatHint = PlatformVideoFormat.HLS))
    plugin.createForTextureView(createOptions(formatHint = PlatformVideoFormat.DASH))
    plugin.createForTextureView(createOptions(formatHint = PlatformVideoFormat.SS))

    assertEquals(
        listOf(MimeTypes.APPLICATION_M3U8, MimeTypes.APPLICATION_MPD, MimeTypes.APPLICATION_SS),
        mimeTypes)
  }

  @Test
  fun providerCannotModifyHeadersOfFallback() {
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) { request ->
      @Suppress("UNCHECKED_CAST") val headers = request.httpHeaders as MutableMap<String, String>
      assertThrows(UnsupportedOperationException::class.java) { headers["X-Injected"] = "1" }
      null
    }

    createPlugin()
        .createForTextureView(createOptions(httpHeaders = mutableMapOf("Authorization" to "a")))

    assertTrue(createdAssets.single() is HttpVideoAsset)
  }

  @Test
  fun nullConfigFallsBackToDefaultHandling() {
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) { null }

    createPlugin().createForTextureView(createOptions())

    assertTrue(createdAssets.single() is HttpVideoAsset)
  }

  @Test
  fun providerSetAfterAttachIsUsed() {
    val mediaItem = MediaItem.fromUri(URL)
    val plugin = createPlugin()
    setConfigProvider(mediaItem = mediaItem)

    plugin.createForTextureView(createOptions())

    assertSame(mediaItem, createdAssets.single().mediaItem)
  }

  @Test
  fun latestProviderReplacesEarlierOne() {
    val mediaItem = MediaItem.fromUri(URL)
    setConfigProvider()
    setConfigProvider(mediaItem = mediaItem)

    createPlugin().createForTextureView(createOptions())

    assertSame(mediaItem, createdAssets.single().mediaItem)
  }

  @Test
  fun providerOnlyAppliesToItsEngine() {
    setConfigProvider(binding = createMockBinding())

    createPlugin().createForTextureView(createOptions())

    assertTrue(createdAssets.single() is HttpVideoAsset)
  }

  @Test
  fun settingNullRemovesProvider() {
    setConfigProvider()
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding, null)

    createPlugin().createForTextureView(createOptions())

    assertTrue(createdAssets.single() is HttpVideoAsset)
  }

  @Test
  fun providerSurvivesPluginReattach() {
    val mediaItem = MediaItem.fromUri(URL)
    setConfigProvider(mediaItem = mediaItem)
    createPlugin().onDetachedFromEngine(binding)

    createPlugin().createForTextureView(createOptions())

    assertSame(mediaItem, createdAssets.single().mediaItem)
  }

  @Test
  fun providerIsConsultedForAssetAndRtspUris() {
    val mediaItem = MediaItem.fromUri(URL)
    val requestedUris = mutableListOf<String>()
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) { request ->
      requestedUris.add(request.uri)
      VideoPlayerAndroidExternalApi.MediaConfig(mediaItem, FakeMediaSourceFactory())
    }
    val plugin = createPlugin()
    val assetUri = "asset:///flutter_assets/assets/video.mp4"
    val rtspUri = "rtsp://example.com/stream"

    plugin.createForTextureView(createOptions(uri = assetUri))
    plugin.createForTextureView(createOptions(uri = rtspUri))

    assertEquals(listOf(assetUri, rtspUri), requestedUris)
    assertEquals(2, createdAssets.size)
    for (asset in createdAssets) {
      assertTrue(asset is ExternalVideoAsset)
      assertSame(mediaItem, asset.mediaItem)
    }
  }

  @Test
  fun providerExceptionPropagatesWithoutCreatingPlayer() {
    val failure = RuntimeException("provider failed")
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding) { throw failure }
    val plugin = createPlugin()

    val thrown =
        assertThrows(RuntimeException::class.java) { plugin.createForTextureView(createOptions()) }

    assertSame(failure, thrown)
    assertTrue(createdAssets.isEmpty())
    verify(binding.textureRegistry, never()).createSurfaceProducer()
  }

  @Test
  fun failedTexturePlayerCreationReleasesSurfaceAndEvents() {
    setConfigProvider()
    val surfaceProducer = mock(TextureRegistry.SurfaceProducer::class.java)
    `when`(binding.textureRegistry.createSurfaceProducer()).thenReturn(surfaceProducer)
    val plugin = createPlugin(createTexturePlayer = { _, _, _, _, _ -> throw FAILURE })

    assertThrows(IllegalStateException::class.java) { plugin.createForTextureView(createOptions()) }

    verify(surfaceProducer).release()
    verify(binding.binaryMessenger).setMessageHandler(eq(eventChannelName(1)), isNull())
  }

  @Test
  fun failedPlatformViewPlayerCreationReleasesEvents() {
    setConfigProvider()
    val plugin = createPlugin(createPlatformViewPlayer = { _, _, _, _ -> throw FAILURE })

    assertThrows(IllegalStateException::class.java) {
      plugin.createForPlatformView(createOptions())
    }

    verify(binding.binaryMessenger).setMessageHandler(eq(eventChannelName(1)), isNull())
  }

  @Test
  fun configFailingInPlayerConstructionReleasesExoPlayer() {
    val exoPlayer = mock(ExoPlayer::class.java)
    val mediaItem = MediaItem.Builder().setMediaId("no-uri").build()
    doThrow(FAILURE).`when`(exoPlayer).setMediaItem(mediaItem)

    assertThrows(IllegalStateException::class.java) {
      TextureVideoPlayer(
          mock(VideoPlayerCallbacks::class.java),
          mock(TextureRegistry.SurfaceProducer::class.java),
          mediaItem,
          VideoPlayerOptions()) {
            exoPlayer
          }
    }

    verify(exoPlayer).release()
  }

  private companion object {
    const val URL = "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
    val FAILURE = IllegalStateException("player construction failed")

    fun eventChannelName(playerId: Long) =
        "dev.flutter.pigeon.video_player_android.VideoEventChannel.videoEvents.$playerId"
  }
}
