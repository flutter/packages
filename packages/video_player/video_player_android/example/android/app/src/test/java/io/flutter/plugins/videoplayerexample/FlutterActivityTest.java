// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayerexample;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.plugins.videoplayer.VideoPlayerPlugin;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(manifest = Config.NONE)
public class FlutterActivityTest {
  AutoCloseable mockCloseable;
  @Mock FlutterPlugin.FlutterPluginBinding flutterPluginBinding;

  @Before
  public void before() {
    mockCloseable = MockitoAnnotations.openMocks(this);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void disposeAllPlayers() {
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mock(Context.class));
    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getPlatformViewRegistry())
        .thenReturn(mock(PlatformViewRegistry.class));

    VideoPlayerPlugin videoPlayerPlugin = spy(new VideoPlayerPlugin());

    videoPlayerPlugin.onAttachedToEngine(flutterPluginBinding);
    videoPlayerPlugin.onDetachedFromEngine(flutterPluginBinding);
    verify(videoPlayerPlugin, times(1)).onDestroy();
  }
}
