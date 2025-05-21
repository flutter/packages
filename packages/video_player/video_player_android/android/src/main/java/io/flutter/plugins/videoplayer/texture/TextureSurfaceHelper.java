// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.texture;

import android.os.Handler;
import android.os.Looper;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.exoplayer.ExoPlayer;

/**
 * Helper class to manage surface texture transitions and avoid flickering during
 * surface changes, scrolling, or system interruptions.
 */
public class TextureSurfaceHelper {
  private final ExoPlayer exoPlayer;
  private final Handler mainHandler;
  
  // Surface management
  private Surface currentSurface;
  private boolean surfaceValid = false;
  
  // Delay before applying surface changes to avoid rapid flickering
  private static final int SURFACE_CHANGE_DELAY_MS = 16;

  public TextureSurfaceHelper(@NonNull ExoPlayer exoPlayer) {
    this.exoPlayer = exoPlayer;
    this.mainHandler = new Handler(Looper.getMainLooper());
  }

  /**
   * Sets the surface with debouncing to prevent flickering.
   * 
   * @param surface The surface to set
   */
  public void setSurface(@Nullable Surface surface) {
    mainHandler.removeCallbacksAndMessages(null); // Clear pending surface operations
    
    if (surface == null) {
      // If surface is null, clear immediately
      exoPlayer.clearVideoSurface();
      surfaceValid = false;
      currentSurface = null;
      return;
    }
    
    // If we're setting a new surface and already have a valid one,
    // apply immediately for critical surfaces without delay
    if (currentSurface != surface) {
      // Store the new surface
      currentSurface = surface;
      
      // For immediate response on initial surface, set directly
      if (!surfaceValid) {
        exoPlayer.setVideoSurface(surface);
        surfaceValid = true;
        return;
      }
      
      // For surface changes, apply after short delay to avoid flicker
      mainHandler.postDelayed(() -> {
        if (currentSurface == surface) {
          exoPlayer.setVideoSurface(surface);
          surfaceValid = true;
        }
      }, SURFACE_CHANGE_DELAY_MS);
    }
  }
  
  /**
   * Safely clears the current surface without releasing the player.
   */
  public void clearSurface() {
    mainHandler.removeCallbacksAndMessages(null);
    
    // Instead of immediately clearing, post with delay to avoid flicker
    mainHandler.postDelayed(() -> {
      exoPlayer.clearVideoSurface();
      surfaceValid = false;
    }, SURFACE_CHANGE_DELAY_MS);
  }
  
  /**
   * Checks if the current surface is valid.
   * 
   * @return true if the surface is valid and active
   */
  public boolean isSurfaceValid() {
    return surfaceValid && currentSurface != null;
  }
  
  /**
   * Releases all resources.
   */
  public void release() {
    mainHandler.removeCallbacksAndMessages(null);
    exoPlayer.clearVideoSurface();
    currentSurface = null;
    surfaceValid = false;
  }
} 