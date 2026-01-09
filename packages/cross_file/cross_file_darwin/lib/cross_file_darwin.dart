
import 'cross_file_darwin_platform_interface.dart';

class CrossFileDarwin {
  Future<String?> getPlatformVersion() {
    return CrossFileDarwinPlatform.instance.getPlatformVersion();
  }
}
