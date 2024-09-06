// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import '../x_file.dart';

/// The shared behavior for all byte-backed [XFile] implementations.
///
/// This is an almost complete XFile implementation, except for the `saveTo`
/// method, which is platform-dependent.
abstract class BaseBytesXFile implements XFile {
  /// Construct an [XFile] from its data [bytes].
  BaseBytesXFile(
    this.bytes, {
    String? mimeType,
    String? displayName,
    DateTime? lastModified,
  })  : _mimeType = mimeType,
        _displayName = displayName,
        _lastModified = lastModified;

  /// The binary contents of this [XFile].
  final Uint8List bytes;
  final String? _mimeType;
  final String? _displayName;
  final DateTime? _lastModified;

  @override
  Future<DateTime> lastModified() async {
    return _lastModified ?? DateTime.now();
  }

  @override
  String? get mimeType => _mimeType;

  @override
  String? get path => null;

  @override
  String? get name => _displayName;

  @override
  Future<int> length() async {
    return bytes.length;
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(bytes);
  }

  @override
  Future<Uint8List> readAsBytes() async {
    return bytes;
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    yield bytes.sublist(start ?? 0, end ?? bytes.length);
  }
}
