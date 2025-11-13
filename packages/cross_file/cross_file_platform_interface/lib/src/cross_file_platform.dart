import 'platform_cross_directory.dart';
import 'platform_cross_file.dart';

abstract base class CrossFilePlatform {
  static CrossFilePlatform? instance;

  PlatformXFile createPlatformXFile(PlatformXFileCreationParams params);

  PlatformXDirectory createPlatformXDirectory(
    PlatformXDirectoryCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformXDirectory is not implemented on the current platform.',
    );
  }
}
