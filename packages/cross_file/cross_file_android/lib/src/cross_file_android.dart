// Platform Implementation for Android
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import '../cross_file_android.dart';

final class CrossFileAndroid extends CrossFilePlatform {
  static void registerWith() {
    CrossFilePlatform.instance = CrossFileAndroid();
  }

  @override
  AndroidXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return AndroidXFile(params);
  }
}
