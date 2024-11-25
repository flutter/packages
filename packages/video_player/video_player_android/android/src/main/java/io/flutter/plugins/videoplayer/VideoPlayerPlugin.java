// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import android.util.LongSparseArray;
import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.util.UnstableApi;

import io.flutter.FlutterInjector;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.videoplayer.Messages.AndroidVideoPlayerApi;
import io.flutter.plugins.videoplayer.Messages.CreateMessage;
import io.flutter.plugins.videoplayer.Messages.LoopingMessage;
import io.flutter.plugins.videoplayer.Messages.MixWithOthersMessage;
import io.flutter.plugins.videoplayer.Messages.PlaybackSpeedMessage;
import io.flutter.plugins.videoplayer.Messages.PositionMessage;
import io.flutter.plugins.videoplayer.Messages.TextureMessage;
import io.flutter.plugins.videoplayer.Messages.TrackSelectionsMessage;
import io.flutter.plugins.videoplayer.Messages.VolumeMessage;
import io.flutter.view.TextureRegistry;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;
import javax.net.ssl.HttpsURLConnection;

/** Android platform implementation of the VideoPlayerPlugin. */
@OptIn(markerClass = UnstableApi.class)
public class VideoPlayerPlugin implements FlutterPlugin, AndroidVideoPlayerApi {
  private static final String TAG = "VideoPlayerPlugin";
  private final LongSparseArray<VideoPlayer> videoPlayers = new LongSparseArray<>();
  private FlutterState flutterState;
  private final VideoPlayerOptions options = new VideoPlayerOptions();

  /** Register this with the v2 embedding for the plugin to respond to lifecycle callbacks. */
  public VideoPlayerPlugin() {}

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    final FlutterInjector injector = FlutterInjector.instance();
    this.flutterState =
        new FlutterState(
            binding.getApplicationContext(),
            binding.getBinaryMessenger(),
            injector.flutterLoader()::getLookupKeyForAsset,
            injector.flutterLoader()::getLookupKeyForAsset,
            binding.getTextureRegistry());
    flutterState.startListening(this, binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (flutterState == null) {
      Log.wtf(TAG, "Detached from the engine before registering to it.");
    }
    flutterState.stopListening(binding.getBinaryMessenger());
    flutterState = null;
    onDestroy();
  }

  private void disposeAllPlayers() {
    for (int i = 0; i < videoPlayers.size(); i++) {
      videoPlayers.valueAt(i).dispose();
    }
    videoPlayers.clear();
  }

  public void onDestroy() {
    // The whole FlutterView is being destroyed. Here we release resources acquired for all
    // instances
    // of VideoPlayer. Once https://github.com/flutter/flutter/issues/19358 is resolved this may
    // be replaced with just asserting that videoPlayers.isEmpty().
    // https://github.com/flutter/flutter/issues/20989 tracks this.
    disposeAllPlayers();
  }

  public void initialize() {
    disposeAllPlayers();
  }

  public @NonNull TextureMessage create(@NonNull CreateMessage arg) {
    TextureRegistry.SurfaceProducer handle = flutterState.textureRegistry.createSurfaceProducer();
    EventChannel eventChannel =
        new EventChannel(
            flutterState.binaryMessenger, "flutter.io/videoPlayer/videoEvents" + handle.id());

    final VideoAsset videoAsset;
    if (arg.getAsset() != null) {
      String assetLookupKey;
      if (arg.getPackageName() != null) {
        assetLookupKey =
            flutterState.keyForAssetAndPackageName.get(arg.getAsset(), arg.getPackageName());
      } else {
        assetLookupKey = flutterState.keyForAsset.get(arg.getAsset());
      }
      videoAsset = VideoAsset.fromAssetUrl("asset:///" + assetLookupKey);
    } else if (arg.getUri().startsWith("rtsp://")) {
      videoAsset = VideoAsset.fromRtspUrl(arg.getUri());
    } else {
      VideoAsset.StreamingFormat streamingFormat = VideoAsset.StreamingFormat.UNKNOWN;
      String formatHint = arg.getFormatHint();
      if (formatHint != null) {
        switch (formatHint) {
          case "ss":
            streamingFormat = VideoAsset.StreamingFormat.SMOOTH;
            break;
          case "dash":
            streamingFormat = VideoAsset.StreamingFormat.DYNAMIC_ADAPTIVE;
            break;
          case "hls":
            streamingFormat = VideoAsset.StreamingFormat.HTTP_LIVE;
            break;
        }
      }
      videoAsset = VideoAsset.fromRemoteUrl(arg.getUri(), streamingFormat, arg.getHttpHeaders());
    }
    videoPlayers.put(
        handle.id(),
        VideoPlayer.create(
            flutterState.applicationContext,
            VideoPlayerEventCallbacks.bindTo(eventChannel),
            handle,
            videoAsset,
            options));

    return new TextureMessage.Builder().setTextureId(handle.id()).build();
  }

  @NonNull
  private VideoPlayer getPlayer(long textureId) {
    VideoPlayer player = videoPlayers.get(textureId);

    // Avoid a very ugly un-debuggable NPE that results in returning a null player.
    if (player == null) {
      String message = "No player found with textureId <" + textureId + ">";
      if (videoPlayers.size() == 0) {
        message += " and no active players created by the plugin.";
      }
      throw new IllegalStateException(message);
    }

    return player;
  }

  public void dispose(@NonNull TextureMessage arg) {
    VideoPlayer player = getPlayer(arg.getTextureId());
    player.dispose();
    videoPlayers.remove(arg.getTextureId());
  }

  public void setLooping(@NonNull LoopingMessage arg) {
    VideoPlayer player = getPlayer(arg.getTextureId());
    player.setLooping(arg.getIsLooping());
  }

  public void setVolume(@NonNull VolumeMessage arg) {
    VideoPlayer player = getPlayer(arg.getTextureId());
    player.setVolume(arg.getVolume());
  }

  public void setPlaybackSpeed(@NonNull PlaybackSpeedMessage arg) {
    VideoPlayer player = getPlayer(arg.getTextureId());
    player.setPlaybackSpeed(arg.getSpeed());
  }

  public void play(@NonNull TextureMessage arg) {
    VideoPlayer player = getPlayer(arg.getTextureId());
    player.play();
  }

  public @NonNull PositionMessage position(@NonNull TextureMessage arg) {
    VideoPlayer player = getPlayer(arg.getTextureId());
    PositionMessage result =
        new PositionMessage.Builder()
            .setPosition(player.getPosition())
            .setTextureId(arg.getTextureId())
            .build();
    player.sendBufferingUpdate();
    return result;
  }

  public void seekTo(@NonNull PositionMessage arg) {
    VideoPlayer player = getPlayer(arg.getTextureId());
    player.seekTo(arg.getPosition().intValue());
  }

  @NonNull
  @OptIn(markerClass = UnstableApi.class)
  public TrackSelectionsMessage trackSelections(TextureMessage arg) {
    System.err.println("xxx : tracks 5 ...");
    VideoPlayer player = videoPlayers.get(arg.getTextureId());
    TrackSelectionsMessage result = new TrackSelectionsMessage();
    result.setTextureId(arg.getTextureId());
    result.setTrackSelections(player.getTrackSelections());
    System.err.println("xxx : tracks 51 ...");
    System.err.println(result.toString());
    return result;
  }

  public void setTrackSelection(TrackSelectionsMessage arg) {
    System.err.println("xxx : setTrackSelection : " + arg.toList());
    VideoPlayer player = videoPlayers.get(arg.getTextureId());
    player.setTrackSelection(arg.getTrackId(), arg.getTrackType().intValue());

  }
  public void pause(@NonNull TextureMessage arg) {
    VideoPlayer player = getPlayer(arg.getTextureId());
    player.pause();
  }

  @Override
  public void setMixWithOthers(@NonNull MixWithOthersMessage arg) {
    options.mixWithOthers = arg.getMixWithOthers();
  }

  private interface KeyForAssetFn {
    String get(String asset);
  }

  private interface KeyForAssetAndPackageName {
    String get(String asset, String packageName);
  }

  private static final class FlutterState {
    final Context applicationContext;
    final BinaryMessenger binaryMessenger;
    final KeyForAssetFn keyForAsset;
    final KeyForAssetAndPackageName keyForAssetAndPackageName;
    final TextureRegistry textureRegistry;

    FlutterState(
        Context applicationContext,
        BinaryMessenger messenger,
        KeyForAssetFn keyForAsset,
        KeyForAssetAndPackageName keyForAssetAndPackageName,
        TextureRegistry textureRegistry) {
      this.applicationContext = applicationContext;
      this.binaryMessenger = messenger;
      this.keyForAsset = keyForAsset;
      this.keyForAssetAndPackageName = keyForAssetAndPackageName;
      this.textureRegistry = textureRegistry;
    }

    void startListening(VideoPlayerPlugin methodCallHandler, BinaryMessenger messenger) {
      AndroidVideoPlayerApi.setUp(messenger, methodCallHandler);
    }

    void stopListening(BinaryMessenger messenger) {
      AndroidVideoPlayerApi.setUp(messenger, null);
    }
  }
}
