// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import com.google.android.gms.maps.GoogleMapOptions;
import org.junit.Test;

public class GoogleMapBuilderTest {

  @Test
  public void setBackgroundColorConfiguresMapCreationOptions() {
    final GoogleMapOptions options = mock(GoogleMapOptions.class);
    final GoogleMapBuilder builder = new GoogleMapBuilder(options);
    final int backgroundColor = 0xFF123456;

    builder.setBackgroundColor(backgroundColor);

    verify(options).backgroundColor(backgroundColor);
  }
}
