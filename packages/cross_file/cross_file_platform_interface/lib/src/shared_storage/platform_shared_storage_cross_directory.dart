import 'package:flutter/foundation.dart';

import '../../cross_file_platform_interface.dart';

@immutable
base class PlatformSharedStorageXDirectoryCreationParams
    extends PlatformXDirectoryCreationParams {
  const PlatformSharedStorageXDirectoryCreationParams({required super.path});
}

mixin SharedStoragePlatformXDirectoryExtension
    implements PlatformXDirectoryExtension {}

abstract base class PlatformSharedStorageXDirectory extends PlatformXDirectory {
  PlatformSharedStorageXDirectory(
    PlatformSharedStorageXDirectoryCreationParams params,
  ) : super.implementation(params);

  @override
  PlatformSharedStorageXDirectoryCreationParams get params =>
      super.params as PlatformSharedStorageXDirectoryCreationParams;

  @override
  SharedStoragePlatformXDirectoryExtension? get extension =>
      super.extension as SharedStoragePlatformXDirectoryExtension?;

  Future<void> listFiles(ListFileParams params);
}

class ListFileParams {

}
