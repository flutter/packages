// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;

import 'ffi_bindings.g.dart';
import 'security_scoped_resource.dart';

/// Base implementation of [PlatformScopedStorageXFileCreationParams] for iOS
/// and macOS.
sealed class DarwinScopedStorageXFileCreationParams
    extends PlatformScopedStorageXFileCreationParams {
  /// Constructs a [DarwinScopedStorageXFileCreationParams].
  const DarwinScopedStorageXFileCreationParams({required super.uri});

  /// Constructs a [DarwinScopedStorageXFileCreationParams] with a security
  /// scoped uri.
  factory DarwinScopedStorageXFileCreationParams.securityScoped({required String uri}) =>
      SecurityScopedDarwinScopedStorageXFileCreationParams(uri: uri);

  /// Constructs a [DarwinScopedStorageXFileCreationParams] with an asset
  /// identifier from the Photos Library.
  factory DarwinScopedStorageXFileCreationParams.photoKit({required String localIdentifier}) =>
      PhotoKitDarwinScopedStorageXFileCreationParams(localIdentifier: localIdentifier);
}

/// Creation parameters for [SecurityScopedDarwinScopedStorageXFile].
@immutable
base class SecurityScopedDarwinScopedStorageXFileCreationParams
    extends DarwinScopedStorageXFileCreationParams {
  /// Constructs a [SecurityScopedDarwinScopedStorageXFileCreationParams].
  const SecurityScopedDarwinScopedStorageXFileCreationParams({required super.uri});
}

/// Creation parameters for [PhotoKitDarwinScopedStorageXFile].
@immutable
base class PhotoKitDarwinScopedStorageXFileCreationParams
    extends DarwinScopedStorageXFileCreationParams {
  /// Constructs a [PhotoKitDarwinScopedStorageXFileCreationParams].
  const PhotoKitDarwinScopedStorageXFileCreationParams({required String localIdentifier})
    : super(uri: localIdentifier);
}

/// Base implementation of [PlatformScopedStorageXFile] for iOS and macOS.
sealed class DarwinScopedStorageXFile extends PlatformScopedStorageXFile {
  factory DarwinScopedStorageXFile(PlatformScopedStorageXFileCreationParams params) {
    return switch (params) {
      final SecurityScopedDarwinScopedStorageXFileCreationParams securityScopedParams =>
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
base class SecurityScopedDarwinScopedStorageXFile extends DarwinScopedStorageXFile
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
      : SecurityScopedDarwinScopedStorageXFileCreationParams(uri: super.params.uri);

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
      return _file.lengthSync();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) => _file.openRead(start, end).cast();

  @override
  Future<Uint8List> readAsBytes() => _file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) => _file.readAsString(encoding: encoding);

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
      : PhotoKitDarwinScopedStorageXFileCreationParams(localIdentifier: super.params.uri);

  @override
  PhotoKitDarwinScopedStorageXFileExtension? get extension => this;

  @override
  Future<DateTime?> lastModified() async {
    if (_tryGetAsset(identifier: params.uri) case final PHAsset asset) {
      final NSDate? date = asset.modificationDate;
      if (date != null) {
        DateTime.fromMillisecondsSinceEpoch((date.timeIntervalSince1970 * 1000).round());
      }
    }

    return null;
  }

  @override
  Future<int?> length() async {
    if (_tryGetAsset(identifier: params.uri) case final PHAsset asset) {
      final NSArray resources = PHAssetResource.assetResourcesForAsset(asset);
      final ObjCObject? firstObject = resources.firstObject;

      if (firstObject != null) {
        final resource = PHAssetResource.as(firstObject);
        final ObjCObject? fileSize = resource.valueForKey(NSString('fileSize'));
        print('here');
        if (fileSize != null) {
          final Pointer<UnsignedLong> pointer = Pointer.fromAddress(fileSize.ref.pointer.address);
          return pointer.value;
        }
        //return figleSize?.ref.pointer.cast<UnsignedLong>().value;
      }
    }

    return null;
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) => throw UnsupportedError('');

  @override
  Future<Uint8List> readAsBytes() {
    if (_tryGetAsset(identifier: params.uri) case final PHAsset asset) {
      final PHImageManager manager = PHImageManager.defaultManager();
      final PHImageRequestOptions options = PHImageRequestOptions.new$();
      options.isNetworkAccessAllowed = true;

      final bytesCompleter = Completer<Uint8List>();
      void resultHandler(
        NSData? imageData,
        NSString? dataUti,
        CGImagePropertyOrientation orientation,
        NSDictionary? info,
      ) {
        if (imageData != null) {
          final Uint8List bytes = _extractBytesToUint8List(imageData);
          runOnPlatformThread(() {
            bytesCompleter.complete(bytes);
          });
        }
      }

      manager.requestImageDataAndOrientationForAsset(
        asset,
        options: options,
        resultHandler:
            ObjCBlock_ffiVoid_NSData_NSString_CGImagePropertyOrientation_NSDictionary.listener(
              resultHandler,
            ),
      );
      return bytesCompleter.future;
    }

    throw Error();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await readAsBytes());
  }

  @override
  Future<bool> canRead() => exists();

  @override
  Future<bool> exists() async => _tryGetAsset(identifier: params.uri) != null;

  @override
  Future<String?> name() async {
    if (_tryGetAsset(identifier: params.uri) case final PHAsset asset) {
      final NSArray resources = PHAssetResource.assetResourcesForAsset(asset);
      final ObjCObject? firstObject = resources.firstObject;

      if (firstObject != null) {
        final resource = PHAssetResource.as(firstObject);
        return resource.originalFilename.toDartString();
      }
    }

    return null;
  }

  PHAsset? _tryGetAsset({required String identifier}) {
    final PHFetchResult result = PHAsset.fetchAssetsWithLocalIdentifiers(
      <String>[params.uri].toNSArray(),
    );
    final ObjCObject? firstObject = result.firstObject;
    if (firstObject != null) {
      return PHAsset.as(firstObject);
    }

    return null;
  }

  Uint8List _extractBytesToUint8List(NSData data) {
    if (data.length == 0) {
      return Uint8List(0);
    }

    final Pointer<Uint8> uint8Pointer = data.bytes.cast<Uint8>();
    final Uint8List byteView = uint8Pointer.asTypedList(data.length);
    return Uint8List.fromList(byteView);
  }
}

/// Provides platform specific features for
/// [SecurityScopedDarwinScopedStorageXFile].
mixin SecurityScopedDarwinScopedStorageXFileExtension
    implements PlatformScopedStorageXFileExtension, SecurityScopedResource {}

/// Provides platform specific features for
/// [PhotoKitDarwinScopedStorageXFile].
mixin PhotoKitDarwinScopedStorageXFileExtension implements PlatformScopedStorageXFileExtension {}
