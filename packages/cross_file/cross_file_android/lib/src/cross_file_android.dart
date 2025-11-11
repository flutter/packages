// Platform Implementation for Android
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

final class XFileAndroid extends XFilePlatform {
  static void registerWith() {
    XFilePlatform.instance = XFileAndroid();
  }

  @override
  PlatformXFile createPlatformXFile(String path) {
    // TODO: implement createPlatformXFile
    throw UnimplementedError();
  }
}