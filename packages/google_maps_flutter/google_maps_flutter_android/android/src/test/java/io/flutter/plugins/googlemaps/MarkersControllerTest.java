// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.AdvancedMarkerOptions;
import com.google.android.gms.maps.model.AdvancedMarkerOptions.CollisionBehavior;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugin.common.BinaryMessenger;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class MarkersControllerTest {
  private Context context;
  private MapsCallbackApi flutterApi;
  private ClusterManagersController clusterManagersController;
  private MarkersController controller;
  private GoogleMap googleMap;
  private MarkerManager markerManager;
  private MarkerManager.Collection markerCollection;
  private AssetManager assetManager;
  private final float density = 1;
  private AutoCloseable mocksClosable;

  @Mock private Convert.BitmapDescriptorFactoryWrapper bitmapDescriptorFactoryWrapper;

  private static PlatformMarkerBuilder defaultMarkerBuilder() {
    Bitmap fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    byte[] byteArray = byteArrayOutputStream.toByteArray();
    PlatformBitmap icon =
        new PlatformBitmap(
            new PlatformBitmapBytesMap(
                byteArray, PlatformMapBitmapScaling.NONE, /* imagePixelRatio */ 1.0, null, null));
    PlatformDoublePair anchor = new PlatformDoublePair(0.5, 0.0);
    PlatformInfoWindow infoWindow = new PlatformInfoWindow(null, null, anchor);
    return new PlatformMarkerBuilder()
        .setPosition(new PlatformLatLng(0.0, 0.0))
        .setAnchor(new PlatformDoublePair(0.0, 0.0))
        .setFlat(false)
        .setDraggable(false)
        .setVisible(true)
        .setAlpha(1.0)
        .setRotation(0.0)
        .setZIndex(0.0)
        .setConsumeTapEvents(false)
        .setIcon(icon)
        .setInfoWindow(infoWindow)
        .setCollisionBehavior(PlatformMarkerCollisionBehavior.REQUIRED_DISPLAY);
  }

  @Before
  public void setUp() {
    mocksClosable = MockitoAnnotations.openMocks(this);
    assetManager = ApplicationProvider.getApplicationContext().getAssets();
    context = ApplicationProvider.getApplicationContext();
    flutterApi = spy(new MapsCallbackApi(mock(BinaryMessenger.class), ""));
    clusterManagersController =
        spy(new ClusterManagersController(flutterApi, context, PlatformMarkerType.MARKER));
    controller =
        new MarkersController(
            flutterApi,
            clusterManagersController,
            assetManager,
            density,
            bitmapDescriptorFactoryWrapper,
            PlatformMarkerType.MARKER);
    googleMap = mock(GoogleMap.class);
    markerManager = new MarkerManager(googleMap);
    markerCollection = markerManager.newCollection();
    controller.setCollection(markerCollection);
    clusterManagersController.init(googleMap, markerManager);
  }

  @After
  public void close() throws Exception {
    mocksClosable.close();
  }

  @Test
  public void controller_OnMarkerDragStart() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);

    final List<PlatformMarker> markers =
        Collections.singletonList(defaultMarkerBuilder().setMarkerId(googleMarkerId).build());
    controller.addMarkers(markers);
    controller.onMarkerDragStart(googleMarkerId, latLng);

    Mockito.verify(flutterApi)
        .onMarkerDragStart(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)), any());
  }

  @Test
  public void controller_OnMarkerDragEnd() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);

    final List<PlatformMarker> markers =
        Collections.singletonList(defaultMarkerBuilder().setMarkerId(googleMarkerId).build());
    controller.addMarkers(markers);
    controller.onMarkerDragEnd(googleMarkerId, latLng);

    Mockito.verify(flutterApi)
        .onMarkerDragEnd(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)), any());
  }

  @Test
  public void controller_OnMarkerDrag() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);

    final List<PlatformMarker> markers =
        Collections.singletonList(defaultMarkerBuilder().setMarkerId(googleMarkerId).build());

    controller.addMarkers(markers);
    controller.onMarkerDrag(googleMarkerId, latLng);

    Mockito.verify(flutterApi)
        .onMarkerDrag(eq(googleMarkerId), eq(Convert.latLngToPigeon(latLng)), any());
  }

  @Test(expected = NullPointerException.class)
  public void controller_AddMarkerThrowsErrorIfMarkerIdIsNull() {
    final List<PlatformMarker> markers = Collections.singletonList(defaultMarkerBuilder().build());
    try {
      controller.addMarkers(markers);
    } catch (NullPointerException e) {
      assertEquals("markerId was null", e.getMessage());
      throw e;
    }
  }

  @Test
  public void controller_AddChangeAndRemoveMarkerWithClusterManagerId() {
    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";
    final String clusterManagerId = "cm123";

    final PlatformMarkerBuilder builder = defaultMarkerBuilder();
    builder
        .setMarkerId(googleMarkerId)
        .setClusterManagerId(clusterManagerId)
        .setPosition(new PlatformLatLng(1.1, 2.2));

    when(marker.getId()).thenReturn(googleMarkerId);

    // Store reference to verify later, since markerIdToMarkerBuilder is private
    final MarkerBuilder[] addedMarkerBuilder = new MarkerBuilder[1];

    // Add marker and verify addItems is called with correct parameters
    controller.addMarkers(Collections.singletonList(builder.build()));
    Mockito.verify(clusterManagersController, times(1))
        .addItems(
            eq(clusterManagerId),
            Mockito.argThat(
                markerBuilders -> {
                  if (markerBuilders.size() == 1
                      && markerBuilders.get(0).clusterManagerId().equals(clusterManagerId)) {
                    // Store reference for later use in onClusterItemRendered
                    addedMarkerBuilder[0] = markerBuilders.get(0);
                    return true;
                  }
                  return false;
                }));

    // clusterManagersController calls onClusterItemRendered with created marker.
    controller.onClusterItemRendered(addedMarkerBuilder[0], marker);

    // Change marker to test that markerController is created and the marker can be
    // updated
    final LatLng latLng2 = new LatLng(3.3, 4.4);

    builder.setPosition(new PlatformLatLng(latLng2.latitude, latLng2.longitude));
    final List<PlatformMarker> updatedMarkers = Collections.singletonList(builder.build());

    controller.changeMarkers(updatedMarkers);
    Mockito.verify(marker, times(1)).setPosition(latLng2);

    // Remove marker
    controller.removeMarkers(Collections.singletonList(googleMarkerId));

    Mockito.verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId),
            Mockito.argThat(
                PlatformMarkerBuilders ->
                    PlatformMarkerBuilders.size() == 1
                        && PlatformMarkerBuilders.get(0)
                            .clusterManagerId()
                            .equals(clusterManagerId)));
  }

  @Test
  public void controller_AddChangeAndRemoveMarkerWithoutClusterManagerId() {
    MarkerManager.Collection spyMarkerCollection = spy(markerCollection);
    controller.setCollection(spyMarkerCollection);

    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final PlatformMarkerBuilder builder = defaultMarkerBuilder();
    builder.setMarkerId(googleMarkerId);
    controller.addMarkers(Collections.singletonList(builder.build()));

    // clusterManagersController should not be called when adding the marker
    Mockito.verify(clusterManagersController, times(0)).addItem(any());

    Mockito.verify(spyMarkerCollection, times(1)).addMarker(any(MarkerOptions.class));

    final float alpha = 0.1f;

    final List<PlatformMarker> markerUpdates =
        Collections.singletonList(builder.setAlpha((double) alpha).build());
    controller.changeMarkers(markerUpdates);
    Mockito.verify(marker, times(1)).setAlpha(alpha);

    controller.removeMarkers(Collections.singletonList(googleMarkerId));

    // clusterManagersController should not be called when removing the marker
    Mockito.verify(clusterManagersController, times(0)).removeItem(any());

    Mockito.verify(spyMarkerCollection, times(1)).remove(marker);
  }

  @Test
  public void PlatformMarkerBuilder_setCollisionBehavior() {
    PlatformMarker platformMarker = defaultMarkerBuilder().setMarkerId("1").build();
    MarkerBuilder markerBuilder = new MarkerBuilder("m_1", "1", PlatformMarkerType.ADVANCED_MARKER);

    // Default collision behavior of an AdvancedMarker
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1, bitmapDescriptorFactoryWrapper);
    MarkerOptions markerOptions = markerBuilder.build();
    Assert.assertEquals(AdvancedMarkerOptions.class, markerOptions.getClass());
    Assert.assertEquals(
        CollisionBehavior.REQUIRED, ((AdvancedMarkerOptions) markerOptions).getCollisionBehavior());

    // Customized collision behavior of an AdvancedMarker
    platformMarker =
        defaultMarkerBuilder()
            .setMarkerId("1")
            .setCollisionBehavior(PlatformMarkerCollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY)
            .build();
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1, bitmapDescriptorFactoryWrapper);
    markerOptions = markerBuilder.build();
    Assert.assertEquals(AdvancedMarkerOptions.class, markerOptions.getClass());
    Assert.assertEquals(
        CollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY,
        ((AdvancedMarkerOptions) markerOptions).getCollisionBehavior());

    // Legacy markers don't have collision behavior in the marker options
    platformMarker = defaultMarkerBuilder().setMarkerId("1").build();
    markerBuilder = new MarkerBuilder("m_1", "1", PlatformMarkerType.MARKER);
    Convert.interpretMarkerOptions(
        platformMarker, markerBuilder, assetManager, 1, bitmapDescriptorFactoryWrapper);
    markerOptions = markerBuilder.build();
    Assert.assertEquals(MarkerOptions.class, markerOptions.getClass());
  }

  @Test
  public void controller_BatchAddMultipleMarkersWithClusterManagerId() {
    final String clusterManagerId = "cm123";

    // Create multiple markers with the same cluster manager
    final List<PlatformMarker> markers = new ArrayList<>();
    for (int i = 0; i < 5; i++) {
      final PlatformMarkerBuilder builder = defaultMarkerBuilder();
      builder
          .setMarkerId("marker" + i)
          .setClusterManagerId(clusterManagerId)
          .setPosition(new PlatformLatLng(1.0 + i, 2.0 + i));
      markers.add(builder.build());
    }

    // Add all markers in one batch
    controller.addMarkers(markers);

    // Verify addItems is called exactly once with all 5 markers
    Mockito.verify(clusterManagersController, times(1))
        .addItems(
            eq(clusterManagerId),
            Mockito.argThat(
                PlatformMarkerBuilders ->
                    PlatformMarkerBuilders.size() == 5
                        && PlatformMarkerBuilders.stream()
                            .allMatch(mb -> mb.clusterManagerId().equals(clusterManagerId))));

    // Verify addItem is never called (we're using batch operation)
    Mockito.verify(clusterManagersController, times(0)).addItem(any());
  }

  @Test
  public void controller_BatchRemoveMultipleMarkersWithClusterManagerId() {
    final String clusterManagerId = "cm123";

    // First add markers
    final List<PlatformMarker> markers = new ArrayList<>();
    final List<String> markerIds = new ArrayList<>();
    for (int i = 0; i < 5; i++) {
      String markerId = "marker" + i;
      markerIds.add(markerId);
      final PlatformMarkerBuilder builder = defaultMarkerBuilder();
      builder
          .setMarkerId(markerId)
          .setClusterManagerId(clusterManagerId)
          .setPosition(new PlatformLatLng(1.0 + i, 2.0 + i));
      markers.add(builder.build());
    }

    controller.addMarkers(markers);

    // Remove all markers in one batch
    controller.removeMarkers(markerIds);

    // Verify removeItems is called exactly once with all 5 markers
    Mockito.verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId),
            Mockito.argThat(
                PlatformMarkerBuilders ->
                    PlatformMarkerBuilders.size() == 5
                        && PlatformMarkerBuilders.stream()
                            .allMatch(mb -> mb.clusterManagerId().equals(clusterManagerId))));

    // Verify removeItem is never called (we're using batch operation)
    Mockito.verify(clusterManagersController, times(0)).removeItem(any());
  }

  @Test
  public void controller_BatchChangeMarkersWithClusterManagerChange() {
    final String clusterManagerId1 = "cm123";
    final String clusterManagerId2 = "cm456";

    // First add markers to cluster manager 1
    final List<PlatformMarker> initialMarkers = new ArrayList<>();
    for (int i = 0; i < 5; i++) {
      final PlatformMarkerBuilder builder = defaultMarkerBuilder();
      builder
          .setMarkerId("marker" + i)
          .setClusterManagerId(clusterManagerId1)
          .setPosition(new PlatformLatLng(1.0 + i, 2.0 + i));
      initialMarkers.add(builder.build());
    }
    controller.addMarkers(initialMarkers);

    // Reset mock to clear invocation counts
    Mockito.reset(clusterManagersController);

    // Now change all markers to cluster manager 2
    final List<PlatformMarker> changedMarkers = new ArrayList<>();
    for (int i = 0; i < 5; i++) {
      final PlatformMarkerBuilder builder = defaultMarkerBuilder();
      builder
          .setMarkerId("marker" + i)
          .setClusterManagerId(clusterManagerId2) // Different cluster manager
          .setPosition(new PlatformLatLng(3.0 + i, 4.0 + i));
      changedMarkers.add(builder.build());
    }
    controller.changeMarkers(changedMarkers);

    // Verify removeItems is called exactly once for cluster manager 1 with all 5
    // markers
    Mockito.verify(clusterManagersController, times(1))
        .removeItems(
            eq(clusterManagerId1),
            Mockito.argThat(
                PlatformMarkerBuilders ->
                    PlatformMarkerBuilders.size() == 5
                        && PlatformMarkerBuilders.stream()
                            .allMatch(mb -> mb.clusterManagerId().equals(clusterManagerId1))));

    // Verify addItems is called exactly once for cluster manager 2 with all 5
    // markers
    Mockito.verify(clusterManagersController, times(1))
        .addItems(
            eq(clusterManagerId2),
            Mockito.argThat(
                PlatformMarkerBuilders ->
                    PlatformMarkerBuilders.size() == 5
                        && PlatformMarkerBuilders.stream()
                            .allMatch(mb -> mb.clusterManagerId().equals(clusterManagerId2))));

    // Verify individual operations are never called (we're using batch operations)
    Mockito.verify(clusterManagersController, times(0)).addItem(any());
    Mockito.verify(clusterManagersController, times(0)).removeItem(any());
  }

  @Test
  public void controller_ChangeMarkerInPlace() {
    final Marker marker = mock(Marker.class);
    final String markerId = "marker1";
    final String clusterManagerId = "cm123";

    when(marker.getId()).thenReturn(markerId);

    // Add a clustered marker
    final PlatformMarkerBuilder builder = defaultMarkerBuilder();
    builder
        .setMarkerId(markerId)
        .setClusterManagerId(clusterManagerId)
        .setPosition(new PlatformLatLng(1.0, 2.0));
    controller.addMarkers(Collections.singletonList(builder.build()));

    // Capture the PlatformMarkerBuilder passed to addItems
    @SuppressWarnings("unchecked")
    ArgumentCaptor<List<MarkerBuilder>> captor = ArgumentCaptor.forClass(List.class);
    Mockito.verify(clusterManagersController).addItems(eq(clusterManagerId), captor.capture());
    MarkerBuilder capturedMarkerBuilder = captor.getValue().get(0);

    // Simulate cluster render so markerController exists
    controller.onClusterItemRendered(capturedMarkerBuilder, marker);

    // Reset to clear invocation counts
    Mockito.reset(clusterManagersController);

    // Change marker in place (same clusterManagerId)
    final LatLng newLatLng = new LatLng(3.0, 4.0);
    builder.setPosition(new PlatformLatLng(newLatLng.latitude, newLatLng.longitude));
    controller.changeMarkers(Collections.singletonList(builder.build()));

    // In-place update: marker position is updated directly
    Mockito.verify(marker, times(1)).setPosition(newLatLng);
    // No re-clustering needed
    Mockito.verify(clusterManagersController, times(0)).addItems(any(), any());
    Mockito.verify(clusterManagersController, times(0)).removeItems(any(), any());
  }

  // Remove this if builders are added to the Kotlin generator; see discussion in
  // https://github.com/flutter/flutter/issues/158287
  private static final class PlatformMarkerBuilder {
    private @Nullable Double alpha;
    private @Nullable PlatformDoublePair anchor;
    private @Nullable Boolean consumeTapEvents;
    private @Nullable Boolean draggable;
    private @Nullable Boolean flat;
    private @Nullable PlatformBitmap icon;
    private @Nullable PlatformInfoWindow infoWindow;
    private @Nullable PlatformLatLng position;
    private @Nullable Double rotation;
    private @Nullable Boolean visible;
    private @Nullable Double zIndex;
    private @Nullable String markerId;
    private @Nullable String clusterManagerId;
    private @Nullable PlatformMarkerCollisionBehavior collisionBehavior;

    public @NonNull PlatformMarkerBuilder setAlpha(@NonNull Double setterArg) {
      this.alpha = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setAnchor(@NonNull PlatformDoublePair setterArg) {
      this.anchor = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setConsumeTapEvents(@NonNull Boolean setterArg) {
      this.consumeTapEvents = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setDraggable(@NonNull Boolean setterArg) {
      this.draggable = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setFlat(@NonNull Boolean setterArg) {
      this.flat = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setIcon(@NonNull PlatformBitmap setterArg) {
      this.icon = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setInfoWindow(@NonNull PlatformInfoWindow setterArg) {
      this.infoWindow = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setPosition(@NonNull PlatformLatLng setterArg) {
      this.position = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setRotation(@NonNull Double setterArg) {
      this.rotation = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setVisible(@NonNull Boolean setterArg) {
      this.visible = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setZIndex(@NonNull Double setterArg) {
      this.zIndex = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setMarkerId(@NonNull String setterArg) {
      this.markerId = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setClusterManagerId(@Nullable String setterArg) {
      this.clusterManagerId = setterArg;
      return this;
    }

    public @NonNull PlatformMarkerBuilder setCollisionBehavior(
        @NonNull PlatformMarkerCollisionBehavior setterArg) {
      this.collisionBehavior = setterArg;
      return this;
    }

    public @NonNull PlatformMarker build() {
      return new PlatformMarker(
          Objects.requireNonNull(alpha),
          Objects.requireNonNull(anchor),
          Objects.requireNonNull(consumeTapEvents),
          Objects.requireNonNull(draggable),
          Objects.requireNonNull(flat),
          Objects.requireNonNull(icon),
          Objects.requireNonNull(infoWindow),
          Objects.requireNonNull(position),
          Objects.requireNonNull(rotation),
          Objects.requireNonNull(visible),
          Objects.requireNonNull(zIndex),
          Objects.requireNonNull(markerId),
          clusterManagerId,
          Objects.requireNonNull(collisionBehavior));
    }
  }
}
