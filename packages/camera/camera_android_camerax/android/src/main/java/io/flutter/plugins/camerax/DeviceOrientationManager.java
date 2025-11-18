// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.util.Log;
import android.view.Display;
import android.view.OrientationEventListener;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;
import java.util.Objects;

/**
 * Support class to help to determine the media orientation based on the orientation of the device.
 */
public class DeviceOrientationManager {
  private static final IntentFilter orientationIntentFilter =
      new IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED);

  private final DeviceOrientationManagerProxyApi api;
  private PlatformChannel.DeviceOrientation lastOrientation;
  private BroadcastReceiver broadcastReceiver;

  @VisibleForTesting @Nullable protected OrientationEventListener orientationEventListener;

  DeviceOrientationManager(DeviceOrientationManagerProxyApi api) {
    this.api = api;
  }

  @NonNull
  Context getContext() {
    return api.getPigeonRegistrar().getContext();
  }

  /**
   * Starts listening to the device's sensors for device orientation updates.
   *
   * <p>When orientation information is updated, the callback method of the {@link
   * DeviceOrientationManagerProxyApi} is called with the new orientation.
   */
  @SuppressLint("UnprotectedReceiver")
  // orientationIntentFilter only listens to protected broadcast
  public void start() {
    stop();

    // Listen for changes in device orientation at the default rate that is suitable for monitoring
    // typical screen orientation changes.
    orientationEventListener = createOrientationEventListener();
    orientationEventListener.enable();
  }

  @VisibleForTesting
  @NonNull
  /**
   * Creates an {@link OrientationEventListener} that will call the callback method of the {@link
   * DeviceOrientationManagerProxyApi} whenever it is notified of a new device orientation and this
   * {@code DeviceOrientationManager} instance determines that the orientation of the device {@link
   * Configuration} has changed.
   */
  protected OrientationEventListener createOrientationEventListener() {
    return new OrientationEventListener(getContext()) {
      @Override
      public void onOrientationChanged(int orientation) {
        handleUiOrientationChange();
      }
    };
  }

  /** Stops listening for orientation updates. */
  public void stop() {
    if (orientationEventListener == null) {
      return;
    }
    lastOrientation = null;

    orientationEventListener.disable();
    orientationEventListener = null;
  }

  /**
   * Handles orientation changes based on change events triggered by the OrientationIntentFilter.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   */
  @VisibleForTesting
  void handleUiOrientationChange() {
    PlatformChannel.DeviceOrientation orientation = getUiOrientation();
    handleOrientationChange(this, orientation, lastOrientation, api);
    lastOrientation = orientation;
  }

  /**
   * Handles orientation changes coming from the device's sensors.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   */
  @VisibleForTesting
  static void handleOrientationChange(
      DeviceOrientationManager manager,
      DeviceOrientation newOrientation,
      DeviceOrientation previousOrientation,
      DeviceOrientationManagerProxyApi api) {
    if (!newOrientation.equals(previousOrientation)) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              new ProxyApiRegistrar.FlutterMethodRunnable() {
                @Override
                public void run() {
                  api.onDeviceOrientationChanged(
                      manager,
                      newOrientation.toString(),
                      ResultCompat.asCompatCallback(
                          result -> {
                            if (result.isFailure()) {
                              onFailure(
                                  "DeviceOrientationManager.onDeviceOrientationChanged",
                                  Objects.requireNonNull(result.exceptionOrNull()));
                            }
                            return null;
                          }));
                }
              });
    }
  }

  /**
   * Gets the current user interface orientation.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @return The current user interface orientation.
   */
  // Configuration.ORIENTATION_SQUARE is deprecated.
  @SuppressWarnings("deprecation")
  @NonNull
  PlatformChannel.DeviceOrientation getUiOrientation() {
    final int rotation = getDefaultRotation();
    final int orientation = getContext().getResources().getConfiguration().orientation;

    switch (orientation) {
      case Configuration.ORIENTATION_PORTRAIT:
        if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
          return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
        } else {
          return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
        }
      case Configuration.ORIENTATION_LANDSCAPE:
        if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
          return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
        } else {
          return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
        }
      case Configuration.ORIENTATION_SQUARE:
      case Configuration.ORIENTATION_UNDEFINED:
      default:
        return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
    }
  }

  /**
   * Gets default capture rotation for CameraX {@code UseCase}s.
   *
   * <p>See
   * https://developer.android.com/reference/androidx/camera/core/ImageCapture#setTargetRotation(int),
   * for instance.
   *
   * @return The rotation of the screen from its "natural" orientation; one of {@code
   *     Surface.ROTATION_0}, {@code Surface.ROTATION_90}, {@code Surface.ROTATION_180}, {@code
   *     Surface.ROTATION_270}
   */
  int getDefaultRotation() {
    Display display = getDisplay();

    if (display == null) {
      // The Activity is not available (null or destroyed), which can happen briefly
      // during configuration changes or due to race conditions. Returning ROTATION_0 ensures safe
      // fallback and prevents crashes until a valid Activity is attached again.
      Log.w(
          "DeviceOrientationManager",
          "Cannot get display: Activity may be null (destroyed or not yet attached) due to a race condition.");
      return Surface.ROTATION_0;
    }

    return display.getRotation();
  }

  /**
   * Gets an instance of the Android {@link android.view.Display}.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @return An instance of the Android {@link android.view.Display}.
   */
  @VisibleForTesting
  @Nullable
  Display getDisplay() {
    return api.getPigeonRegistrar().getDisplay();
  }
}
