// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.Context;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapsSdkInitializedCallback;
import io.flutter.plugin.common.BinaryMessenger;

/** GoogleMaps initializer used to initialize the Google Maps SDK with preferred settings. */
final class GoogleMapInitializer implements OnMapsSdkInitializedCallback, MapsInitializerApi {
  private static final String TAG = "GoogleMapInitializer";
  private final Context context;
  private static Result<PlatformRendererType> initializationResult;
  private boolean rendererInitialized = false;

  GoogleMapInitializer(Context context, BinaryMessenger binaryMessenger) {
    this.context = context;

    MapsInitializerApi.setUp(binaryMessenger, this);
  }

  @Override
  public void initializeWithPreferredRenderer(
      @Nullable PlatformRendererType type, @NonNull Result<PlatformRendererType> result) {
    if (rendererInitialized || initializationResult != null) {
      result.error(
          new FlutterError(
              "Renderer already initialized",
              "Renderer initialization called multiple times",
              null));
    } else {
      initializationResult = result;
      initializeWithRendererRequest(Convert.toMapRendererType(type));
    }
  }

  @Override
  public void warmup() {
    Log.i(TAG, "Google Maps warmup started.");
    try {
      // This creates a fake map view in order to trigger the SDK's
      // initialization. For context, see
      // https://github.com/flutter/flutter/issues/28493#issuecomment-2919150669.
      MapView mv = new MapView(context);
      mv.onCreate(null);
      mv.onResume();
      mv.onPause();
      mv.onDestroy();
      Log.i(TAG, "Maps warmup complete.");
    } catch (Exception e) {
      throw new FlutterError("Could not warm up", e.toString(), null);
    }
  }

  /**
   * Initializes map renderer to with preferred renderer type.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   */
  @VisibleForTesting
  public void initializeWithRendererRequest(@Nullable MapsInitializer.Renderer renderer) {
    MapsInitializer.initialize(context, renderer, this);
  }

  /** Is called by Google Maps SDK to determine which version of the renderer was initialized. */
  @Override
  public void onMapsSdkInitialized(@NonNull MapsInitializer.Renderer renderer) {
    rendererInitialized = true;
    if (initializationResult != null) {
      switch (renderer) {
        case LATEST:
          initializationResult.success(PlatformRendererType.LATEST);
          break;
        case LEGACY:
          initializationResult.success(PlatformRendererType.LEGACY);
          break;
        default:
          initializationResult.error(
              new FlutterError(
                  "Unknown renderer type",
                  "Initialized with unknown renderer type",
                  renderer.name()));
      }
      initializationResult = null;
    }
  }
}
