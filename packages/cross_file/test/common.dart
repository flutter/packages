// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

/// An XFileSource that uses a fixed last modified time and byte contents.
class TestXFileSource extends XFileSource {
  TestXFileSource(
      this._lastModified, this.mimeType, this.bytes, this.path, this.name);

  final DateTime _lastModified;
  @override
  final String? mimeType;
  final Uint8List bytes;
  @override
  final String? path;
  @override
  final String? name;

  @override
  Future<DateTime> lastModified() => Future<DateTime>.value(_lastModified);

  @override
  Future<int> length() => Future<int>.value(bytes.length);

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    return Stream<Uint8List>.value(bytes.sublist(start ?? 0, end));
  }
}
