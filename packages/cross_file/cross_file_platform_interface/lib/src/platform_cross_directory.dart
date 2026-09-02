// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart' show immutable, protected;

import 'platform_cross_entity.dart';

/// Object specifying creation parameters for creating a [PlatformXDirectory].
///
/// Platform-specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformXDirectoryCreationParams] to
/// provide additional platform-specific parameters.
///
/// When extending [PlatformXDirectoryCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidXDirectoryCreationParams
///     extends PlatformXDirectoryCreationParams {
///   AndroidXDirectoryCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidXDirectoryCreationParams.fromCreationParams(
///     PlatformXDirectoryCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidXDirectoryCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformXDirectoryCreationParams extends PlatformXEntityCreationParams {
  /// Constructs a [PlatformXDirectoryCreationParams].
  const PlatformXDirectoryCreationParams({required super.uri});
}

/// Base mixin used to provide platform-specific features for implementations of
/// [PlatformXDirectory].
///
/// When providing platform specific features, platform implementations are
/// expected to declare a mixin that implements this mixin and return an
/// instance with [PlatformXDirectory.extension].
///
/// ```dart
/// base class AndroidXDirectory extends PlatformXDirectory with AndroidXDirectoryExtension {
///   // ...
///   @override
///   PlatformXDirectoryExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidXDirectoryExtension implements PlatformXDirectoryExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin PlatformXDirectoryExtension implements PlatformXEntityExtension {}

/// Interface for a reference to a container of local data resources.
abstract base class PlatformXDirectory extends PlatformXEntity {
  /// Constructs a [PlatformXDirectory].
  @protected
  PlatformXDirectory(PlatformXDirectoryCreationParams super.params);

  @override
  PlatformXDirectoryCreationParams get params => super.params as PlatformXDirectoryCreationParams;

  /// Lists the sub-directories and files of this Directory.
  ///
  /// Platforms may throw an exception if there is an error listing entities in
  /// the directory
  Stream<PlatformXEntity> list(PlatformListParams params);
}

/// Base class for parameters passed to [PlatformXDirectory.list].
@immutable
base class PlatformListParams {
  /// Constructs a [PlatformListParams];
  const PlatformListParams();
}
