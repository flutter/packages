package io.flutter.plugins.camera.features.intfeature;

import android.hardware.camera2.CaptureRequest;

import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.features.CameraFeature;

/** Controls the zoom configuration on the {@link android.hardware.camera2} API. */
public class IntFeature extends CameraFeature<Integer> {

    private Integer currentValue;

    public IntFeature(CameraProperties cameraProperties, Integer value) {
        super(cameraProperties);
        currentValue = value;
    }

    @Override
    public String getDebugName() {
        return "IntFeature";
    }

    @Override
    public Integer getValue() {
        return currentValue;
    }

    @Override
    public void setValue(Integer value) {
        currentValue = value;
    }

    @Override
    public boolean checkIsSupported() {
        return true;
    }

    @Override
    public void updateBuilder(CaptureRequest.Builder requestBuilder) {
    }
}
