// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:cross_file_io/cross_file_io.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'cross_file_darwin_apis.g.dart';
import 'security_scoped_resource.dart';

/// Implementation of [PlatformXDirectoryCreationParams] for iOS and
/// macOS.
@immutable
base class DarwinXDirectoryCreationParams extends IOXDirectoryCreationParams {
  /// Constructs a [DarwinXDirectoryCreationParams].
  DarwinXDirectoryCreationParams({
    required super.uri,
    @visibleForTesting CrossFileDarwinApi? api,
  }) : api = api ?? CrossFileDarwinApi();

  /// The API used to call to native code to interact with files.
  @visibleForTesting
  final CrossFileDarwinApi api;
}

/// Implementation of [PlatformXDirectory] for iOS and macOS.
base class DarwinXDirectory extends IOXDirectory
    with DarwinXDirectoryExtension {
  /// Constructs a [DarwinXDirectory].
  DarwinXDirectory(super.params) : super();

  late final DarwinXDirectoryCreationParams _params =
      super.params is DarwinXDirectoryCreationParams
      ? super.params as DarwinXDirectoryCreationParams
      : DarwinXDirectoryCreationParams(uri: super.params.uri);

  @override
  DarwinXDirectoryCreationParams get params => _params;

  @override
  DarwinXDirectoryExtension? get extension => this;

  @override
  Future<bool> startAccessingSecurityScopedResource() {
    return params.api.startAccessingSecurityScopedResource(params.uri);
  }

  @override
  Future<void> stopAccessingSecurityScopedResource() {
    return params.api.stopAccessingSecurityScopedResource(params.uri);
  }
}

/// Provides platform specific features for [DarwinXDirectory].
mixin DarwinXDirectoryExtension
    implements IOXDirectoryExtension, SecurityScopedResource {}
