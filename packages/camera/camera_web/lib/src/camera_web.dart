// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:math';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web/web.dart' as web;

import 'camera.dart';
import 'camera_service.dart';
import 'pkg_web_tweaks.dart';
import 'types/types.dart';

// The default error message, when the error is an empty string.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/message
const String _kDefaultErrorMessage =
    'No further diagnostic information can be determined or provided.';

/// The web implementation of [CameraPlatform].
///
/// This class implements the `package:camera` functionality for the web.
class CameraPlugin extends CameraPlatform {
  /// Creates a new instance of [CameraPlugin]
  /// with the given [cameraService].
  CameraPlugin({required CameraService cameraService})
      : _cameraService = cameraService;

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith(Registrar registrar) {
    CameraPlatform.instance = CameraPlugin(
      cameraService: CameraService(),
    );
  }

  final CameraService _cameraService;

  /// The cameras managed by the [CameraPlugin].
  @visibleForTesting
  final Map<int, Camera> cameras = <int, Camera>{};
  int _textureCounter = 1;

  /// Metadata associated with each camera description.
  /// Populated in [availableCameras].
  @visibleForTesting
  final Map<CameraDescription, CameraMetadata> camerasMetadata =
      <CameraDescription, CameraMetadata>{};

  /// The controller used to broadcast different camera events.
  ///
  /// It is `broadcast` as multiple controllers may subscribe
  /// to different stream views of this controller.
  @visibleForTesting
  final StreamController<CameraEvent> cameraEventStreamController =
      StreamController<CameraEvent>.broadcast();

  /// The stream provider for [web.HTMLVideoElement] error events.
  @visibleForTesting
  web.EventStreamProvider<web.Event> videoElementOnErrorProvider =
      web.EventStreamProviders.errorElementEvent;

  final Map<int, StreamSubscription<web.Event>> _cameraVideoErrorSubscriptions =
      <int, StreamSubscription<web.Event>>{};

  /// The stream provider for [web.HTMLVideoElement] abort events.
  @visibleForTesting
  web.EventStreamProvider<web.Event> videoElementOnAbortProvider =
      web.EventStreamProviders.errorElementEvent;

  final Map<int, StreamSubscription<web.Event>> _cameraVideoAbortSubscriptions =
      <int, StreamSubscription<web.Event>>{};

  final Map<int, StreamSubscription<web.MediaStreamTrack>>
      _cameraEndedSubscriptions =
      <int, StreamSubscription<web.MediaStreamTrack>>{};

  final Map<int, StreamSubscription<web.ErrorEvent>>
      _cameraVideoRecordingErrorSubscriptions =
      <int, StreamSubscription<web.ErrorEvent>>{};

  /// Returns a stream of camera events for the given [cameraId].
  Stream<CameraEvent> _cameraEvents(int cameraId) =>
      cameraEventStreamController.stream
          .where((CameraEvent event) => event.cameraId == cameraId);

  /// The stream provider for [web.ScreenOrientation] change events.
  @visibleForTesting
  web.EventStreamProvider<web.Event> orientationOnChangeProvider =
      web.EventStreamProviders.changeEvent;

  /// The current browser window used to access media devices.
  @visibleForTesting
  web.Window window = web.window;

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      final web.MediaDevices mediaDevices = window.navigator.mediaDevices;
      final List<CameraDescription> cameras = <CameraDescription>[];

      // Request video permissions only.
      final web.MediaStream cameraStream =
          await _cameraService.getMediaStreamForOptions(const CameraOptions());

      // Release the camera stream used to request video permissions.
      cameraStream
          .getVideoTracks()
          .toDart
          .forEach((web.MediaStreamTrack videoTrack) => videoTrack.stop());

      // Request available media devices.
      final List<web.MediaDeviceInfo> devices =
          (await mediaDevices.enumerateDevices().toDart).toDart;

      // Filter video input devices.
      final Iterable<web.MediaDeviceInfo> videoInputDevices = devices
          .where(
            (web.MediaDeviceInfo device) =>
                device.kind == MediaDeviceKind.videoInput,
          )

          /// The device id property is currently not supported on Internet Explorer:
          /// https://developer.mozilla.org/en-US/docs/Web/API/MediaDeviceInfo/deviceId#browser_compatibility
          .where((web.MediaDeviceInfo device) => device.deviceId.isNotEmpty);

      // Map video input devices to camera descriptions.
      for (final web.MediaDeviceInfo videoInputDevice in videoInputDevices) {
        // Get the video stream for the current video input device
        // to later use for the available video tracks.
        final web.MediaStream videoStream =
            await _getVideoStreamForDevice(videoInputDevice.deviceId);

        // Get all video tracks in the video stream
        // to later extract the lens direction from the first track.
        final List<web.MediaStreamTrack> videoTracks =
            videoStream.getVideoTracks().toDart;

        if (videoTracks.isNotEmpty) {
          // Get the facing mode from the first available video track.
          final String? facingMode =
              _cameraService.getFacingModeForVideoTrack(videoTracks.first);

          // Get the lens direction based on the facing mode.
          // Fallback to the external lens direction
          // if the facing mode is not available.
          final CameraLensDirection lensDirection = facingMode != null
              ? _cameraService.mapFacingModeToLensDirection(facingMode)
              : CameraLensDirection.external;

          // Create a camera description.
          //
          // The name is a camera label which might be empty
          // if no permissions to media devices have been granted.
          //
          // MediaDeviceInfo.label:
          // https://developer.mozilla.org/en-US/docs/Web/API/MediaDeviceInfo/label
          //
          // Sensor orientation is currently not supported.
          final CameraDescription camera = CameraDescription(
            name: videoInputDevice.label,
            lensDirection: lensDirection,
            sensorOrientation: 0,
          );

          final CameraMetadata cameraMetadata = CameraMetadata(
            deviceId: videoInputDevice.deviceId,
            facingMode: facingMode,
          );

          cameras.add(camera);

          camerasMetadata[camera] = cameraMetadata;

          // Release the camera stream of the current video input device.
          for (final web.MediaStreamTrack videoTrack in videoTracks) {
            videoTrack.stop();
          }
        } else {
          // Ignore as no video tracks exist in the current video input device.
          continue;
        }
      }

      return cameras;
    } on web.DOMException catch (e) {
      throw CameraException(e.name, e.message);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw CameraException(e.code.toString(), e.description);
    }
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) =>
      createCameraWithSettings(
          cameraDescription,
          MediaSettings(
            resolutionPreset: resolutionPreset,
            enableAudio: enableAudio,
          ));

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings? mediaSettings,
  ) async {
    try {
      if (!camerasMetadata.containsKey(cameraDescription)) {
        throw PlatformException(
          code: CameraErrorCode.missingMetadata.toString(),
          message:
              'Missing camera metadata. Make sure to call `availableCameras` before creating a camera.',
        );
      }

      final int textureId = _textureCounter++;

      final CameraMetadata cameraMetadata = camerasMetadata[cameraDescription]!;

      final CameraType? cameraType = cameraMetadata.facingMode != null
          ? _cameraService.mapFacingModeToCameraType(cameraMetadata.facingMode!)
          : null;

      // Use the highest resolution possible
      // if the resolution preset is not specified.
      final Size videoSize = _cameraService.mapResolutionPresetToSize(
          mediaSettings?.resolutionPreset ?? ResolutionPreset.max);

      // Create a camera with the given audio and video constraints.
      // Sensor orientation is currently not supported.
      final Camera camera = Camera(
        textureId: textureId,
        cameraService: _cameraService,
        options: CameraOptions(
          audio: AudioConstraints(enabled: mediaSettings?.enableAudio ?? true),
          video: VideoConstraints(
            facingMode:
                cameraType != null ? FacingModeConstraint(cameraType) : null,
            width: VideoSizeConstraint(
              ideal: videoSize.width.toInt(),
            ),
            height: VideoSizeConstraint(
              ideal: videoSize.height.toInt(),
            ),
            deviceId: cameraMetadata.deviceId,
          ),
        ),
        recorderOptions: (
          audioBitrate: mediaSettings?.audioBitrate,
          videoBitrate: mediaSettings?.videoBitrate,
        ),
      );

      cameras[textureId] = camera;

      return textureId;
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    // The image format group is currently not supported.
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    try {
      final Camera camera = getCamera(cameraId);

      await camera.initialize();

      // Add camera's video error events to the camera events stream.
      // The error event fires when the video element's source has failed to load, or can't be used.
      _cameraVideoErrorSubscriptions[cameraId] = videoElementOnErrorProvider
          .forElement(camera.videoElement)
          .listen((web.Event _) {
        // The Event itself (_) doesn't contain information about the actual error.
        // We need to look at the HTMLMediaElement.error.
        // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
        final web.MediaError error = camera.videoElement.error!;
        final CameraErrorCode errorCode = CameraErrorCode.fromMediaError(error);
        final String errorMessage =
            error.message != '' ? error.message : _kDefaultErrorMessage;

        cameraEventStreamController.add(
          CameraErrorEvent(
            cameraId,
            'Error code: $errorCode, error message: $errorMessage',
          ),
        );
      });

      // Add camera's video abort events to the camera events stream.
      // The abort event fires when the video element's source has not fully loaded.
      _cameraVideoAbortSubscriptions[cameraId] = videoElementOnAbortProvider
          .forElement(camera.videoElement)
          .listen((web.Event _) {
        cameraEventStreamController.add(
          CameraErrorEvent(
            cameraId,
            "Error code: ${CameraErrorCode.abort}, error message: The video element's source has not fully loaded.",
          ),
        );
      });

      await camera.play();

      // Add camera's closing events to the camera events stream.
      // The onEnded stream fires when there is no more camera stream data.
      _cameraEndedSubscriptions[cameraId] =
          camera.onEnded.listen((web.MediaStreamTrack _) {
        cameraEventStreamController.add(
          CameraClosingEvent(cameraId),
        );
      });

      final Size cameraSize = camera.getVideoSize();

      cameraEventStreamController.add(
        CameraInitializedEvent(
          cameraId,
          cameraSize.width,
          cameraSize.height,
          // TODO(bselwe): Add support for exposure mode and point (https://github.com/flutter/flutter/issues/86857).
          ExposureMode.auto,
          false,
          // TODO(bselwe): Add support for focus mode and point (https://github.com/flutter/flutter/issues/86858).
          FocusMode.auto,
          false,
        ),
      );
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraInitializedEvent>();
  }

  /// Emits an empty stream as there is no event corresponding to a change
  /// in the camera resolution on the web.
  ///
  /// In order to change the camera resolution a new camera with appropriate
  /// [CameraOptions.video] constraints has to be created and initialized.
  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return const Stream<CameraResolutionChangedEvent>.empty();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraClosingEvent>();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return _cameraEvents(cameraId).whereType<CameraErrorEvent>();
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    return getCamera(cameraId).onVideoRecordedEvent;
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    final web.ScreenOrientation orientation = window.screen.orientation;

    // Create an initial orientation event that emits the device orientation
    // as soon as subscribed to this stream.
    final web.Event initialOrientationEvent = web.Event('change');

    return orientationOnChangeProvider
        .forTarget(orientation)
        .startWith(initialOrientationEvent)
        .map(
      (web.Event _) {
        final DeviceOrientation deviceOrientation = _cameraService
            .mapOrientationTypeToDeviceOrientation(orientation.type);
        return DeviceOrientationChangedEvent(deviceOrientation);
      },
    );
  }

  @override
  Future<void> lockCaptureOrientation(
    int cameraId,
    DeviceOrientation orientation,
  ) async {
    try {
      final web.ScreenOrientation screenOrientation = window.screen.orientation;
      final web.Element? documentElement = window.document.documentElement;

      if (documentElement != null) {
        final String orientationType =
            _cameraService.mapDeviceOrientationToOrientationType(orientation);

        // Full-screen mode may be required to modify the device orientation.
        // See: https://w3c.github.io/screen-orientation/#interaction-with-fullscreen-api
        // Recent versions of Dart changed requestFullscreen to return a Future instead of void.
        // This wrapper allows use of both the old and new APIs.
        dynamic fullScreen() => documentElement.requestFullScreenTweak();
        await fullScreen();
        await screenOrientation.lock(orientationType).toDart;
      } else {
        throw PlatformException(
          code: CameraErrorCode.orientationNotSupported.toString(),
          message: 'Orientation is not supported in the current browser.',
        );
      }
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    }
  }

  @override
  Future<void> unlockCaptureOrientation(int cameraId) async {
    try {
      final web.ScreenOrientation orientation = window.screen.orientation;
      final web.Element? documentElement = window.document.documentElement;

      if (documentElement != null) {
        orientation.unlock();
      } else {
        throw PlatformException(
          code: CameraErrorCode.orientationNotSupported.toString(),
          message: 'Orientation is not supported in the current browser.',
        );
      }
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    }
  }

  @override
  Future<XFile> takePicture(int cameraId) {
    try {
      return getCamera(cameraId).takePicture();
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> prepareForVideoRecording() async {
    // This is a no-op as it is not required for the web.
  }

  @override
  Future<void> startVideoRecording(int cameraId, {Duration? maxVideoDuration}) {
    // Ignore maxVideoDuration, as it is deprecated.
    return startVideoCapturing(VideoCaptureOptions(cameraId));
  }

  @override
  Future<void> startVideoCapturing(VideoCaptureOptions options) {
    if (options.streamCallback != null || options.streamOptions != null) {
      throw UnimplementedError('Streaming is not currently supported on web');
    }

    try {
      final Camera camera = getCamera(options.cameraId);

      // Add camera's video recording errors to the camera events stream.
      // The error event fires when the video recording is not allowed or an unsupported
      // codec is used.
      _cameraVideoRecordingErrorSubscriptions[options.cameraId] =
          camera.onVideoRecordingError.listen((web.ErrorEvent errorEvent) {
        cameraEventStreamController.add(
          CameraErrorEvent(
            options.cameraId,
            'Error code: ${errorEvent.type}, error message: ${errorEvent.message}.',
          ),
        );
      });

      return camera.startVideoRecording();
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<XFile> stopVideoRecording(int cameraId) async {
    try {
      final XFile videoRecording =
          await getCamera(cameraId).stopVideoRecording();
      await _cameraVideoRecordingErrorSubscriptions[cameraId]?.cancel();
      return videoRecording;
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> pauseVideoRecording(int cameraId) {
    try {
      return getCamera(cameraId).pauseVideoRecording();
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> resumeVideoRecording(int cameraId) {
    try {
      return getCamera(cameraId).resumeVideoRecording();
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {
    try {
      getCamera(cameraId).setFlashMode(mode);
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> setExposureMode(int cameraId, ExposureMode mode) {
    throw UnimplementedError('setExposureMode() is not implemented.');
  }

  @override
  Future<void> setExposurePoint(int cameraId, Point<double>? point) {
    throw UnimplementedError('setExposurePoint() is not implemented.');
  }

  @override
  Future<double> getMinExposureOffset(int cameraId) {
    throw UnimplementedError('getMinExposureOffset() is not implemented.');
  }

  @override
  Future<double> getMaxExposureOffset(int cameraId) {
    throw UnimplementedError('getMaxExposureOffset() is not implemented.');
  }

  @override
  Future<double> getExposureOffsetStepSize(int cameraId) {
    throw UnimplementedError('getExposureOffsetStepSize() is not implemented.');
  }

  @override
  Future<double> setExposureOffset(int cameraId, double offset) {
    throw UnimplementedError('setExposureOffset() is not implemented.');
  }

  @override
  Future<void> setFocusMode(int cameraId, FocusMode mode) {
    throw UnimplementedError('setFocusMode() is not implemented.');
  }

  @override
  Future<void> setFocusPoint(int cameraId, Point<double>? point) {
    throw UnimplementedError('setFocusPoint() is not implemented.');
  }

  @override
  Future<double> getMaxZoomLevel(int cameraId) async {
    try {
      return getCamera(cameraId).getMaxZoomLevel();
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<double> getMinZoomLevel(int cameraId) async {
    try {
      return getCamera(cameraId).getMinZoomLevel();
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Future<void> setZoomLevel(int cameraId, double zoom) async {
    try {
      getCamera(cameraId).setZoomLevel(zoom);
    } on web.DOMException catch (e) {
      throw CameraException(e.name, e.message);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw CameraException(e.code.toString(), e.description);
    }
  }

  @override
  Future<void> pausePreview(int cameraId) async {
    try {
      getCamera(cameraId).pause();
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    }
  }

  @override
  Future<void> resumePreview(int cameraId) async {
    try {
      await getCamera(cameraId).play();
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    } on CameraWebException catch (e) {
      _addCameraErrorEvent(e);
      throw PlatformException(code: e.code.toString(), message: e.description);
    }
  }

  @override
  Widget buildPreview(int cameraId) {
    return HtmlElementView(
      viewType: getCamera(cameraId).getViewType(),
    );
  }

  @override
  Future<void> dispose(int cameraId) async {
    try {
      await getCamera(cameraId).dispose();
      await _cameraVideoErrorSubscriptions[cameraId]?.cancel();
      await _cameraVideoAbortSubscriptions[cameraId]?.cancel();

      await _cameraEndedSubscriptions[cameraId]?.cancel();
      await _cameraVideoRecordingErrorSubscriptions[cameraId]?.cancel();

      cameras.remove(cameraId);
      _cameraVideoErrorSubscriptions.remove(cameraId);
      _cameraVideoAbortSubscriptions.remove(cameraId);
      _cameraEndedSubscriptions.remove(cameraId);
    } on web.DOMException catch (e) {
      throw PlatformException(code: e.name, message: e.message);
    }
  }

  /// Returns a media video stream for the device with the given [deviceId].
  Future<web.MediaStream> _getVideoStreamForDevice(
    String deviceId,
  ) {
    // Create camera options with the desired device id.
    final CameraOptions cameraOptions = CameraOptions(
      video: VideoConstraints(deviceId: deviceId),
    );

    return _cameraService.getMediaStreamForOptions(cameraOptions);
  }

  /// Returns a camera for the given [cameraId].
  ///
  /// Throws a [CameraException] if the camera does not exist.
  @visibleForTesting
  Camera getCamera(int cameraId) {
    final Camera? camera = cameras[cameraId];

    if (camera == null) {
      throw PlatformException(
        code: CameraErrorCode.notFound.toString(),
        message: 'No camera found for the given camera id $cameraId.',
      );
    }

    return camera;
  }

  /// Adds a [CameraErrorEvent], associated with the [exception],
  /// to the stream of camera events.
  void _addCameraErrorEvent(CameraWebException exception) {
    cameraEventStreamController.add(
      CameraErrorEvent(
        exception.cameraId,
        'Error code: ${exception.code}, error message: ${exception.description}',
      ),
    );
  }
}
