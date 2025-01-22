// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'analyzer.dart';
import 'camera.dart';
import 'camera2_camera_info.dart';
import 'camera_control.dart';
import 'camera_info.dart';
import 'camera_selector.dart';
import 'camera_state.dart';
import 'camera_state_error.dart';
import 'camerax_library.g.dart';
import 'device_orientation_manager.dart';
import 'exposure_state.dart';
import 'focus_metering_result.dart';
import 'image_proxy.dart';
import 'java_object.dart';
import 'live_data.dart';
import 'observer.dart';
import 'pending_recording.dart';
import 'plane_proxy.dart';
import 'process_camera_provider.dart';
import 'recorder.dart';
import 'recording.dart';
import 'system_services.dart';
import 'video_capture.dart';
import 'zoom_state.dart';

/// Handles initialization of Flutter APIs for the Android CameraX library.
class AndroidCameraXCameraFlutterApis {
  /// Creates a [AndroidCameraXCameraFlutterApis].
  AndroidCameraXCameraFlutterApis(
      {JavaObjectFlutterApiImpl? javaObjectFlutterApiImpl,
      CameraFlutterApiImpl? cameraFlutterApiImpl,
      CameraInfoFlutterApiImpl? cameraInfoFlutterApiImpl,
      CameraSelectorFlutterApiImpl? cameraSelectorFlutterApiImpl,
      ProcessCameraProviderFlutterApiImpl? processCameraProviderFlutterApiImpl,
      SystemServicesFlutterApiImpl? systemServicesFlutterApiImpl,
      DeviceOrientationManagerFlutterApiImpl?
          deviceOrientationManagerFlutterApiImpl,
      CameraStateErrorFlutterApiImpl? cameraStateErrorFlutterApiImpl,
      CameraStateFlutterApiImpl? cameraStateFlutterApiImpl,
      PendingRecordingFlutterApiImpl? pendingRecordingFlutterApiImpl,
      RecordingFlutterApiImpl? recordingFlutterApiImpl,
      RecorderFlutterApiImpl? recorderFlutterApiImpl,
      VideoCaptureFlutterApiImpl? videoCaptureFlutterApiImpl,
      ExposureStateFlutterApiImpl? exposureStateFlutterApiImpl,
      ZoomStateFlutterApiImpl? zoomStateFlutterApiImpl,
      LiveDataFlutterApiImpl? liveDataFlutterApiImpl,
      ObserverFlutterApiImpl? observerFlutterApiImpl,
      ImageProxyFlutterApiImpl? imageProxyFlutterApiImpl,
      PlaneProxyFlutterApiImpl? planeProxyFlutterApiImpl,
      AnalyzerFlutterApiImpl? analyzerFlutterApiImpl,
      CameraControlFlutterApiImpl? cameraControlFlutterApiImpl,
      FocusMeteringResultFlutterApiImpl? focusMeteringResultFlutterApiImpl,
      Camera2CameraInfoFlutterApiImpl? camera2CameraInfoFlutterApiImpl}) {
    this.javaObjectFlutterApiImpl =
        javaObjectFlutterApiImpl ?? JavaObjectFlutterApiImpl();
    this.cameraInfoFlutterApiImpl =
        cameraInfoFlutterApiImpl ?? CameraInfoFlutterApiImpl();
    this.cameraSelectorFlutterApiImpl =
        cameraSelectorFlutterApiImpl ?? CameraSelectorFlutterApiImpl();
    this.processCameraProviderFlutterApiImpl =
        processCameraProviderFlutterApiImpl ??
            ProcessCameraProviderFlutterApiImpl();
    this.cameraFlutterApiImpl = cameraFlutterApiImpl ?? CameraFlutterApiImpl();
    this.systemServicesFlutterApiImpl =
        systemServicesFlutterApiImpl ?? SystemServicesFlutterApiImpl();
    this.deviceOrientationManagerFlutterApiImpl =
        deviceOrientationManagerFlutterApiImpl ??
            DeviceOrientationManagerFlutterApiImpl();
    this.cameraStateErrorFlutterApiImpl =
        cameraStateErrorFlutterApiImpl ?? CameraStateErrorFlutterApiImpl();
    this.cameraStateFlutterApiImpl =
        cameraStateFlutterApiImpl ?? CameraStateFlutterApiImpl();
    this.pendingRecordingFlutterApiImpl =
        pendingRecordingFlutterApiImpl ?? PendingRecordingFlutterApiImpl();
    this.recordingFlutterApiImpl =
        recordingFlutterApiImpl ?? RecordingFlutterApiImpl();
    this.recorderFlutterApiImpl =
        recorderFlutterApiImpl ?? RecorderFlutterApiImpl();
    this.videoCaptureFlutterApiImpl =
        videoCaptureFlutterApiImpl ?? VideoCaptureFlutterApiImpl();
    this.exposureStateFlutterApiImpl =
        exposureStateFlutterApiImpl ?? ExposureStateFlutterApiImpl();
    this.zoomStateFlutterApiImpl =
        zoomStateFlutterApiImpl ?? ZoomStateFlutterApiImpl();
    this.liveDataFlutterApiImpl =
        liveDataFlutterApiImpl ?? LiveDataFlutterApiImpl();
    this.observerFlutterApiImpl =
        observerFlutterApiImpl ?? ObserverFlutterApiImpl();
    this.analyzerFlutterApiImpl =
        analyzerFlutterApiImpl ?? AnalyzerFlutterApiImpl();
    this.imageProxyFlutterApiImpl =
        imageProxyFlutterApiImpl ?? ImageProxyFlutterApiImpl();
    this.planeProxyFlutterApiImpl =
        planeProxyFlutterApiImpl ?? PlaneProxyFlutterApiImpl();
    this.cameraControlFlutterApiImpl =
        cameraControlFlutterApiImpl ?? CameraControlFlutterApiImpl();
    this.focusMeteringResultFlutterApiImpl =
        focusMeteringResultFlutterApiImpl ??
            FocusMeteringResultFlutterApiImpl();
    this.camera2CameraInfoFlutterApiImpl =
        camera2CameraInfoFlutterApiImpl ?? Camera2CameraInfoFlutterApiImpl();
  }

  static bool _haveBeenSetUp = false;

  /// Mutable instance containing all Flutter Apis for Android CameraX Camera.
  ///
  /// This should only be changed for testing purposes.
  static AndroidCameraXCameraFlutterApis instance =
      AndroidCameraXCameraFlutterApis();

  /// Handles callbacks methods for the native Java Object class.
  late final JavaObjectFlutterApi javaObjectFlutterApiImpl;

  /// Flutter Api implementation for [CameraInfo].
  late final CameraInfoFlutterApiImpl cameraInfoFlutterApiImpl;

  /// Flutter Api implementation for [CameraSelector].
  late final CameraSelectorFlutterApiImpl cameraSelectorFlutterApiImpl;

  /// Flutter Api implementation for [ProcessCameraProvider].
  late final ProcessCameraProviderFlutterApiImpl
      processCameraProviderFlutterApiImpl;

  /// Flutter Api implementation for [Camera].
  late final CameraFlutterApiImpl cameraFlutterApiImpl;

  /// Flutter Api implementation for [SystemServices].
  late final SystemServicesFlutterApiImpl systemServicesFlutterApiImpl;

  /// Flutter Api implementation for [DeviceOrientationManager].
  late final DeviceOrientationManagerFlutterApiImpl
      deviceOrientationManagerFlutterApiImpl;

  /// Flutter Api implementation for [CameraStateError].
  late final CameraStateErrorFlutterApiImpl? cameraStateErrorFlutterApiImpl;

  /// Flutter Api implementation for [CameraState].
  late final CameraStateFlutterApiImpl? cameraStateFlutterApiImpl;

  /// Flutter Api implementation for [LiveData].
  late final LiveDataFlutterApiImpl? liveDataFlutterApiImpl;

  /// Flutter Api implementation for [Observer].
  late final ObserverFlutterApiImpl? observerFlutterApiImpl;

  /// Flutter Api for [PendingRecording].
  late final PendingRecordingFlutterApiImpl pendingRecordingFlutterApiImpl;

  /// Flutter Api for [Recording].
  late final RecordingFlutterApiImpl recordingFlutterApiImpl;

  /// Flutter Api for [Recorder].
  late final RecorderFlutterApiImpl recorderFlutterApiImpl;

  /// Flutter Api for [VideoCapture].
  late final VideoCaptureFlutterApiImpl videoCaptureFlutterApiImpl;

  /// Flutter Api for [ExposureState].
  late final ExposureStateFlutterApiImpl exposureStateFlutterApiImpl;

  /// Flutter Api for [ZoomState].
  late final ZoomStateFlutterApiImpl zoomStateFlutterApiImpl;

  /// Flutter Api implementation for [Analyzer].
  late final AnalyzerFlutterApiImpl analyzerFlutterApiImpl;

  /// Flutter Api implementation for [ImageProxy].
  late final ImageProxyFlutterApiImpl imageProxyFlutterApiImpl;

  /// Flutter Api implementation for [PlaneProxy].
  late final PlaneProxyFlutterApiImpl planeProxyFlutterApiImpl;

  /// Flutter Api implementation for [CameraControl].
  late final CameraControlFlutterApiImpl cameraControlFlutterApiImpl;

  /// Flutter Api implementation for [FocusMeteringResult].
  late final FocusMeteringResultFlutterApiImpl
      focusMeteringResultFlutterApiImpl;

  /// Flutter Api implementation for [Camera2CameraInfo].
  late final Camera2CameraInfoFlutterApiImpl camera2CameraInfoFlutterApiImpl;

  /// Ensures all the Flutter APIs have been setup to receive calls from native code.
  void ensureSetUp() {
    if (!_haveBeenSetUp) {
      JavaObjectFlutterApi.setup(javaObjectFlutterApiImpl);
      CameraInfoFlutterApi.setup(cameraInfoFlutterApiImpl);
      CameraSelectorFlutterApi.setup(cameraSelectorFlutterApiImpl);
      ProcessCameraProviderFlutterApi.setup(
          processCameraProviderFlutterApiImpl);
      CameraFlutterApi.setup(cameraFlutterApiImpl);
      SystemServicesFlutterApi.setup(systemServicesFlutterApiImpl);
      DeviceOrientationManagerFlutterApi.setup(
          deviceOrientationManagerFlutterApiImpl);
      CameraStateErrorFlutterApi.setup(cameraStateErrorFlutterApiImpl);
      CameraStateFlutterApi.setup(cameraStateFlutterApiImpl);
      PendingRecordingFlutterApi.setup(pendingRecordingFlutterApiImpl);
      RecordingFlutterApi.setup(recordingFlutterApiImpl);
      RecorderFlutterApi.setup(recorderFlutterApiImpl);
      VideoCaptureFlutterApi.setup(videoCaptureFlutterApiImpl);
      ExposureStateFlutterApi.setup(exposureStateFlutterApiImpl);
      ZoomStateFlutterApi.setup(zoomStateFlutterApiImpl);
      AnalyzerFlutterApi.setup(analyzerFlutterApiImpl);
      ImageProxyFlutterApi.setup(imageProxyFlutterApiImpl);
      PlaneProxyFlutterApi.setup(planeProxyFlutterApiImpl);
      LiveDataFlutterApi.setup(liveDataFlutterApiImpl);
      ObserverFlutterApi.setup(observerFlutterApiImpl);
      CameraControlFlutterApi.setup(cameraControlFlutterApiImpl);
      FocusMeteringResultFlutterApi.setup(focusMeteringResultFlutterApiImpl);
      Camera2CameraInfoFlutterApi.setup(camera2CameraInfoFlutterApiImpl);
      _haveBeenSetUp = true;
    }
  }
}
