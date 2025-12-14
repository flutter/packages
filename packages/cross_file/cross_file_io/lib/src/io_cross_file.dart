// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

/// Implementation of [PlatformXFile] for dart:io.
base class IOXFile extends PlatformXFile with IOXFileExtension {
  /// Constructs an [IOXFile].
  IOXFile(super.params) : super.implementation();

  @override
  late final file = File(params.uri);

  @override
  PlatformXFileExtension? get extension => this;

  @override
  Future<DateTime> lastModified() async => file.lastModifiedSync();

  @override
  Future<int> length() => file.length();

  @override
  Stream<List<int>> openRead([int? start, int? end]) =>
      file.openRead(start, end);

  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      file.readAsString(encoding: encoding);

  @override
  Future<bool> canRead() => exists();

  @override
  Future<bool> exists() async => file.existsSync();
}

/// Provides platform specific features for [IOXFile].
mixin IOXFileExtension implements PlatformXFileExtension {
  /// The underlying file.
  File get file;
}
