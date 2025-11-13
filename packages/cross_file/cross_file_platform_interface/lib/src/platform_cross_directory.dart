import 'package:flutter/foundation.dart';

import 'cross_file_platform.dart';

@immutable
base class PlatformXDirectoryCreationParams {
  const PlatformXDirectoryCreationParams({required this.path});

  final String path;
}

mixin PlatformXDirectoryExtension {}

abstract base class PlatformXDirectory {
  /// Creates a new [PlatformXDirectory]
  factory PlatformXDirectory(PlatformXDirectoryCreationParams params) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    final PlatformXDirectory file = CrossFilePlatform.instance!
        .createPlatformXDirectory(params);
    return file;
  }

  @protected
  PlatformXDirectory.implementation(this.params);

  final PlatformXDirectoryCreationParams params;

  PlatformXDirectoryExtension? get extension => null;

  Future<bool> exists();
}
