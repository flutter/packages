import 'package:camera_linux/src/messages.g.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CameraLinux extends CameraPlatform {
  final CameraApi _hostApi;

  CameraLinux({@visibleForTesting CameraApi? api}) : _hostApi = api ?? CameraApi();

  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith() {
    print("registerWith");
    CameraPlatform.instance = CameraLinux();
  }

  @override
  Future<List<CameraDescription>> availableCameras() async {
    try {
      print("availableCameras");
      return []; //(await _hostApi.getAvailableCameras()).map(cameraDescriptionFromPlatform).toList();
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }
}
