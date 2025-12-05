
// Platform Implementation for Android
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'io_cross_file.dart';

final class CrossFileIO extends CrossFilePlatform {
  static void registerWith() {
    CrossFilePlatform.instance = CrossFileIO();
  }

  @override
  IOXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return IOXFile(params);
  }
}
