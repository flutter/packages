import 'package:flutter/foundation.dart';

import '../../cross_file_platform_interface.dart';

@immutable
base class PlatformSharedStorageXFileCreationParams
    extends PlatformXFileCreationParams {
  const PlatformSharedStorageXFileCreationParams({required super.path});
}

mixin SharedStoragePlatformXFileExtension implements PlatformXFileExtension {}

abstract base class PlatformSharedStorageXFile extends PlatformXFile {
  /// Creates a new [PlatformSharedStorageXFile]
  factory PlatformSharedStorageXFile(
    PlatformSharedStorageXFileCreationParams params,
  ) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `XFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    final PlatformSharedStorageXFile file = CrossFilePlatform.instance!
        .createPlatformSharedStorageXFile(params);
    return file;
  }

  @protected
  PlatformSharedStorageXFile.implementation(super.params)
    : super.implementation();

  @override
  PlatformSharedStorageXFileCreationParams get params =>
      super.params as PlatformSharedStorageXFileCreationParams;

  @override
  SharedStoragePlatformXFileExtension? get extension =>
      super.extension as SharedStoragePlatformXFileExtension?;

  Future<void> delete();
}
