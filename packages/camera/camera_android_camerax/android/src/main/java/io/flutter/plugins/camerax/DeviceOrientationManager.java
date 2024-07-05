// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.view.Display;
import android.view.Surface;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;

/**
 * Support class to help to determine the media orientation based on the orientation of the device.
 */
public class DeviceOrientationManager {

  interface DeviceOrientationChangeCallback {
    void onChange(DeviceOrientation newOrientation);
  }

  private static final IntentFilter orientationIntentFilter =
      new IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED);

  private final Activity activity;
  private final boolean isFrontFacing;
  private final int sensorOrientation;
  private final DeviceOrientationChangeCallback deviceOrientationChangeCallback;
  private PlatformChannel.DeviceOrientation lastOrientation;
  private BroadcastReceiver broadcastReceiver;

  DeviceOrientationManager(
      @NonNull Activity activity,
      boolean isFrontFacing,
      int sensorOrientation,
      DeviceOrientationChangeCallback callback) {
    this.activity = activity;
    this.isFrontFacing = isFrontFacing;
    this.sensorOrientation = sensorOrientation;
    this.deviceOrientationChangeCallback = callback;
  }

  /**
   * Starts listening to the device's sensors or UI for orientation updates.
   *
   * <p>When orientation information is updated, the callback method of the {@link
   * DeviceOrientationChangeCallback} is called with the new orientation.
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
    activity.registerReceiver(broadcastReceiver, orientationIntentFilter);
    broadcastReceiver.onReceive(activity, null);
  }

  /** Stops listening for orientation updates. */
  public void stop() {
    if (broadcastReceiver == null) {
      return;
    }
    activity.unregisterReceiver(broadcastReceiver);
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
    handleOrientationChange(orientation, lastOrientation, deviceOrientationChangeCallback);
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
      DeviceOrientation newOrientation,
      DeviceOrientation previousOrientation,
      DeviceOrientationChangeCallback callback) {
    if (!newOrientation.equals(previousOrientation)) {
      callback.onChange(newOrientation);
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
    final int orientation = activity.getResources().getConfiguration().orientation;

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
  @SuppressWarnings("deprecation")
  @VisibleForTesting
  Display getDisplay() {
    return ((WindowManager) activity.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
  }
}
