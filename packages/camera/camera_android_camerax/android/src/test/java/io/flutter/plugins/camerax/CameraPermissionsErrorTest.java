package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.CameraInfo;

import org.junit.Test;

public class CameraPermissionsErrorTest {
  @Test
  public void errorCode() {
    final PigeonApiCameraPermissionsError api = new TestProxyApiRegistrar().getPigeonApiCameraPermissionsError();

    final String errorCode = "errorCode";
    final CameraPermissionsError instance = new CameraPermissionsError(errorCode, "desc");

    assertEquals(errorCode, api.errorCode(instance));
  }

  @Test
  public void description() {
    final PigeonApiCameraPermissionsError api = new TestProxyApiRegistrar().getPigeonApiCameraPermissionsError();

    final String description = "desc";
    final CameraPermissionsError instance = new CameraPermissionsError("errorCode", description);

    assertEquals(description, api.description(instance));
  }
}
