
import 'cross_file_web_platform_interface.dart';

class CrossFileWeb {
  Future<String?> getPlatformVersion() {
    return CrossFileWebPlatform.instance.getPlatformVersion();
  }
}
