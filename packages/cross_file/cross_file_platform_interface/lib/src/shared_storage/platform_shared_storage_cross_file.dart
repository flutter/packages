import 'package:flutter/foundation.dart';

import '../../cross_file_platform_interface.dart';

@immutable
base class PlatformSharedStorageXFileCreationParams
    extends PlatformXFileCreationParams {
  const PlatformSharedStorageXFileCreationParams({required super.path});
}

mixin SharedStoragePlatformXFileExtension implements PlatformXFileExtension {}

abstract base class PlatformSharedStorageXFile extends PlatformXFile {
  PlatformSharedStorageXFile(PlatformSharedStorageXFileCreationParams params)
    : super.implementation(params);

  @override
  PlatformSharedStorageXFileCreationParams get params =>
      super.params as PlatformSharedStorageXFileCreationParams;

  @override
  SharedStoragePlatformXFileExtension? get extension =>
      super.extension as SharedStoragePlatformXFileExtension?;

  Future<void> delete();
}
