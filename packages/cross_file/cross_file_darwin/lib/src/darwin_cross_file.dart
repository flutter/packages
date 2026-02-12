// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:cross_file_io/cross_file_io.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'cross_file_darwin_apis.g.dart';
import 'security_scoped_resource.dart';

/// Implementation of [PlatformXFileCreationParams] for iOS and
/// macOS.
@immutable
base class DarwinXFileCreationParams extends IOXFileCreationParams {
  /// Constructs a [DarwinXFileCreationParams].
  DarwinXFileCreationParams({
    required super.uri,
    @visibleForTesting CrossFileDarwinApi? api,
  }) : api = api ?? CrossFileDarwinApi();

  DarwinXFileCreationParams.fromFilePath({
    required String path,
    @visibleForTesting CrossFileDarwinApi? api,
  }) : api = api ?? CrossFileDarwinApi(),
       super(uri: 'file:///$path');

  /// The API used to call to native code to interact with files.
  @visibleForTesting
  final CrossFileDarwinApi api;
}

/// Implementation of [PlatformXFile] for iOS and macOS.
base class DarwinXFile extends IOXFile with DarwinXFileExtension {
  /// Constructs a [DarwinXFile].
  DarwinXFile(super.params) : super();

  late final DarwinXFileCreationParams _params =
      super.params is DarwinXFileCreationParams
      ? super.params as DarwinXFileCreationParams
      : DarwinXFileCreationParams(uri: super.params.uri);

  @override
  DarwinXFileCreationParams get params => _params;

  @override
  DarwinXFileExtension? get extension => this;

  @override
  Future<bool> startAccessingSecurityScopedResource() {
    return params.api.startAccessingSecurityScopedResource(params.uri);
  }

  @override
  Future<void> stopAccessingSecurityScopedResource() {
    return params.api.stopAccessingSecurityScopedResource(params.uri);
  }

  @override
  Future<String?> toBookmarkedUri() async {
    return params.api.tryCreateBookmarkedUrl(params.uri);
  }
}

/// Provides platform specific features for [DarwinXFile].
mixin DarwinXFileExtension
    implements IOXFileExtension, SecurityScopedResource {}
