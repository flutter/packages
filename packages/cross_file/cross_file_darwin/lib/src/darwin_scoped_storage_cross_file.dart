// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:objective_c/objective_c.dart';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'cross_file_darwin_apis.g.dart';
import 'security_scoped_resource.dart';

import 'ffi_bindings.g.dart';

/// Base implementation of [PlatformScopedStorageXFileCreationParams] for iOS
/// and macOS.
sealed class DarwinScopedStorageXFileCreationParams
    extends PlatformScopedStorageXFileCreationParams {
  /// Constructs a [DarwinScopedStorageXFileCreationParams].
  const DarwinScopedStorageXFileCreationParams({required super.uri});

  /// Constructs a [DarwinScopedStorageXFileCreationParams] with a security
  /// scoped uri.
  factory DarwinScopedStorageXFileCreationParams.securityScoped({
    required String uri,
  }) =>
      SecurityScopedDarwinScopedStorageXFileCreationParams(uri: uri);

  /// Constructs a [DarwinScopedStorageXFileCreationParams] with an asset
  /// identifier from the Photos Library.
  factory DarwinScopedStorageXFileCreationParams.photoKit({
    required String localIdentifier,
  }) => PhotoKitDarwinScopedStorageXFileCreationParams(
    localIdentifier: localIdentifier,
  );
}

/// Creation parameters for [SecurityScopedDarwinScopedStorageXFile].
@immutable
base class SecurityScopedDarwinScopedStorageXFileCreationParams
    extends DarwinScopedStorageXFileCreationParams {
  /// Constructs a [SecurityScopedDarwinScopedStorageXFileCreationParams].
  const SecurityScopedDarwinScopedStorageXFileCreationParams({
    required super.uri,
  });
}

/// Creation parameters for [PhotoKitDarwinScopedStorageXFile].
@immutable
base class PhotoKitDarwinScopedStorageXFileCreationParams
    extends DarwinScopedStorageXFileCreationParams {
  /// Constructs a [PhotoKitDarwinScopedStorageXFileCreationParams].
  PhotoKitDarwinScopedStorageXFileCreationParams({
    required String localIdentifier,
  }) : super(uri: localIdentifier);
}

/// Base implementation of [PlatformScopedStorageXFile] for iOS and macOS.
sealed class DarwinScopedStorageXFile extends PlatformScopedStorageXFile {
  factory DarwinScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    return switch (params) {
      final SecurityScopedDarwinScopedStorageXFileCreationParams
      securityScopedParams =>
        SecurityScopedDarwinScopedStorageXFile(securityScopedParams),
      final PhotoKitDarwinScopedStorageXFileCreationParams photoKitParams =>
        PhotoKitDarwinScopedStorageXFile(photoKitParams),
      _ => SecurityScopedDarwinScopedStorageXFile(params),
    };
  }

  @protected
  DarwinScopedStorageXFile._(super.params) : super.implementation();
}

/// Implementation of [DarwinScopedStorageXFile] for interacting with a
/// security-scoped URL.
base class SecurityScopedDarwinScopedStorageXFile
    extends DarwinScopedStorageXFile
    with SecurityScopedDarwinScopedStorageXFileExtension {
  /// Constructs a [SecurityScopedDarwinScopedStorageXFile].
  SecurityScopedDarwinScopedStorageXFile(super.params) : super._() {
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

  late final _file = File.fromUri(Uri.parse(params.uri));

  @override
  late final SecurityScopedDarwinScopedStorageXFileCreationParams params =
      super.params is SecurityScopedDarwinScopedStorageXFileCreationParams
      ? super.params as SecurityScopedDarwinScopedStorageXFileCreationParams
      : SecurityScopedDarwinScopedStorageXFileCreationParams(
          uri: super.params.uri,
        );

  @override
  SecurityScopedDarwinScopedStorageXFileExtension? get extension => this;

  @override
  Future<DateTime?> lastModified() async {
    try {
      return _file.lastModifiedSync();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<int?> length() async {
    try {
      return _file.length();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) =>
      _file.openRead(start, end).cast();

  @override
  Future<Uint8List> readAsBytes() => _file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      _file.readAsString(encoding: encoding);

  @override
  Future<bool> canRead() async {
    return NSFileManager.getDefaultManager().isReadableFileAtPath(
      NSString(Uri.file(params.uri).path),
    );
  }

  @override
  Future<bool> exists() async => _file.existsSync();

  @override
  Future<String?> name() async => path.basename(_file.path);

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

/// Implementation of [DarwinScopedStorageXFile] as a representation of a
/// image, video, or Live Photo in the Photos library.
base class PhotoKitDarwinScopedStorageXFile extends DarwinScopedStorageXFile
    with PhotoKitDarwinScopedStorageXFileExtension {
  /// Constructs a [SecurityScopedDarwinScopedStorageXFile].
  PhotoKitDarwinScopedStorageXFile(super.params) : super._();

  @override
  late final PhotoKitDarwinScopedStorageXFileCreationParams params =
      super.params is PhotoKitDarwinScopedStorageXFileCreationParams
      ? super.params as PhotoKitDarwinScopedStorageXFileCreationParams
      : PhotoKitDarwinScopedStorageXFileCreationParams(
          localIdentifier: super.params.uri,
        );

  @override
  PhotoKitDarwinScopedStorageXFileExtension? get extension => this;

  @override
  Future<DateTime?> lastModified() async {
    throw UnsupportedError('');
  }

  @override
  Future<int?> length() async {
    try {
      throw UnsupportedError('');
    } on FileSystemException {
      return null;
    }
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) =>
      throw UnsupportedError('');

  @override
  Future<Uint8List> readAsBytes() => throw UnsupportedError('');

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      throw UnsupportedError('');

  @override
  Future<bool> canRead() {
    throw UnsupportedError('');
  }

  @override
  Future<bool> exists() async => throw UnsupportedError('');

  @override
  Future<String?> name() async => throw UnsupportedError('');
}

/// Provides platform specific features for
/// [SecurityScopedDarwinScopedStorageXFile].
mixin SecurityScopedDarwinScopedStorageXFileExtension
    implements PlatformScopedStorageXFileExtension, SecurityScopedResource {}

/// Provides platform specific features for
/// [PhotoKitDarwinScopedStorageXFile].
mixin PhotoKitDarwinScopedStorageXFileExtension
    implements PlatformScopedStorageXFileExtension {}
