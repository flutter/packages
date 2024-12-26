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
import androidx.lifecycle.LifecycleOwner;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;

public class ProxyApiRegistrar extends CameraXLibraryPigeonProxyApiRegistrar {
  @NonNull
  private final CameraPermissionsManager cameraPermissionsManager = new CameraPermissionsManager();

  @NonNull
  private final TextureRegistry textureRegistry;

  private final long defaultClearFinalizedWeakReferencesInterval;

  @NonNull
  private Context context;

  @Nullable
  private CameraPermissionsManager.PermissionsRegistry permissionsRegistry;

  public ProxyApiRegistrar(@NonNull BinaryMessenger binaryMessenger, @NonNull Context context, @NonNull TextureRegistry textureRegistry) {
    super(binaryMessenger);
    this.context = context;
    this.textureRegistry = textureRegistry;
    defaultClearFinalizedWeakReferencesInterval = getInstanceManager().getClearFinalizedWeakReferencesInterval();
  }

  // Interface for an injectable SDK version checker.
  @ChecksSdkIntAtLeast(parameter = 0)
  boolean sdkIsAtLeast(int version) {
    return Build.VERSION.SDK_INT >= version;
  }

  // Added to be overridden for tests. The test implementation calls `callback` immediately, instead
  // of waiting for the main thread to run it.
  void runOnMainThread(@NonNull Runnable runnable) {
    if (context instanceof Activity) {
      ((Activity) context).runOnUiThread(runnable);
    } else {
      new Handler(Looper.getMainLooper()).post(runnable);
    }
  }

  // For logging exceptions received from Host -> Dart message calls.
  void logError(@NonNull String tag, @NonNull Throwable exception) {
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

  @Nullable
  public LifecycleOwner getLifecycleOwner() {
    if (context instanceof LifecycleOwner) {
      return (LifecycleOwner) context;
    } else if (context instanceof Activity) {
      return new ProxyLifecycleProvider((Activity) context);
    }

    return null;
  }

  @NonNull
  public CameraPermissionsManager getCameraPermissionsManager() {
    return cameraPermissionsManager;
  }

  void setPermissionsRegistry(@Nullable CameraPermissionsManager.PermissionsRegistry permissionsRegistry) {
    this.permissionsRegistry = permissionsRegistry;
  }

  @Nullable
  CameraPermissionsManager.PermissionsRegistry getPermissionsRegistry() {
    return permissionsRegistry;
  }

  @NonNull
  TextureRegistry getTextureRegistry() {
    return textureRegistry;
  }

  long getDefaultClearFinalizedWeakReferencesInterval() {
    return defaultClearFinalizedWeakReferencesInterval;
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
    return new CameraInfoProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCameraSelector getPigeonApiCameraSelector() {
    return new CameraSelectorProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiProcessCameraProvider getPigeonApiProcessCameraProvider() {
    return new ProcessCameraProviderProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCamera getPigeonApiCamera() {
    return new CameraProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiSystemServicesManager getPigeonApiSystemServicesManager() {
    return new SystemServicesManagerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiDeviceOrientationManager getPigeonApiDeviceOrientationManager() {
    return new DeviceOrientationManagerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiPreview getPigeonApiPreview() {
    return new PreviewProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiVideoCapture getPigeonApiVideoCapture() {
    return new VideoCaptureProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiRecorder getPigeonApiRecorder() {
    return new RecorderProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiVideoRecordEventListener getPigeonApiVideoRecordEventListener() {
    return new VideoRecordEventListenerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiPendingRecording getPigeonApiPendingRecording() {
    return new PendingRecordingProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiRecording getPigeonApiRecording() {
    return new RecordingProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiImageCapture getPigeonApiImageCapture() {
    return new ImageCaptureProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiResolutionStrategy getPigeonApiResolutionStrategy() {
    return new ResolutionStrategyProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiResolutionSelector getPigeonApiResolutionSelector() {
    return new ResolutionSelectorProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiAspectRatioStrategy getPigeonApiAspectRatioStrategy() {
    return new AspectRatioStrategyProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCameraState getPigeonApiCameraState() {
    return new CameraStateProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiExposureState getPigeonApiExposureState() {
    return new ExposureStateProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiZoomState getPigeonApiZoomState() {
    return new ZoomStateProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiImageAnalysis getPigeonApiImageAnalysis() {
    return new ImageAnalysisProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiAnalyzer getPigeonApiAnalyzer() {
    return new AnalyzerProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiCameraStateStateError getPigeonApiCameraStateStateError() {
    return new CameraStateStateErrorProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiLiveData getPigeonApiLiveData() {
    return new LiveDataProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiImageProxy getPigeonApiImageProxy() {
    return new ImageProxyProxyApi(this);
  }

  @NonNull
  @Override
  public PigeonApiPlaneProxy getPigeonApiPlaneProxy() {
    return new PlaneProxyProxyApi(this);
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
