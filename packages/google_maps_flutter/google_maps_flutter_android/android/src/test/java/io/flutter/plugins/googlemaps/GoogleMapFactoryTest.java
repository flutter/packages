// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugin.common.BinaryMessenger;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedConstruction;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class GoogleMapFactoryTest {

  @Test
  public void createDoesNotSetBackgroundColorWhenNull() {
    final Context context = ApplicationProvider.getApplicationContext();
    final BinaryMessenger binaryMessenger = mock(BinaryMessenger.class);
    final LifecycleProvider lifecycleProvider = mock(LifecycleProvider.class);
    final PlatformMapConfiguration mapConfiguration = mock(PlatformMapConfiguration.class);
    final PlatformMapViewCreationParams creationParams = mock(PlatformMapViewCreationParams.class);
    when(mapConfiguration.getBackgroundColor()).thenReturn(null);
    when(creationParams.getMapConfiguration()).thenReturn(mapConfiguration);
    when(creationParams.getInitialCameraPosition())
        .thenReturn(new PlatformCameraPosition(0.0, new PlatformLatLng(0.0, 0.0), 0.0, 0.0));

    try (MockedConstruction<GoogleMapBuilder> builders = mockConstruction(GoogleMapBuilder.class)) {
      final GoogleMapFactory factory =
          new GoogleMapFactory(binaryMessenger, context, lifecycleProvider);

      factory.create(context, 0, creationParams);

      verify(builders.constructed().get(0), never()).setBackgroundColor(anyInt());
    }
  }
}
