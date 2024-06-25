package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThrows;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.net.Uri;
import androidx.media3.common.MediaItem;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.test.core.app.ApplicationProvider;
import java.util.HashMap;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

/**
 * Unit tests for {@link VideoAsset}.
 *
 * <p>This test suite <em>narrowly verifies</em> that the {@link VideoAsset} factory methods, {@link
 * VideoAsset#fromRemoteUrl(String, VideoAsset.StreamingFormat, Map)} and {@link
 * VideoAsset#fromAssetUrl(String)} follow the contract they have documented.
 *
 * <p>In other tests of the player, a fake asset is likely to be used.
 */
@RunWith(RobolectricTestRunner.class)
public final class VideoAssetTest {
  @Test
  public void localVideoRequiresAssetUrl() {
    assertThrows(
        IllegalArgumentException.class,
        () -> VideoAsset.fromAssetUrl("https://not.local/video.mp4"));
  }

  @Test
  public void localVideoCreatesMediaItem() {
    VideoAsset asset = VideoAsset.fromAssetUrl("asset:///asset-key");
    MediaItem mediaItem = asset.getMediaItem();

    assert mediaItem.localConfiguration != null;
    assertEquals(mediaItem.localConfiguration.uri, Uri.parse("asset:///asset-key"));
  }

  private static DefaultHttpDataSource.Factory mockHttpFactory() {
    DefaultHttpDataSource.Factory httpFactory = mock(DefaultHttpDataSource.Factory.class);
    when(httpFactory.setUserAgent(anyString())).thenReturn(httpFactory);
    when(httpFactory.setAllowCrossProtocolRedirects(anyBoolean())).thenReturn(httpFactory);
    when(httpFactory.setDefaultRequestProperties(anyMap())).thenReturn(httpFactory);
    return httpFactory;
  }

  @Test
  public void remoteVideoByDefaultSetsUserAgentAndCrossProtocolRedirects() throws Exception {
    VideoAsset asset =
        VideoAsset.fromRemoteUrl(
            "https://flutter.dev/video.mp4", VideoAsset.StreamingFormat.Unknown, new HashMap<>());

    DefaultHttpDataSource.Factory mockFactory = mockHttpFactory();
    asset.getMediaSourceFactory(ApplicationProvider.getApplicationContext(), mockFactory);

    verify(mockFactory).setUserAgent("ExoPlayer");
    verify(mockFactory).setAllowCrossProtocolRedirects(true);
    verify(mockFactory, never()).setDefaultRequestProperties(anyMap());
  }

  @Test
  public void remoteVideoOverridesUserAgentIfProvided() throws Exception {
    Map<String, String> headers = new HashMap<>();
    headers.put("User-Agent", "FantasticalVideoBot");

    VideoAsset asset =
        VideoAsset.fromRemoteUrl(
            "https://flutter.dev/video.mp4", VideoAsset.StreamingFormat.Unknown, headers);

    DefaultHttpDataSource.Factory mockFactory = mockHttpFactory();
    asset.getMediaSourceFactory(ApplicationProvider.getApplicationContext(), mockFactory);

    verify(mockFactory).setUserAgent("FantasticalVideoBot");
    verify(mockFactory).setAllowCrossProtocolRedirects(true);
    verify(mockFactory).setDefaultRequestProperties(headers);
  }

  @Test
  public void remoteVideoSetsAdditionalHttpHeadersIfProvided() throws Exception {
    Map<String, String> headers = new HashMap<>();
    headers.put("X-Cache-Forever", "true");

    VideoAsset asset =
        VideoAsset.fromRemoteUrl(
            "https://flutter.dev/video.mp4", VideoAsset.StreamingFormat.Unknown, headers);

    DefaultHttpDataSource.Factory mockFactory = mockHttpFactory();
    asset.getMediaSourceFactory(ApplicationProvider.getApplicationContext(), mockFactory);

    verify(mockFactory).setUserAgent("ExoPlayer");
    verify(mockFactory).setAllowCrossProtocolRedirects(true);
    verify(mockFactory).setDefaultRequestProperties(headers);
  }
}
