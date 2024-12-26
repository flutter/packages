package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.BinaryMessenger;

public class ProxyApiRegistrar extends CameraXLibraryPigeonProxyApiRegistrar {
  @NonNull
  private Context context;

  public ProxyApiRegistrar(@NonNull BinaryMessenger binaryMessenger, @NonNull Context context) {
    super(binaryMessenger);
    this.context = context;
  }

  // Interface for an injectable SDK version checker.
  @ChecksSdkIntAtLeast(parameter = 0)
  boolean sdkIsAtLeast(int version) {
    return Build.VERSION.SDK_INT >= version;
  }

  // Added to be overridden for tests. The test implementation calls `callback` immediately, instead
  // of waiting for the main thread to run it.
  void runOnMainThread(Runnable runnable) {
    if (context instanceof Activity) {
      ((Activity) context).runOnUiThread(runnable);
    } else {
      new Handler(Looper.getMainLooper()).post(runnable);
    }
  }

  // For logging exceptions received from Host -> Dart message calls.
  void logError(String tag, Throwable exception) {
    Log.e(
        tag,
        exception.getClass().getSimpleName()
            + ", Message: "
            + exception.getMessage()
            + ", Stacktrace: "
            + Log.getStackTraceString(exception));
  }

  @NonNull
  public Context getContext() {
    return context;
  }

  public void setContext(@NonNull Context context) {
    this.context = context;
  }

  @NonNull
  @Override
  public PigeonApiCameraSize getPigeonApiCameraSize() {
    return new CameraSizeProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiResolutionInfo getPigeonApiResolutionInfo() {
    return new ResolutionInfoProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCameraPermissionsErrorData getPigeonApiCameraPermissionsErrorData() {
    return new CameraPermissionsErrorDataProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCameraIntegerRange getPigeonApiCameraIntegerRange() {
    return new CameraIntegerRangeProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiMeteringPoint getPigeonApiMeteringPoint() {
    return new MeteringPointProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiObserver getPigeonApiObserver() {
    return new ObserverProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCameraInfo getPigeonApiCameraInfo() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCameraSelector getPigeonApiCameraSelector() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiProcessCameraProvider getPigeonApiProcessCameraProvider() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCamera getPigeonApiCamera() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiSystemServicesManager getPigeonApiSystemServicesManager() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiDeviceOrientationManager getPigeonApiDeviceOrientationManager() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiPreview getPigeonApiPreview() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiVideoCapture getPigeonApiVideoCapture() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiRecorder getPigeonApiRecorder() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiVideoRecordEventListener getPigeonApiVideoRecordEventListener() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiPendingRecording getPigeonApiPendingRecording() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiRecording getPigeonApiRecording() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiImageCapture getPigeonApiImageCapture() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiResolutionStrategy getPigeonApiResolutionStrategy() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiResolutionSelector getPigeonApiResolutionSelector() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiAspectRatioStrategy getPigeonApiAspectRatioStrategy() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCameraState getPigeonApiCameraState() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiExposureState getPigeonApiExposureState() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiZoomState getPigeonApiZoomState() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiImageAnalysis getPigeonApiImageAnalysis() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiAnalyzer getPigeonApiAnalyzer() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCameraStateStateError getPigeonApiCameraStateStateError() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiLiveData getPigeonApiLiveData() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiImageProxy getPigeonApiImageProxy() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiPlaneProxy getPigeonApiPlaneProxy() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiQualitySelector getPigeonApiQualitySelector() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiFallbackStrategy getPigeonApiFallbackStrategy() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCameraControl getPigeonApiCameraControl() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiFocusMeteringActionBuilder getPigeonApiFocusMeteringActionBuilder() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiFocusMeteringAction getPigeonApiFocusMeteringAction() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiFocusMeteringResult getPigeonApiFocusMeteringResult() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCaptureRequest getPigeonApiCaptureRequest() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCaptureRequestOptions getPigeonApiCaptureRequestOptions() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCamera2CameraControl getPigeonApiCamera2CameraControl() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiResolutionFilter getPigeonApiResolutionFilter() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCameraCharacteristics getPigeonApiCameraCharacteristics() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiCamera2CameraInfo getPigeonApiCamera2CameraInfo() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiMeteringPointFactory getPigeonApiMeteringPointFactory() {
    return null;
  }

  @NonNull
  @Override
  public PigeonApiDisplayOrientedMeteringPointFactory getPigeonApiDisplayOrientedMeteringPointFactory() {
    return null;
  }
}
