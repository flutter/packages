// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.view.Display;
import android.view.Surface;
import androidx.annotation.NonNull;
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

  DeviceOrientationManager(DeviceOrientationManagerProxyApi api) {
    this.api = api;
  }

  @NonNull
  Context getContext() {
    return api.getPigeonRegistrar().getContext();
  }

  /**
   * Starts listening to the device's sensors or UI for orientation updates.
   *
   * <p>When orientation information is updated, the callback method of the {@link
   * DeviceOrientationManagerProxyApi} is called with the new orientation.
   *
   * <p>If the device's ACCELEROMETER_ROTATION setting is enabled the {@link
   * DeviceOrientationManager} will report orientation updates based on the sensor information. If
   * the ACCELEROMETER_ROTATION is disabled the {@link DeviceOrientationManager} will fallback to
   * the deliver orientation updates based on the UI orientation.
   */
  public void start() {
    if (broadcastReceiver != null) {
      return;
    }
    broadcastReceiver =
        new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
            handleUIOrientationChange();
          }
        };
    getContext().registerReceiver(broadcastReceiver, orientationIntentFilter);
    broadcastReceiver.onReceive(getContext(), null);
  }

  /** Stops listening for orientation updates. */
  public void stop() {
    if (broadcastReceiver == null) {
      return;
    }
    getContext().unregisterReceiver(broadcastReceiver);
    broadcastReceiver = null;
  }

  /**
   * Handles orientation changes based on change events triggered by the OrientationIntentFilter.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   */
  @VisibleForTesting
  void handleUIOrientationChange() {
    PlatformChannel.DeviceOrientation orientation = getUIOrientation();
    handleOrientationChange(this, orientation, lastOrientation, api);
    lastOrientation = orientation;
  }

  /**
   * Handles orientation changes coming from either the device's sensors or the
   * OrientationIntentFilter.
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
  PlatformChannel.DeviceOrientation getUIOrientation() {
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
    return getDisplay().getRotation();
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
  Display getDisplay() {
    return api.getPigeonRegistrar().getDisplay();
  }
}
