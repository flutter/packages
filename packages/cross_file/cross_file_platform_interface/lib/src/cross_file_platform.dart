import 'platform_cross_directory.dart';
import 'platform_cross_file.dart';
import 'shared_storage/platform_shared_storage_cross_file.dart';

abstract base class CrossFilePlatform {
  static CrossFilePlatform? instance;

  PlatformXFile createPlatformXFile(PlatformXFileCreationParams params);

  PlatformSharedStorageXFile createPlatformSharedStorageXFile(
    PlatformSharedStorageXFileCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformSharedStorageXFile is not implemented on the current platform.',
    );
  }

  PlatformXDirectory createPlatformXDirectory(
    PlatformXDirectoryCreationParams params,
  ) {
    throw UnimplementedError(
      'createPlatformXDirectory is not implemented on the current platform.',
    );
  }
}
