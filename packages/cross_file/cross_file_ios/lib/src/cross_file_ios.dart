// Platform Implementation for Android
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'ios_cross_file.dart';

final class CrossFileIOS extends CrossFilePlatform {
  static void registerWith() {
    CrossFilePlatform.instance = CrossFileIOS();
  }

  @override
  IOSXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return IOSXFile(
      PlatformSharedStorageXFileCreationParams(path: params.path),
    );
  }

  @override
  PlatformSharedStorageXFile createPlatformSharedStorageXFile(
    PlatformSharedStorageXFileCreationParams params,
  ) {
    return IOSXFile(params);
  }
}
