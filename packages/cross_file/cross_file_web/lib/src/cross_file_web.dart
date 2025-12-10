import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'web_cross_file.dart';

base class CrossFileWeb extends CrossFilePlatform {
  static void registerWith() {
    CrossFilePlatform.instance = CrossFileWeb();
  }

  @override
  WebXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return WebXFile(params);
  }
}
