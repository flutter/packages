// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show internal, protected;

import 'cross_disposable.dart';

/// The common superclass for [XFile] and [XDirectory].
base class XEntity with XDisposable {
  /// Constructs a [XEntity].
  @internal
  @protected
  XEntity(this.platform);

  /// Implementation of [XEntity] for the current platform.
  @internal
  final PlatformXEntity platform;

  /// Attempt to provide the platform class extension.
  ///
  /// Returns null if the specified platform extension cannot be retrieved.
  S? getExtension<S extends PlatformXEntityExtension>() {
    assert(assertNotDisposed());
    return platform.extension is S ? platform.extension! as S : null;
  }

  /// A unique string used to identify the resource.
  String get uri => platform.params.uri;

  /// Whether the resource represented by this reference exists.
  Future<bool> exists() {
    assert(assertNotDisposed());
    return platform.exists();
  }

  /// Releases the underlying reference to the resource, if necessary.
  ///
  /// This is expected to be called when the app no longer needs to access the
  /// resource.
  ///
  /// The result of calling this is platform implementation dependent. This can
  /// do nothing on some platforms while on other platforms it can remove access
  /// to a resource referenced by [uri] even if it is used with a new instance.
  ///
  /// Once called, this instance can no longer be used.
  Future<void> dispose() {
    markDisposed();
    return platform.dispose();
  }

  @override
  // This is required because `XDisposable` contains an _isDisposed variable.
  // Since this class delegates to a platform implementation, an instance is
  // always equal if the platform implementations are the same reference.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => other is XEntity && other.platform == platform;

  @override
  // This is required because `XDisposable` contains an _isDisposed variable.
  // Since this class delegates to a platform implementation, an instance is
  // always equal if the platform implementations are the same reference.
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => platform.hashCode;

  @override
  String toString() => platform.params.uri;
}
