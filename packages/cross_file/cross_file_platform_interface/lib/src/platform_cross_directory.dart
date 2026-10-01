// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart' show immutable, protected;

import 'platform_cross_entity.dart';
import 'platform_cross_file.dart';

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

/// Interface for a reference to a container of data resources.
abstract base class PlatformXDirectory extends PlatformXEntity {
  /// Constructs a [PlatformXDirectory].
  @protected
  PlatformXDirectory(PlatformXDirectoryCreationParams super.params);

  @override
  PlatformXDirectoryCreationParams get params => super.params as PlatformXDirectoryCreationParams;

  /// Extension for providing platform-specific features.
  @override
  PlatformXDirectoryExtension? get extension => null;

  /// Lists the sub-directories and resources of this container.
  ///
  /// Platforms may throw an exception if there is an error listing entities in
  /// the directory
  Stream<PlatformXEntity> list(PlatformListParams params);

  /// Whether the application has permission to modify or write to the
  /// fcontainer.
  Future<bool> canWrite() {
    throw UnimplementedError('`canWrite` is not implemented on the current platform.');
  }

  /// Creates a resource in this container.
  ///
  /// Platforms may throw an exception if there is an error creating the
  /// resource.
  Future<PlatformXFile> createFile(PlatformCreateParams params) {
    throw UnimplementedError('`createFile` is not implemented on the current platform.');
  }

  /// Creates a container in this the container.
  ///
  /// Platforms may throw an exception if there is an error creating the
  /// container.
  Future<PlatformXDirectory> createDirectory(PlatformCreateParams params) {
    throw UnimplementedError('`createDirectory` is not implemented on the current platform.');
  }

  /// Deletes the container.
  ///
  /// Platforms may throw an exception if there is an error deleting the
  /// container.
  Future<bool> delete(PlatformDirectoryDeleteParams params) {
    throw UnimplementedError('`delete` is not implemented on the current platform.');
  }
}

/// Base class for parameters passed to [PlatformXDirectory.list].
@immutable
base class PlatformListParams {
  /// Constructs a [PlatformListParams];
  const PlatformListParams();
}

/// Base class for parameters passed to [PlatformXDirectory.create].
@immutable
base class PlatformCreateParams {
  /// Constructs a [PlatformCreateParams];
  const PlatformCreateParams();
}

/// Base class for parameters passed to [PlatformXDirectory.delete].
@immutable
base class PlatformDirectoryDeleteParams {
  /// Constructs a [PlatformDirectoryDeleteParams];
  const PlatformDirectoryDeleteParams();
}
