import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOptions: JavaOptions(package: 'io.flutter.plugins.camera'),
  javaOut: 'android/src/main/java/io/flutter/plugins/camera/Messages.java',
  copyrightHeader: 'pigeons/copyright.txt',
))

enum PlatformCameraLensDirection {
  front,
  back,
  external,
}

class PlatformCameraDescription {
  PlatformCameraDescription({required this.name, required this.lensDirection, required this.sensorOrientation});
  final String name;
  final PlatformCameraLensDirection lensDirection;
  final int sensorOrientation;
}

@HostApi()
abstract class CameraApi {
  List<PlatformCameraDescription> getAvailableCameras();
}
