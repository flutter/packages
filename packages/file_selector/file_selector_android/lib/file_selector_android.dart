
import 'file_selector_android_platform_interface.dart';

class FileSelectorAndroid {
  Future<String?> getPlatformVersion() {
    return FileSelectorAndroidPlatform.instance.getPlatformVersion();
  }
}
