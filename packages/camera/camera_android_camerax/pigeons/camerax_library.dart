// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/camerax_library.g.dart',
    dartTestOut: 'test/test_camerax_library.g.dart',
    dartOptions: DartOptions(copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
    javaOut:
        'android/src/main/java/io/flutter/plugins/camerax/GeneratedCameraXLibrary.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.camerax',
      className: 'GeneratedCameraXLibrary',
      copyrightHeader: <String>[
        'Copyright 2013 The Flutter Authors. All rights reserved.',
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
    ),
  ),
)
class ResolutionInfo {
  ResolutionInfo({
    required this.width,
    required this.height,
  });

  int width;
  int height;
}

class CameraPermissionsErrorData {
  CameraPermissionsErrorData({
    required this.errorCode,
    required this.description,
  });

  String errorCode;
  String description;
}

class ImagePlaneInformation {
  ImagePlaneInformation({
    required this.bytes,
    required this.bytesPerRow,
    required this.bytesPerPixel,
  });

  Uint8List bytes;
  int bytesPerRow;
  int bytesPerPixel;
}

class ImageInformation {
  ImageInformation({
    required this.format,
    required this.imagePlanesInformation,
    required this.height,
    required this.width,
  });

  int format;
  List<ImagePlaneInformation?> imagePlanesInformation;
  int height;
  int width;
}

@HostApi(dartHostTestHandler: 'TestInstanceManagerHostApi')
abstract class InstanceManagerHostApi {
  /// Clear the native `InstanceManager`.
  ///
  /// This is typically only used after a hot restart.
  void clear();
}

@HostApi(dartHostTestHandler: 'TestJavaObjectHostApi')
abstract class JavaObjectHostApi {
  void dispose(int identifier);
}

@FlutterApi()
abstract class JavaObjectFlutterApi {
  void dispose(int identifier);
}

@HostApi(dartHostTestHandler: 'TestCameraInfoHostApi')
abstract class CameraInfoHostApi {
  int getSensorRotationDegrees(int identifier);
}

@FlutterApi()
abstract class CameraInfoFlutterApi {
  void create(int identifier);
}

@HostApi(dartHostTestHandler: 'TestCameraSelectorHostApi')
abstract class CameraSelectorHostApi {
  void create(int identifier, int? lensFacing);

  List<int> filter(int identifier, List<int> cameraInfoIds);
}

@FlutterApi()
abstract class CameraSelectorFlutterApi {
  void create(int identifier, int? lensFacing);
}

@HostApi(dartHostTestHandler: 'TestProcessCameraProviderHostApi')
abstract class ProcessCameraProviderHostApi {
  @async
  int getInstance();

  List<int> getAvailableCameraInfos(int identifier);

  int bindToLifecycle(
      int identifier, int cameraSelectorIdentifier, List<int> useCaseIds);

  bool isBound(int identifier, int useCaseIdentifier);

  void unbind(int identifier, List<int> useCaseIds);

  void unbindAll(int identifier);
}

@FlutterApi()
abstract class ProcessCameraProviderFlutterApi {
  void create(int identifier);
}

@FlutterApi()
abstract class CameraFlutterApi {
  void create(int identifier);
}

@HostApi(dartHostTestHandler: 'TestSystemServicesHostApi')
abstract class SystemServicesHostApi {
  @async
  CameraPermissionsErrorData? requestCameraPermissions(bool enableAudio);

  void startListeningForDeviceOrientationChange(
      bool isFrontFacing, int sensorOrientation);

  void stopListeningForDeviceOrientationChange();
}

@FlutterApi()
abstract class SystemServicesFlutterApi {
  void onDeviceOrientationChanged(String orientation);

  void onCameraError(String errorDescription);
}

@HostApi(dartHostTestHandler: 'TestPreviewHostApi')
abstract class PreviewHostApi {
  void create(int identifier, int? rotation, ResolutionInfo? targetResolution);

  int setSurfaceProvider(int identifier);

  void releaseFlutterSurfaceTexture();

  ResolutionInfo getResolutionInfo(int identifier);
}

@HostApi(dartHostTestHandler: 'TestImageCaptureHostApi')
abstract class ImageCaptureHostApi {
  void create(int identifier, int? flashMode, ResolutionInfo? targetResolution);

  void setFlashMode(int identifier, int flashMode);

  @async
  String takePicture(int identifier);
}

// @HostApi(dartHostTestHandler: 'TestImageAnalysisHostApi')
// abstract class ImageAnalysisHostApi {
//   void create(int identifier, ResolutionInfo? targetResolution);

//   void setAnalyzer(int identifier);

//   void clearAnalyzer(int identifier);
// }

// @FlutterApi()
// abstract class ImageAnalysisFlutterApi {
//   void onImageAnalyzed(ImageInformation imageInformation);
// }

@HostApi(dartHostTestHandler: 'TestImageAnalysisAnalyzerHostApi')
abstract class ImageAnalysisAnalyzerHostApi {
  void create(int identifier);

}

@FlutterApi()
abstract class ImageAnalysisAnalyzerFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.

  void create(
    int identifier,

  );

  /// Callback to Dart function `ImageAnalysisAnalyzer.analyze`.

  void analyze(
    int identifier,
    int imageProxyIdentifier,

  );
}

@HostApi(dartHostTestHandler: 'TestImageProxyHostApi')
abstract class ImageProxyHostApi {

  /// Handles Dart method `ImageProxy.getPlanes`.

  List getPlanes(
     int identifier,

  );

  /// Handles Dart method `ImageProxy.getFormat`.

  int getFormat(
     int identifier,

  );

  /// Handles Dart method `ImageProxy.getHeight`.

  int getHeight(
     int identifier,

  );

  /// Handles Dart method `ImageProxy.getWidth`.

  int getWidth(
     int identifier,

  );

  /// Handles Dart method `ImageProxy.close`.

  void close(
     int identifier,

  );

}

@FlutterApi()
abstract class ImageProxyFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.

  void create(
    int identifier,

  );

}

@HostApi(dartHostTestHandler: 'TestImageAnalysisHostApi')
abstract class ImageAnalysisHostApi {

  /// Create a new native instance and add it to the `InstanceManager`.

  void create(
    int identifier,

    int? targetResolutionIdentifier,

  );

  // /// Handles attaching `ImageAnalysis.onStreamedFrameAvailableStreamController` to a native instance.

  // void attachOnStreamedFrameAvailableStreamController(

  //   int onStreamedFrameAvailableStreamControllerIdentifier,
  // );

  /// Handles Dart method `ImageAnalysis.setAnalyzer`.

  void setAnalyzer(
     int identifier,

    int analyzerIdentifier,

  );

  /// Handles Dart method `ImageAnalysis.clearAnalyzer`.

  void clearAnalyzer(
     int identifier,

  );

}

@HostApi(dartHostTestHandler: 'TestImageProxyPlaneProxyHostApi')
abstract class ImageProxyPlaneProxyHostApi {

  /// Handles Dart method `ImageProxyPlaneProxy.getPixelStride`.

  int getPixelStride(
     int identifier,

  );

  /// Handles Dart method `ImageProxyPlaneProxy.getRowStride`.

  Uint8List getBuffer(
     int identifier,

  );

  /// Handles Dart method `ImageProxyPlaneProxy.getRowStride`.

  int  getRowStride(
     int identifier,

  );
}

@FlutterApi()
abstract class ImageProxyPlaneProxyFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.

  void create(
    int identifier,

  );

}
