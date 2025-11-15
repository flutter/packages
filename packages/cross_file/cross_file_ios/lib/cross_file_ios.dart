
import 'cross_file_ios_platform_interface.dart';

class CrossFileIos {
  Future<String?> getPlatformVersion() {
    return CrossFileIosPlatform.instance.getPlatformVersion();
  }
}
