
import 'camera_linux_platform_interface.dart';

class CameraLinux {
  Future<String?> getPlatformVersion() {
    return CameraLinuxPlatform.instance.getPlatformVersion();
  }
}
