// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../x_file.dart';

/// A CrossFile backed by a dart:io [File].
///
/// (Mobile-only).
class IOXFile implements XFile {
  /// Construct a XFile object from a `dart:io` [File].
  ///
  /// The following optional parameters are accepted:
  ///   * [mimeType] to save a call to `package:mime` later.
  ///   * [displayName] to override the displayed name of the file for cosmetic
  ///   reasons (Shouldn't be used as a proxy for the file's [path]).
  IOXFile(
    File file, {
    String? mimeType,
  })  : _mimeType = mimeType,
        _file = file;

  /// Construct a XFile object from a `dart:io` [File]'s [path].
  ///
  /// The following optional parameters are accepted:
  ///   * [mimeType] to save a call to `package:mime` later.
  ///   * [displayName] to override the displayed name of the file for cosmetic
  ///   reasons (Shouldn't be used as a proxy for the file's [path]).
  factory IOXFile.fromPath(
    String path, {
    String? mimeType,
  }) {
    return IOXFile(
      File(path),
      mimeType: mimeType,
    );
  }

  final File _file;
  final String? _mimeType;

  @override
  Future<DateTime> lastModified() async {
    return _file.lastModifiedSync();
  }

  @override
  String? get mimeType => _mimeType;

  @override
  String get path => _file.path;

  @override
  String get name => _file.path.split(Platform.pathSeparator).last;

  @override
  Future<int> length() async {
    return _file.lengthSync();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    return _file.readAsString(encoding: encoding);
  }

  @override
  Future<Uint8List> readAsBytes() {
    return _file.readAsBytes();
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    return _file
        .openRead(start ?? 0, end)
        .map((List<int> chunk) => Uint8List.fromList(chunk));
  }

  @override
  Future<void> saveTo(String path) async {
    await _file.copy(path);
  }
}
