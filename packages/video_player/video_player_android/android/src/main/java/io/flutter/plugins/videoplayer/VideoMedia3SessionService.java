// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MediaMetadata;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.session.CommandButton;
import androidx.media3.session.DefaultMediaNotificationProvider;
import androidx.media3.session.MediaSession;
import androidx.media3.session.MediaSessionService;
import androidx.media3.session.SessionCommand;
import androidx.media3.session.SessionResult;
import com.google.common.collect.ImmutableList;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Media3 MediaSessionService for background video playback. Implements the modern Media3
 * MediaSession API for automatic notification management and better system integration.
 *
 * <p>Based on: https://developer.android.com/media/media3/session/background-playback
 */
public class VideoMedia3SessionService extends MediaSessionService {
  private static final String TAG = "VideoMedia3SessionService";
  private static final String CHANNEL_ID = "video_player_channel";

  // Map of texture IDs to media sessions
  private final Map<Integer, MediaSession> mediaSessions = new HashMap<>();

  // Track the primary session for the service
  @Nullable private MediaSession primarySession = null;

  // Executor for async operations like artwork loading
  private final ExecutorService executorService = Executors.newCachedThreadPool();

  // Handler for main thread operations
  private final Handler mainHandler = new Handler(Looper.getMainLooper());

  // Binder for local service connection
  private final android.os.IBinder binder = new LocalBinder();

  /** Local binder for binding to this service from VideoPlayerPlugin. */
  public class LocalBinder extends android.os.Binder {
    public VideoMedia3SessionService getService() {
      return VideoMedia3SessionService.this;
    }
  }

  @Override
  public void onCreate() {
    super.onCreate();

    // Create notification channel FIRST (required for Android O+)
    createNotificationChannel();

    // Configure Media3 to automatically handle notifications
    setMediaNotificationProvider(
        new DefaultMediaNotificationProvider.Builder(this).setChannelId(CHANNEL_ID).build());

    Log.d(TAG, "VideoMedia3SessionService created with notification provider");
  }

  private void createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      NotificationChannel channel =
          new NotificationChannel(CHANNEL_ID, "Video Playback", NotificationManager.IMPORTANCE_LOW);
      channel.setDescription("Media playback controls");
      channel.setShowBadge(false);

      NotificationManager manager = getSystemService(NotificationManager.class);
      if (manager != null) {
        manager.createNotificationChannel(channel);
        Log.d(TAG, "Notification channel created: " + CHANNEL_ID);
      }
    }
  }

  @Override
  @Nullable
  public android.os.IBinder onBind(@NonNull Intent intent) {
    // If this is a MediaSession connection, use the superclass binding
    if (intent.getAction() != null
        && intent.getAction().equals(MediaSessionService.SERVICE_INTERFACE)) {
      return super.onBind(intent);
    }
    // Otherwise, return our local binder for plugin access
    return binder;
  }

  /**
   * Called when a controller (like MediaController or notification) requests the session. Returns
   * the primary MediaSession or null if none exists.
   */
  @Override
  @Nullable
  public MediaSession onGetSession(@NonNull MediaSession.ControllerInfo controllerInfo) {
    Log.d(TAG, "onGetSession called for controller: " + controllerInfo.getPackageName());
    return primarySession;
  }

  /**
   * Creates a MediaSession for a video player. This is the main entry point for enabling background
   * playback.
   *
   * @param textureId Unique identifier for the video player
   * @param player The ExoPlayer instance
   * @param notificationMetadata Metadata about the media being played
   * @return The created MediaSession, or null if creation fails
   */
  @Nullable
  public MediaSession createMediaSession(
      int textureId,
      @NonNull ExoPlayer player,
      @Nullable NotificationMetadataMessage notificationMetadata) {

    try {
      Log.d(TAG, "Creating Media3 MediaSession for texture: " + textureId);

      // Check if session already exists for this texture
      if (mediaSessions.containsKey(textureId)) {
        Log.w(TAG, "MediaSession already exists for texture: " + textureId);
        return mediaSessions.get(textureId);
      }

      // Validate player
      if (player == null) {
        Log.e(TAG, "Cannot create MediaSession with null player");
        return null;
      }

      // Update player metadata if provided
      if (notificationMetadata != null) {
        updatePlayerMetadata(player, notificationMetadata);
      }

      // Create session activity (opens the app when notification is tapped)
      Intent openAppIntent = getPackageManager().getLaunchIntentForPackage(getPackageName());
      if (openAppIntent != null) {
        openAppIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
      }
      PendingIntent sessionActivity =
          PendingIntent.getActivity(
              this,
              textureId,
              openAppIntent,
              PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);

      // Build MediaSession with callback
      MediaSession session =
          new MediaSession.Builder(this, player)
              .setId("video_player_" + textureId)
              .setSessionActivity(sessionActivity)
              .setCallback(new MediaSessionCallback())
              .build();

      // Store the session
      mediaSessions.put(textureId, session);

      // Set as primary session if first one
      if (primarySession == null) {
        primarySession = session;
        Log.d(TAG, "Set primary MediaSession for texture: " + textureId);
      }

      // CRITICAL: Register the session with Media3's notification system
      // This tells the MediaSessionService about the active session
      try {
        addSession(session);
        Log.d(TAG, "Called addSession() to register with Media3 notification system");
      } catch (Exception e) {
        Log.e(TAG, "Error calling addSession()", e);
      }

      // Add listener to log playback state changes for debugging
      player.addListener(
          new Player.Listener() {
            @Override
            public void onIsPlayingChanged(boolean isPlaying) {
              Log.d(TAG, "Player isPlaying changed: " + isPlaying);
            }

            @Override
            public void onPlaybackStateChanged(int playbackState) {
              String stateStr =
                  playbackState == Player.STATE_IDLE
                      ? "IDLE"
                      : playbackState == Player.STATE_BUFFERING
                          ? "BUFFERING"
                          : playbackState == Player.STATE_READY
                              ? "READY"
                              : playbackState == Player.STATE_ENDED ? "ENDED" : "UNKNOWN";
              Log.d(
                  TAG,
                  "Player playbackState changed: "
                      + stateStr
                      + " (isPlaying="
                      + player.isPlaying()
                      + ")");
            }
          });

      Log.d(
          TAG,
          "MediaSession created successfully for texture: "
              + textureId
              + ", player.isPlaying="
              + player.isPlaying()
              + ", playbackState="
              + player.getPlaybackState());
      return session;

    } catch (Exception e) {
      Log.e(TAG, "Error creating MediaSession for texture: " + textureId, e);
      return null;
    }
  }

  /**
   * Updates the metadata on an existing MediaSession.
   *
   * @param textureId The texture ID of the player
   * @param notificationMetadata The new metadata
   */
  public void updateMediaSessionMetadata(
      int textureId, @NonNull NotificationMetadataMessage notificationMetadata) {

    MediaSession session = mediaSessions.get(textureId);
    if (session == null) {
      Log.w(TAG, "No MediaSession found for texture: " + textureId);
      return;
    }

    Player player = session.getPlayer();
    if (player instanceof ExoPlayer) {
      updatePlayerMetadata((ExoPlayer) player, notificationMetadata);
    }
  }

  /**
   * Updates the ExoPlayer's current MediaItem with new metadata. This will automatically update the
   * notification.
   */
  private void updatePlayerMetadata(
      @NonNull ExoPlayer player, @NonNull NotificationMetadataMessage metadata) {

    MediaMetadata.Builder metadataBuilder = new MediaMetadata.Builder();

    if (metadata.getTitle() != null) {
      metadataBuilder.setTitle(metadata.getTitle());
      metadataBuilder.setDisplayTitle(metadata.getTitle());
    }
    if (metadata.getArtist() != null) {
      metadataBuilder.setArtist(metadata.getArtist());
    }
    if (metadata.getAlbum() != null) {
      metadataBuilder.setAlbumTitle(metadata.getAlbum());
    }

    // Load artwork asynchronously if provided
    if (metadata.getArtUri() != null) {
      loadArtworkAsync(
          metadata.getArtUri(),
          bitmap -> {
            if (bitmap != null) {
              mainHandler.post(
                  () -> {
                    try {
                      MediaMetadata currentMetadata = player.getMediaMetadata();
                      MediaMetadata.Builder updatedBuilder = currentMetadata.buildUpon();

                      byte[] artworkData = bitmapToByteArray(bitmap);
                      updatedBuilder.setArtworkData(
                          artworkData, MediaMetadata.PICTURE_TYPE_FRONT_COVER);

                      // Update the current media item with artwork
                      MediaItem currentItem = player.getCurrentMediaItem();
                      if (currentItem != null) {
                        MediaItem updatedItem =
                            currentItem
                                .buildUpon()
                                .setMediaMetadata(updatedBuilder.build())
                                .build();
                        // Use replaceMediaItem to avoid disrupting playback
                        player.replaceMediaItem(0, updatedItem);
                        Log.d(TAG, "Artwork loaded and updated");
                      }
                    } catch (Exception e) {
                      Log.e(TAG, "Error updating artwork", e);
                    }
                  });
            }
          });
    }

    // Update the current media item with metadata (without artwork initially)
    MediaItem currentItem = player.getCurrentMediaItem();
    if (currentItem != null) {
      MediaItem updatedItem =
          currentItem.buildUpon().setMediaMetadata(metadataBuilder.build()).build();
      // Use replaceMediaItem to avoid disrupting playback
      player.replaceMediaItem(0, updatedItem);
      Log.d(TAG, "Player metadata updated");
    } else {
      Log.w(TAG, "Player has no current MediaItem to update with metadata");
    }
  }

  /** Callback interface for async artwork loading. */
  private interface ArtworkCallback {
    void onArtworkLoaded(@Nullable Bitmap bitmap);
  }

  /** Asynchronously loads artwork from a URI. */
  private void loadArtworkAsync(@NonNull String artUri, @NonNull ArtworkCallback callback) {
    executorService.execute(
        () -> {
          Bitmap bitmap = null;
          try {
            Uri uri = Uri.parse(artUri);
            String scheme = uri.getScheme();

            if ("http".equals(scheme) || "https".equals(scheme)) {
              bitmap = loadArtworkFromNetwork(artUri);
            } else if ("file".equals(scheme) || "content".equals(scheme)) {
              bitmap = loadArtworkFromContentUri(uri);
            }

            if (bitmap != null) {
              bitmap = scaleBitmap(bitmap, 512); // Max 512x512 for notification
            }
          } catch (Exception e) {
            Log.e(TAG, "Error loading artwork", e);
          }

          final Bitmap finalBitmap = bitmap;
          mainHandler.post(() -> callback.onArtworkLoaded(finalBitmap));
        });
  }

  private Bitmap loadArtworkFromNetwork(String urlString) throws Exception {
    HttpURLConnection connection = null;
    try {
      URL url = new URL(urlString);
      connection = (HttpURLConnection) url.openConnection();
      connection.setDoInput(true);
      connection.setConnectTimeout(5000);
      connection.setReadTimeout(5000);
      connection.connect();

      int responseCode = connection.getResponseCode();
      if (responseCode == HttpURLConnection.HTTP_OK) {
        InputStream input = connection.getInputStream();
        return BitmapFactory.decodeStream(input);
      }
      return null;
    } finally {
      if (connection != null) {
        connection.disconnect();
      }
    }
  }

  private Bitmap loadArtworkFromContentUri(Uri uri) throws Exception {
    InputStream input = getContentResolver().openInputStream(uri);
    if (input != null) {
      try {
        return BitmapFactory.decodeStream(input);
      } finally {
        input.close();
      }
    }
    return null;
  }

  private Bitmap scaleBitmap(Bitmap bitmap, int maxSize) {
    int width = bitmap.getWidth();
    int height = bitmap.getHeight();

    if (width <= maxSize && height <= maxSize) {
      return bitmap;
    }

    float scale = Math.min((float) maxSize / width, (float) maxSize / height);
    int newWidth = Math.round(width * scale);
    int newHeight = Math.round(height * scale);

    Bitmap scaled = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true);
    if (scaled != bitmap) {
      bitmap.recycle();
    }
    return scaled;
  }

  private byte[] bitmapToByteArray(Bitmap bitmap) {
    ByteArrayOutputStream stream = new ByteArrayOutputStream();
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
    return stream.toByteArray();
  }

  /** Removes a media session when player is disposed. */
  public void removeMediaSession(int textureId) {
    try {
      MediaSession session = mediaSessions.remove(textureId);

      if (session != null) {
        Log.d(TAG, "Removing MediaSession for texture: " + textureId);

        if (session == primarySession) {
          primarySession = null;

          // If there are other sessions, promote one to primary
          if (!mediaSessions.isEmpty()) {
            primarySession = mediaSessions.values().iterator().next();
            Log.d(TAG, "Promoted new primary MediaSession");
          }
        }

        // Unregister from Media3 notification system
        try {
          removeSession(session);
        } catch (Exception e) {
          Log.e(TAG, "Error calling removeSession", e);
        }

        // Release the session
        try {
          session.release();
        } catch (Exception e) {
          Log.e(TAG, "Error releasing MediaSession", e);
        }
      } else {
        Log.w(TAG, "No MediaSession found for texture: " + textureId);
      }

      // Stop service if no more sessions
      if (mediaSessions.isEmpty()) {
        Log.d(TAG, "No more sessions, stopping service");
        stopSelf();
      } else {
        Log.d(TAG, "Active sessions remaining: " + mediaSessions.size());
      }

    } catch (Exception e) {
      Log.e(TAG, "Error in removeMediaSession for texture: " + textureId, e);
    }
  }

  /** MediaSession.Callback to handle playback commands and controller connections. */
  private class MediaSessionCallback implements MediaSession.Callback {

    @Override
    public MediaSession.ConnectionResult onConnect(
        @NonNull MediaSession session, @NonNull MediaSession.ControllerInfo controller) {

      Log.d(TAG, "Controller connecting: " + controller.getPackageName());

      // Configure available commands for the controller
      MediaSession.ConnectionResult.AcceptedResultBuilder resultBuilder =
          new MediaSession.ConnectionResult.AcceptedResultBuilder(session);

      // For media notification controller, configure button preferences
      if (session.isMediaNotificationController(controller)) {
        Log.d(TAG, "Configuring media notification controller");

        // Set available player commands
        Player.Commands availableCommands =
            new Player.Commands.Builder()
                .addAll(
                    Player.COMMAND_PLAY_PAUSE,
                    Player.COMMAND_PREPARE,
                    Player.COMMAND_STOP,
                    Player.COMMAND_SEEK_TO_DEFAULT_POSITION,
                    Player.COMMAND_SEEK_IN_CURRENT_MEDIA_ITEM,
                    Player.COMMAND_SEEK_BACK,
                    Player.COMMAND_SEEK_FORWARD,
                    Player.COMMAND_SET_SPEED_AND_PITCH,
                    Player.COMMAND_GET_CURRENT_MEDIA_ITEM,
                    Player.COMMAND_GET_TIMELINE,
                    Player.COMMAND_GET_METADATA)
                .build();

        resultBuilder.setAvailablePlayerCommands(availableCommands);

        // Configure media button layout for notification
        ImmutableList<CommandButton> customLayout =
            ImmutableList.of(
                new CommandButton.Builder()
                    .setPlayerCommand(Player.COMMAND_SEEK_BACK)
                    .setDisplayName("Rewind")
                    .build(),
                new CommandButton.Builder()
                    .setPlayerCommand(Player.COMMAND_PLAY_PAUSE)
                    .setDisplayName("Play/Pause")
                    .build(),
                new CommandButton.Builder()
                    .setPlayerCommand(Player.COMMAND_SEEK_FORWARD)
                    .setDisplayName("Fast Forward")
                    .build());

        resultBuilder.setMediaButtonPreferences(customLayout);
      }

      return resultBuilder.build();
    }

    @Override
    public ListenableFuture<SessionResult> onCustomCommand(
        @NonNull MediaSession session,
        @NonNull MediaSession.ControllerInfo controller,
        @NonNull SessionCommand customCommand,
        @NonNull Bundle args) {

      Log.d(TAG, "Custom command received: " + customCommand.customAction);
      return Futures.immediateFuture(new SessionResult(SessionResult.RESULT_SUCCESS));
    }

    @Override
    public void onDisconnected(
        @NonNull MediaSession session, @NonNull MediaSession.ControllerInfo controller) {
      Log.d(TAG, "Controller disconnected: " + controller.getPackageName());
    }
  }

  @Override
  public void onTaskRemoved(@Nullable Intent rootIntent) {
    Log.d(TAG, "Task removed - app swiped away");

    // Stop all playback when app is removed from recents
    for (MediaSession session : mediaSessions.values()) {
      Player player = session.getPlayer();
      if (player != null && player.isPlaying()) {
        player.pause();
      }
    }

    // Stop the service
    stopSelf();

    super.onTaskRemoved(rootIntent);
  }

  @Override
  public void onDestroy() {
    Log.d(TAG, "VideoMedia3SessionService destroyed");

    try {
      // Release all sessions
      for (MediaSession session : mediaSessions.values()) {
        try {
          session.release();
        } catch (Exception e) {
          Log.e(TAG, "Error releasing session in onDestroy", e);
        }
      }
      mediaSessions.clear();
      primarySession = null;

      executorService.shutdown();
    } catch (Exception e) {
      Log.e(TAG, "Error in onDestroy", e);
    }

    super.onDestroy();
  }
}
