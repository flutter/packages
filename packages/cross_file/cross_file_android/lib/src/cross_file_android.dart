// Platform Implementation for Android
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'android_cross_file.dart';

final class CrossFileAndroid extends CrossFilePlatform {
  static void registerWith() {
    CrossFilePlatform.instance = CrossFileAndroid();
  }

  @override
  AndroidXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return createPlatformSharedStorageXFile(
      PlatformSharedStorageXFileCreationParams(path: params.path),
    );
  }

  @override
  AndroidXFile createPlatformSharedStorageXFile(
    PlatformSharedStorageXFileCreationParams params,
  ) {
    return AndroidXFile(params);
  }
}
