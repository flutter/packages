package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class CameraPermissionsErrorTest {
  @Test
  public void errorCode() {
    final PigeonApiCameraPermissionsError api =
        new TestProxyApiRegistrar().getPigeonApiCameraPermissionsError();

    final String errorCode = "errorCode";
    final CameraPermissionsError instance = new CameraPermissionsError(errorCode, "desc");

    assertEquals(errorCode, api.errorCode(instance));
  }

  @Test
  public void description() {
    final PigeonApiCameraPermissionsError api =
        new TestProxyApiRegistrar().getPigeonApiCameraPermissionsError();

    final String description = "desc";
    final CameraPermissionsError instance = new CameraPermissionsError("errorCode", description);

    assertEquals(description, api.description(instance));
  }
}
