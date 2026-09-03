// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import java.util.Locale;

/**
 * Opt-in event logging for diagnosing what a texture shows between two videos; the Android half of
 * FVPDiag in video_player_avfoundation.
 *
 * <p>A page reveals its video texture when the plugin reports the player ready. Whether that texture
 * has a frame by then cannot be seen from Dart, which learns only that ExoPlayer reached {@code
 * STATE_READY}. These events timestamp the load and the first rendered frame against the same wall
 * clock the Dart side logs, so tool/videodiag/analyze.py in the app repo can interleave them.
 *
 * <p>Off unless the app calls {@code setEnabled} on the {@code flutter.dev/videoPlayer/diag} method
 * channel, so a normal build pays one already-resolved boolean per event.
 *
 * <p>Unlike the AVFoundation side there is no {@code setFirstFrameGating} or {@code
 * setPlaceholderHoldMs} here: neither the readiness gate nor the placeholder buffer they switch
 * exists on Android, where {@code loadAsset} gets a brand new SurfaceProducer instead. Those calls
 * are answered {@code notImplemented} rather than silently accepted, so a harness cannot believe it
 * turned off something that was never on.
 */
public final class VideoPlayerDiag {
  private static final String TAG = "VideoDiag";
  private static final String CHANNEL = "flutter.dev/videoPlayer/diag";

  private static volatile boolean enabled = false;
  private static MethodChannel channel;

  private VideoPlayerDiag() {}

  public static boolean isEnabled() {
    return enabled;
  }

  static void startListening(@NonNull BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, CHANNEL);
    channel.setMethodCallHandler(
        (call, result) -> {
          if ("setEnabled".equals(call.method)) {
            enabled = Boolean.TRUE.equals(call.arguments());
            result.success(null);
          } else {
            result.notImplemented();
          }
        });
  }

  static void stopListening() {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
    enabled = false;
  }

  /**
   * Logs one {@code [VideoDiag/android]} line: an event name plus {@code key=value} fields, prefixed
   * with the wall clock in milliseconds so the app's own {@code [VideoDiag]} lines interleave with
   * these. Field values must not contain spaces -- the parser splits on them.
   */
  public static void log(@NonNull String format, Object... args) {
    if (!enabled) {
      return;
    }
    android.util.Log.i(
        TAG,
        String.format(
            Locale.US,
            "[VideoDiag/android] t=%d.000 %s",
            System.currentTimeMillis(),
            String.format(Locale.US, format, args)));
  }

  /** The filename of {@code url}, without the query string a CDN URL carries. */
  @NonNull
  public static String shortUrl(String url) {
    if (url == null || url.isEmpty()) {
      return "none";
    }
    String withoutQuery = url.split("\\?")[0];
    int slash = withoutQuery.lastIndexOf('/');
    String name = slash < 0 ? withoutQuery : withoutQuery.substring(slash + 1);
    return name.isEmpty() ? "none" : name;
  }
}
