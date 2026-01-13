// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class CameraPermissionsErrorTest {
  @Test
  public void errorCode_returnsValueOfErrorCodeFromInstance() {
    final PigeonApiCameraPermissionsError api =
        new TestProxyApiRegistrar().getPigeonApiCameraPermissionsError();

    final String errorCode = "errorCode";
    final CameraPermissionsError instance = new CameraPermissionsError(errorCode, "desc");

    assertEquals(errorCode, api.errorCode(instance));
  }

  @Test
  public void description_returnsValueOfDescriptionFromInstance() {
    final PigeonApiCameraPermissionsError api =
        new TestProxyApiRegistrar().getPigeonApiCameraPermissionsError();

    final String description = "desc";
    final CameraPermissionsError instance = new CameraPermissionsError("errorCode", description);

    assertEquals(description, api.description(instance));
  }
}
