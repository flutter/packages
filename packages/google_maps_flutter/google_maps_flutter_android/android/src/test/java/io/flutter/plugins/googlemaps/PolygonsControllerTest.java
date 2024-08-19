// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import org.junit.Before;
import org.mockito.Mock;

public class PolygonsControllerTest {
  @Mock GoogleMap googleMap;

  private PigeonTestHelper pigeonTestHelper;

  @Before
  public void setup() {
    pigeonTestHelper = new PigeonTestHelper();
  }
}
