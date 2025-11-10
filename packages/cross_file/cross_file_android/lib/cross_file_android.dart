
import 'cross_file_android_platform_interface.dart';

class CrossFileAndroid {
  Future<String?> getPlatformVersion() {
    return CrossFileAndroidPlatform.instance.getPlatformVersion();
  }
}
