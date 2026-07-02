// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

import 'camera.dart';
import 'pkg_web_tweaks.dart';
import 'shims/dart_js_util.dart';
import 'types/types.dart';

/// A service to fetch, map camera settings and
/// obtain the camera stream.
class CameraService {
  /// The current browser window used to access media devices.
  @visibleForTesting
  web.Window window = web.window;

  /// The utility to manipulate JavaScript interop objects.
  @visibleForTesting
  JsUtil jsUtil = JsUtil();

  /// Returns a media stream associated with the camera device
  /// with [cameraId] and constrained by [options].
  Future<web.MediaStream> getMediaStreamForOptions(
    CameraOptions options, {
    int cameraId = 0,
  }) async {
    final web.MediaDevices mediaDevices = window.navigator.mediaDevices;

    try {
      return await mediaDevices.getUserMedia(options.toMediaStreamConstraints()).toDart;
    } on web.DOMException catch (e) {
      switch (e.name) {
        case 'NotFoundError':
        case 'DevicesNotFoundError':
          throw CameraWebException(
            cameraId,
            CameraErrorCode.notFound,
            'No camera found for the given camera options.',
          );
        case 'NotReadableError':
        case 'TrackStartError':
          throw CameraWebException(
            cameraId,
            CameraErrorCode.notReadable,
            'The camera is not readable due to a hardware error '
            'that prevented access to the device.',
          );
        case 'OverconstrainedError':
        case 'ConstraintNotSatisfiedError':
          throw CameraWebException(
            cameraId,
            CameraErrorCode.overconstrained,
            'The camera options are impossible to satisfy.',
          );
        case 'NotAllowedError':
        case 'PermissionDeniedError':
          throw CameraWebException(
            cameraId,
            CameraErrorCode.permissionDenied,
            'The camera cannot be used or the permission '
            'to access the camera is not granted.',
          );
        case 'TypeError':
          throw CameraWebException(
            cameraId,
            CameraErrorCode.type,
            'The camera options are incorrect or attempted '
            'to access the media input from an insecure context.',
          );
        case 'AbortError':
          throw CameraWebException(
            cameraId,
            CameraErrorCode.abort,
            'Some problem occurred that prevented the camera from being used.',
          );
        case 'SecurityError':
          throw CameraWebException(
            cameraId,
            CameraErrorCode.security,
            'The user media support is disabled in the current browser.',
          );
        default:
          throw CameraWebException(
            cameraId,
            CameraErrorCode.unknown,
            'An unknown error occurred when fetching the camera stream.',
          );
      }
    } catch (_) {
      throw CameraWebException(
        cameraId,
        CameraErrorCode.unknown,
        'An unknown error occurred when fetching the camera stream.',
      );
    }
  }

  /// Returns the zoom level capability for the given [camera].
  ///
  /// Throws a [CameraWebException] if the zoom level is not supported
  /// or the camera has not been initialized or started.
  ZoomLevelCapability getZoomLevelCapabilityForCamera(Camera camera) {
    final web.MediaDevices mediaDevices = window.navigator.mediaDevices;
    final web.MediaTrackSupportedConstraints supportedConstraints = mediaDevices
        .getSupportedConstraints();
    final bool zoomLevelSupported = supportedConstraints.zoomNullable ?? false;

    if (!zoomLevelSupported) {
      throw CameraWebException(
        camera.textureId,
        CameraErrorCode.zoomLevelNotSupported,
        'The zoom level is not supported in the current browser.',
      );
    }

    final List<web.MediaStreamTrack> videoTracks =
        camera.stream?.getVideoTracks().toDart ?? <web.MediaStreamTrack>[];

    if (videoTracks.isNotEmpty) {
      final web.MediaStreamTrack defaultVideoTrack = videoTracks.first;

      /// The zoom level capability is represented by MediaSettingsRange.
      /// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaSettingsRange
      final WebTweakMediaSettingsRange? zoomLevelCapability = defaultVideoTrack
          .getCapabilities()
          .zoomNullable;

      if (zoomLevelCapability != null) {
        return ZoomLevelCapability(
          minimum: zoomLevelCapability.min,
          maximum: zoomLevelCapability.max,
          videoTrack: defaultVideoTrack,
        );
      } else {
        throw CameraWebException(
          camera.textureId,
          CameraErrorCode.zoomLevelNotSupported,
          'The zoom level is not supported by the current camera.',
        );
      }
    } else {
      throw CameraWebException(
        camera.textureId,
        CameraErrorCode.notStarted,
        'The camera has not been initialized or started.',
      );
    }
  }

  /// Returns a facing mode of the [videoTrack]
  /// (null if the facing mode is not available).
  String? getFacingModeForVideoTrack(web.MediaStreamTrack videoTrack) {
    final web.MediaDevices mediaDevices = window.navigator.mediaDevices;

    // Check if the camera facing mode is supported by the current browser.
    final web.MediaTrackSupportedConstraints supportedConstraints = mediaDevices
        .getSupportedConstraints();

    // Return null if the facing mode is not supported.
    if (!supportedConstraints.facingMode) {
      return null;
    }

    // Extract the facing mode from the video track settings.
    // The property may not be available if it's not supported
    // by the browser or not available due to context.
    //
    // MediaTrackSettings:
    // https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackSettings
    final web.MediaTrackSettings videoTrackSettings = videoTrack.getSettings();
    final String? facingMode = videoTrackSettings.facingModeNullable;

    if (facingMode == null || facingMode.isEmpty) {
      // If the facing mode does not exist in the video track settings,
      // check for the facing mode in the video track capabilities.
      //
      // MediaTrackCapabilities:
      // https://www.w3.org/TR/mediacapture-streams/#dom-mediatrackcapabilities

      // Check if getting the video track capabilities is supported.
      //
      // The method may not be supported on Firefox.
      // See: https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamTrack/getCapabilities#browser_compatibility
      if (!jsUtil.hasProperty(videoTrack, 'getCapabilities'.toJS)) {
        // Return null if the video track capabilities are not supported.
        return null;
      }

      final web.MediaTrackCapabilities videoTrackCapabilities = videoTrack.getCapabilities();

      // A list of facing mode capabilities as
      //The camera may support multiple facing modes.
      // Some browsers (e.g., Firefox) do not conform to the MediaTrackCapabilities
      // spec and may return `facingMode` as a non-array value (e.g., an empty string,
      // a plain object, or a boolean) Rather than the expected DOMString sequence.
      // We use jsUtil.getProperty to safely read the raw JS value, then explicitly
      // validate it is a JSArray before accessing its elements to prevent a TypeError.

      final JSAny? facingModeCapabilities = jsUtil.getProperty(
        videoTrackCapabilities,
        'facingMode'.toJS,
      );
      if (facingModeCapabilities == null || !facingModeCapabilities.isA<JSArray>()) {
        return null;
      }

      final List<JSAny?> facingModes = (facingModeCapabilities as JSArray).toDart;

      if (facingModes.isNotEmpty && facingModes.first.isA<JSString>()) {
        return (facingModes.first! as JSString).toDart;
      }

      // Return null if there are no facing mode capabilities.
      return null;
    }

    return facingMode;
  }

  /// Maps the given [facingMode] to [CameraLensDirection].
  ///
  /// The following values for the facing mode are supported:
  /// https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackSettings/facingMode
  CameraLensDirection mapFacingModeToLensDirection(String facingMode) {
    switch (facingMode) {
      case 'user':
        return CameraLensDirection.front;
      case 'environment':
        return CameraLensDirection.back;
      case 'left':
      case 'right':
      default:
        return CameraLensDirection.external;
    }
  }

  /// Maps the given [facingMode] to [CameraType].
  ///
  /// See [CameraMetadata.facingMode] for more details.
  CameraType mapFacingModeToCameraType(String facingMode) {
    switch (facingMode) {
      case 'user':
        return CameraType.user;
      case 'environment':
        return CameraType.environment;
      case 'left':
      case 'right':
      default:
        return CameraType.user;
    }
  }

  /// Maps the given [resolutionPreset] to [Size].
  Size mapResolutionPresetToSize(ResolutionPreset resolutionPreset) {
    switch (resolutionPreset) {
      case ResolutionPreset.max:
      case ResolutionPreset.ultraHigh:
        return const Size(4096, 2160);
      case ResolutionPreset.veryHigh:
        return const Size(1920, 1080);
      case ResolutionPreset.high:
        return const Size(1280, 720);
      case ResolutionPreset.medium:
        return const Size(720, 480);
      case ResolutionPreset.low:
        return const Size(320, 240);
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return const Size(320, 240);
  }

  static const int _kiloBits = 1000;
  static const int _megaBits = _kiloBits * _kiloBits;

  /// Maps the given [resolutionPreset] to video bitrate.
  int mapResolutionPresetToVideoBitrate(ResolutionPreset resolutionPreset) {
    switch (resolutionPreset) {
      case ResolutionPreset.max:
      case ResolutionPreset.ultraHigh:
        return 8 * _megaBits;
      case ResolutionPreset.veryHigh:
        return 4 * _megaBits;
      case ResolutionPreset.high:
        return 1 * _megaBits;
      case ResolutionPreset.medium:
        return 400 * _kiloBits;
      case ResolutionPreset.low:
        return 200 * _kiloBits;
    }

    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return 1 * _megaBits;
  }

  /// Maps the given [resolutionPreset] to audio bitrate.
  int mapResolutionPresetToAudioBitrate(ResolutionPreset resolutionPreset) {
    switch (resolutionPreset) {
      case ResolutionPreset.max:
      case ResolutionPreset.ultraHigh:
        return 128 * _kiloBits;
      case ResolutionPreset.veryHigh:
        return 128 * _kiloBits;
      case ResolutionPreset.high:
        return 64 * _kiloBits;
      case ResolutionPreset.medium:
        return 48 * _kiloBits;
      case ResolutionPreset.low:
        return 32 * _kiloBits;
    }

    // The enum comes from a different package, which could get a new value at
    // any time, so provide a fallback that ensures this won't break when used
    // with a version that contains new values. This is deliberately outside
    // the switch rather than a `default` so that the linter will flag the
    // switch as needing an update.
    // ignore: dead_code
    return 64 * _kiloBits;
  }

  /// Maps the given [deviceOrientation] to [OrientationType].
  String mapDeviceOrientationToOrientationType(DeviceOrientation deviceOrientation) {
    switch (deviceOrientation) {
      case DeviceOrientation.portraitUp:
        return OrientationType.portraitPrimary;
      case DeviceOrientation.landscapeLeft:
        return OrientationType.landscapePrimary;
      case DeviceOrientation.portraitDown:
        return OrientationType.portraitSecondary;
      case DeviceOrientation.landscapeRight:
        return OrientationType.landscapeSecondary;
    }
  }

  /// Maps the given [orientationType] to [DeviceOrientation].
  DeviceOrientation mapOrientationTypeToDeviceOrientation(String orientationType) {
    switch (orientationType) {
      case OrientationType.portraitPrimary:
        return DeviceOrientation.portraitUp;
      case OrientationType.landscapePrimary:
        return DeviceOrientation.landscapeLeft;
      case OrientationType.portraitSecondary:
        return DeviceOrientation.portraitDown;
      case OrientationType.landscapeSecondary:
        return DeviceOrientation.landscapeRight;
      default:
        return DeviceOrientation.portraitUp;
    }
  }

  /// Used to check if browser has MediaStreamTrackProcessor capability
  bool hasMediaStreamTrackProcessor() {
    return jsUtil.hasProperty(window, 'MediaStreamTrackProcessor'.toJS);
  }

  /// Used to check if browser has OffscreenCanvas capability
  bool hasPropertyOffScreenCanvas() {
    return jsUtil.hasProperty(window, 'OffscreenCanvas'.toJS);
  }

  /// Returns frame at a specific time using video element
  CameraImageData takeFrame(web.VideoElement videoElement, {int cameraId = 0}) {
    final int width = videoElement.videoWidth;
    final int height = videoElement.videoHeight;
    if (width == 0 || height == 0) {
      throw CameraWebException(
        cameraId,
        CameraErrorCode.cameraFrameDimensionsZero,
        'Computed dimensions are zero: width=$width, height=$height',
      );
    }
    final imageDataSettings = WebTweakImageDataSettings(format: 'rgba-unorm8');
    final web.ImageData imageData;
    if (hasPropertyOffScreenCanvas()) {
      imageData = _takeOffscreenCanvasFrame(
        videoElement,
        width: width,
        height: height,
        settings: imageDataSettings,
      );
    } else {
      imageData = _takeFallbackCanvasFrame(
        videoElement,
        width: width,
        height: height,
        settings: imageDataSettings,
      );
    }
    final ByteBuffer byteBuffer = imageData.data.toDart.buffer;

    return getCameraImageData(bytes: byteBuffer.asUint8List(), width: width, height: height);
  }

  /// Used by [_takeOffscreenCanvasFrame] to cache the offscreen canvas
  web.OffscreenCanvas? _offscreenCanvas;

  /// Used by [_takeOffscreenCanvasFrame] to cache the offscreen canvas context
  web.OffscreenCanvasRenderingContext2D? _offscreenCanvasContext;

  /// Takes a video frame using `OffscreenCanvas` for better performance
  web.ImageData _takeOffscreenCanvasFrame(
    web.VideoElement videoElement, {
    required int width,
    required int height,
    required WebTweakImageDataSettings settings,
  }) {
    _offscreenCanvas ??= web.OffscreenCanvas(width, height);
    if (_offscreenCanvas!.width != width || _offscreenCanvas!.height != height) {
      _offscreenCanvas!
        ..width = width
        ..height = height;
    }
    _offscreenCanvasContext ??=
        _offscreenCanvas!.getContext('2d', <String, Object?>{'willReadFrequently': true}.jsify())!
            as web.OffscreenCanvasRenderingContext2D;

    _offscreenCanvasContext!.drawImage(videoElement, 0, 0);
    return _offscreenCanvasContext!.getImageData(0, 0, width, height, settings);
  }

  /// Used by [_takeFallbackCanvasFrame] to cache the canvas element
  web.CanvasElement? _canvasElement;

  /// Takes a video frame using a regular `CanvasElement`
  web.ImageData _takeFallbackCanvasFrame(
    web.VideoElement videoElement, {
    required int width,
    required int height,
    required WebTweakImageDataSettings settings,
  }) {
    _canvasElement ??= web.CanvasElement()
      ..height = height
      ..width = width;
    if (_canvasElement!.width != width || _canvasElement!.height != height) {
      _canvasElement!
        ..width = width
        ..height = height;
    }
    final web.CanvasRenderingContext2D context = _canvasElement!.context2D;

    context.drawImageScaled(videoElement, 0, 0, width.toDouble(), height.toDouble());
    return context.getImageData(0, 0, width, height, settings);
  }

  /// Returns the first video track from the given [mediaStream].
  ///
  /// Throws a [CameraWebException] if the media stream is null or no video tracks are found.
  web.MediaStreamTrack getMediaStreamVideoTrack(web.MediaStream mediaStream, {int cameraId = 0}) {
    final List<web.MediaStreamTrack> tracks = mediaStream.getVideoTracks().toDart;
    if (tracks.isEmpty) {
      throw CameraWebException(
        cameraId,
        CameraErrorCode.noVideoTrack,
        'No video track found in the media stream.',
      );
    }
    return tracks.first;
  }

  /// Creates a [web.ReadableStreamDefaultReader] from a [web.MediaStreamTrack].
  web.ReadableStreamDefaultReader getMediaStreamTrackReader(
    web.MediaStreamTrack track, {
    int maxBufferSize = 1,
  }) {
    final options = web.MediaStreamTrackProcessorInit(track: track, maxBufferSize: maxBufferSize);
    final processor = web.MediaStreamTrackProcessor(options);
    return processor.readable.getReader() as web.ReadableStreamDefaultReader;
  }

  /// Reads a video frame from the given [reader].
  Future<web.VideoFrame> readVideoTrack(
    web.ReadableStreamDefaultReader reader, {
    int cameraId = 0,
  }) async {
    final web.ReadableStreamReadResult readResult = await reader.read().toDart;
    if (readResult.done) {
      throw CameraWebException(
        cameraId,
        CameraErrorCode.videoTrackReaderClosed,
        'The track reader has been closed.',
      );
    }
    final videoFrame = readResult.value as web.VideoFrame?;
    if (videoFrame == null || videoFrame.visibleRect == null) {
      throw CameraWebException(
        cameraId,
        CameraErrorCode.videoTrackReaderNotInitialized,
        'Failed to read a video frame from the track reader.',
      );
    }
    return videoFrame;
  }

  /// Converts a [web.VideoFrame] into a [CameraImageData], reusing previously
  /// allocated buffers when possible.
  CameraImageData getCameraImageData({
    required int width,
    required int height,
    required Uint8List bytes,
  }) {
    final plane = CameraImagePlane(
      bytes: bytes,
      bytesPerRow: width * 4,
      bytesPerPixel: 4,
      width: width,
      height: height,
    );

    // TODO(TecHaxter): Introduce ImageFormatGroup.rgba8888 in
    //                  package:camera_platform_interface.
    //                  https://github.com/flutter/flutter/issues/151193
    const format = CameraImageFormat(ImageFormatGroup.unknown, raw: 'rgba8888');

    return CameraImageData(width: width, height: height, format: format, planes: [plane]);
  }
}
