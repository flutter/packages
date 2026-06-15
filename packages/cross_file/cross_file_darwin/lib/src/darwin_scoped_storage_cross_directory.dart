// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:objective_c/objective_c.dart';

import 'darwin_scoped_storage_cross_file.dart';
import 'ffi_bindings.g.dart';
import 'security_scoped_resource.dart';

/// Implementation of [PlatformScopedStorageXDirectoryCreationParams] for iOS
/// and macOS.
@immutable
sealed class DarwinScopedStorageXDirectoryCreationParams
    extends PlatformScopedStorageXDirectoryCreationParams {
  /// Constructs a [DarwinScopedStorageXDirectoryCreationParams].
  const DarwinScopedStorageXDirectoryCreationParams({required super.uri});

  /// Constructs a [DarwinScopedStorageXDirectoryCreationParams] with a security
  /// scoped uri.
  factory DarwinScopedStorageXDirectoryCreationParams.securityScoped({required String uri}) =>
      SecurityScopedDarwinScopedStorageXDirectoryCreationParams(uri: uri);
}

/// Creation parameters for [SecurityScopedDarwinScopedStorageXDirectory].
@immutable
base class SecurityScopedDarwinScopedStorageXDirectoryCreationParams
    extends DarwinScopedStorageXDirectoryCreationParams {
  /// Constructs a [SecurityScopedDarwinScopedStorageXDirectoryCreationParams].
  const SecurityScopedDarwinScopedStorageXDirectoryCreationParams({required super.uri});
}

/// Base implementation of [PlatformScopedStorageXDirectory] for iOS and macOS.
sealed class DarwinScopedStorageXDirectory extends PlatformScopedStorageXDirectory {
  factory DarwinScopedStorageXDirectory(PlatformScopedStorageXDirectoryCreationParams params) {
    return SecurityScopedDarwinScopedStorageXDirectory(params);
  }

  @protected
  DarwinScopedStorageXDirectory._(super.params) : super.implementation();
}

/// Implementation of [DarwinScopedStorageXDirectory] for interacting with a
/// security-scoped URL.
base class SecurityScopedDarwinScopedStorageXDirectory extends DarwinScopedStorageXDirectory
    with SecurityScopedDarwinScopedStorageXDirectoryExtension {
  /// Constructs a [SecurityScopedDarwinScopedStorageXDirectory].
  SecurityScopedDarwinScopedStorageXDirectory(super.params) : super._() {
    _finalizer.attach(this, params.uri);
  }

  static final Finalizer<String> _finalizer = Finalizer((String uri) {
    // Check that this is not called during a unit test.
    if (Platform.environment['FLUTTER_TEST'] != 'true') {
      final NSURL? url = NSURL.URLWithString(NSString(uri));
      if (url != null) {
        url.stopAccessingSecurityScopedResource();
      }
    }
  });

  late final _directory = Directory.fromUri(Uri.parse(params.uri));

  @override
  late final SecurityScopedDarwinScopedStorageXDirectoryCreationParams params =
      super.params is SecurityScopedDarwinScopedStorageXDirectoryCreationParams
      ? super.params as SecurityScopedDarwinScopedStorageXDirectoryCreationParams
      : SecurityScopedDarwinScopedStorageXDirectoryCreationParams(uri: super.params.uri);

  @override
  SecurityScopedDarwinScopedStorageXDirectoryExtension? get extension => this;

  @override
  Future<bool> exists() async => _directory.existsSync();

  @override
  Stream<PlatformXEntity> list(ListParams params) async* {
    await for (final FileSystemEntity entity in _directory.list()) {
      switch (entity) {
        case final Directory directory:
          yield DarwinScopedStorageXDirectory(
            DarwinScopedStorageXDirectoryCreationParams.securityScoped(
              uri: directory.uri.toString(),
            ),
          );
        case final File file:
          yield DarwinScopedStorageXFile(
            DarwinScopedStorageXFileCreationParams.securityScoped(uri: file.uri.toString()),
          );
      }
    }
  }

  @override
  Future<bool> canRead() async {
    return NSFileManager.getDefaultManager().isReadableFileAtPath(
      NSString(Uri.file(params.uri).path),
    );
  }

  @override
  Future<bool> startAccessingSecurityScopedResource() async {
    final NSURL? url = NSURL.URLWithString(NSString(params.uri));
    if (url == null) {
      return false;
    }
    return url.startAccessingSecurityScopedResource();
  }

  @override
  Future<void> stopAccessingSecurityScopedResource() async {
    final NSURL? url = NSURL.URLWithString(NSString(params.uri));
    if (url != null) {
      url.stopAccessingSecurityScopedResource();
    }
  }
}

/// Provides platform specific features for
/// [SecurityScopedDarwinScopedStorageXDirectory].
mixin SecurityScopedDarwinScopedStorageXDirectoryExtension
    implements PlatformScopedStorageXDirectoryExtension, SecurityScopedResource {}
