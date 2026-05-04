// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.model.Tile;
import com.google.android.gms.maps.model.TileProvider;
import java.util.concurrent.CountDownLatch;
import kotlin.Unit;

class TileProviderController implements TileProvider {

  private static final String TAG = "TileProviderController";

  protected final String tileOverlayId;
  protected final @NonNull MapsCallbackApi flutterApi;
  protected final Handler handler = new Handler(Looper.getMainLooper());

  TileProviderController(@NonNull MapsCallbackApi flutterApi, String tileOverlayId) {
    this.tileOverlayId = tileOverlayId;
    this.flutterApi = flutterApi;
  }

  @Override
  public Tile getTile(final int x, final int y, final int zoom) {
    Worker worker = new Worker(x, y, zoom);
    return worker.getTile();
  }

  private final class Worker {

    private final CountDownLatch countDownLatch = new CountDownLatch(1);
    private final int x;
    private final int y;
    private final int zoom;
    private @Nullable PlatformTile tile;

    Worker(int x, int y, int zoom) {
      this.x = x;
      this.y = y;
      this.zoom = zoom;
    }

    @NonNull
    Tile getTile() {
      final PlatformPoint location = new PlatformPoint(x, y);
      handler.post(
          () ->
              flutterApi.getTileOverlayTile(
                  tileOverlayId,
                  location,
                  zoom,
                  ResultCompat.asCompatCallback(
                      result -> {
                        tile = result.getOrNull();
                        if (tile == null) {
                          final Throwable error = result.exceptionOrNull();
                          if (error instanceof FlutterError flutterError) {
                            Log.e(
                                TAG,
                                "Can't get tile: errorCode = "
                                    + flutterError.getCode()
                                    + ", errorMessage = "
                                    + flutterError.getMessage()
                                    + ", date = "
                                    + flutterError.getDetails());
                          } else {
                            Log.e(TAG, "Can't get tile: " + error);
                          }
                        }
                        countDownLatch.countDown();
                        return Unit.INSTANCE;
                      })));
      try {
        // `flutterApi.getTileOverlayTile` is async, so use a `countDownLatch` to make it
        // synchronized.
        countDownLatch.await();
      } catch (InterruptedException e) {
        Log.e(
            TAG,
            String.format("countDownLatch: can't get tile: x = %d, y= %d, zoom = %d", x, y, zoom),
            e);
        return TileProvider.NO_TILE;
      }
      try {
        if (tile == null) {
          Log.e(
              TAG,
              String.format(
                  "Did not receive tile data for tile: x = %d, y= %d, zoom = %d", x, y, zoom));
          return TileProvider.NO_TILE;
        }
        return Convert.tileFromPigeon(tile);
      } catch (Exception e) {
        Log.e(TAG, "Can't parse tile data", e);
        return TileProvider.NO_TILE;
      }
    }
  }
}
