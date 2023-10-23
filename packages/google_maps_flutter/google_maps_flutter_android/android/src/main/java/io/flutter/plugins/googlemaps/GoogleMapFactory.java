// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.model.CameraPosition;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.List;
import java.util.Map;

public class GoogleMapFactory extends PlatformViewFactory {

  private final BinaryMessenger binaryMessenger;
  private final LifecycleProvider lifecycleProvider;
  private final GoogleMapInitializer googleMapInitializer;

  GoogleMapFactory(
      BinaryMessenger binaryMessenger, Context context, LifecycleProvider lifecycleProvider) {
    super(StandardMessageCodec.INSTANCE);

    this.binaryMessenger = binaryMessenger;
    this.lifecycleProvider = lifecycleProvider;
    this.googleMapInitializer = new GoogleMapInitializer(context, binaryMessenger);
  }

  @SuppressWarnings("unchecked")
  @Override
  @NonNull
  public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
    Map<String, Object> params = (Map<String, Object>) args;
    final GoogleMapBuilder builder = new GoogleMapBuilder();

    final Object options = params.get("options");
    Convert.interpretGoogleMapOptions(options, builder);
    if (params.containsKey("initialCameraPosition")) {
      CameraPosition position = Convert.toCameraPosition(params.get("initialCameraPosition"));
      builder.setInitialCameraPosition(position);
    }
    if (params.containsKey("markersToAdd")) {
      builder.setInitialMarkers(params.get("markersToAdd"));
    }
    if (params.containsKey("polygonsToAdd")) {
      builder.setInitialPolygons(params.get("polygonsToAdd"));
    }
    if (params.containsKey("polylinesToAdd")) {
      builder.setInitialPolylines(params.get("polylinesToAdd"));
    }
    if (params.containsKey("circlesToAdd")) {
      builder.setInitialCircles(params.get("circlesToAdd"));
    }
    if (params.containsKey("tileOverlaysToAdd")) {
      builder.setInitialTileOverlays((List<Map<String, ?>>) params.get("tileOverlaysToAdd"));
    }
    final Object cloudMapId = ((Map<?, ?>) options).get("cloudMapId");
    if (cloudMapId != null) {
      builder.setMapId((String) cloudMapId);
    }

    return builder.build(id, context, binaryMessenger, lifecycleProvider);
  }
}
