import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show immutable;

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'cross_file.dart';

@immutable
class SharedStorageXFile extends XFile<SharedStoragePlatformXFileExtension> {
  SharedStorageXFile(String path)
    : this.fromPlatformCreationParams(
        PlatformSharedStorageXFileCreationParams(path: path),
      );

  SharedStorageXFile.fromPlatformCreationParams(
    PlatformSharedStorageXFileCreationParams params,
  ) : this.fromPlatform(PlatformSharedStorageXFile(params));

  SharedStorageXFile.fromPlatform(this.platform) : super.fromPlatform(platform);

  @override
  final PlatformSharedStorageXFile platform;

  Future<void> delete() => platform.delete();
}
