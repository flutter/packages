// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import './base.dart';
import 'x_file_source.dart';

// ignore_for_file: avoid_unused_constructor_parameters

/// A CrossFile backed by a dart:io File.
class XFile extends XFileBase {
  /// Construct a CrossFile object backed by a dart:io File.
  ///
  /// [bytes] is ignored; the parameter exists only to match the web version of
  /// the constructor. To construct a dart:io XFile from bytes, use
  /// [XFile.fromData].
  ///
  /// [name] is ignored; the parameter exists only to match the web version of
  /// the constructor.
  ///
  /// [length] is ignored; the parameter exists only to match the web version of
  /// the constructor.
  ///
  // ignore: use_super_parameters
  XFile(
    String path, {
    String? mimeType,
    String? name,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
  })  : _mimeType = mimeType,
        _file = File(path),
        _bytes = null,
        _source = null,
        _lastModified = lastModified,
        super(path);

  /// Construct an CrossFile from its data
  ///
  /// [name] is ignored; the parameter exists only to match the web version of
  /// the constructor.
  XFile.fromData(
    Uint8List bytes, {
    String? mimeType,
    String? path,
    String? name,
    int? length,
    DateTime? lastModified,
  })  : _mimeType = mimeType,
        _bytes = bytes,
        _source = null,
        _file = File(path ?? ''),
        _length = length,
        _lastModified = lastModified,
        super(path) {
    if (length == null) {
      _length = bytes.length;
    }
  }

  /// Construct a CrossFile object from an instance of `XFileSource`.
  ///
  /// Exceptions thrown by any member of the implementation of the source
  /// won't be altered or caught by this `XFile`.
  XFile.fromCustomSource(XFileSource source)
      : _mimeType = null,
        _bytes = null,
        _file = null,
        _length = null,
        _lastModified = null,
        _source = source,
        super(null);

  final File? _file;
  final String? _mimeType;
  final DateTime? _lastModified;
  int? _length;

  final Uint8List? _bytes;
  final XFileSource? _source;

  @override
  Future<DateTime> lastModified() {
    if (_lastModified != null) {
      return Future<DateTime>.value(_lastModified);
    }

    if (_source != null) {
      return _source.lastModified();
    }
    // ignore: avoid_slow_async_io
    return _file!.lastModified();
  }

  @override
  Future<void> saveTo(String path) async {
    final File fileToSave = File(path);

    if (_bytes != null) {
      await fileToSave.writeAsBytes(_bytes);

      return;
    }

    if (_source != null) {
      // Clear the file before writing to it
      await fileToSave.writeAsBytes(<int>[]);

      await _source.openRead().forEach((Uint8List chunk) {
        fileToSave.writeAsBytesSync(chunk, mode: FileMode.append);
      });
      return;
    }

    await _file!.copy(path);
  }

  @override
  String? get mimeType => _mimeType;

  @override
  String get path {
    if (_file != null) {
      return _file.path;
    }

    return _source!.path;
  }

  @override
  String get name {
    if (_file != null) {
      return _file.path.split(Platform.pathSeparator).last;
    }

    // Name could be different from the basename of the path on Android
    // as the full path may not be available.
    return _source!.name;
  }

  @override
  Future<int> length() {
    if (_length != null) {
      return Future<int>.value(_length);
    }

    if (_file != null) {
      return _file.length();
    }

    return _source!.length();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    if (_bytes != null) {
      return Future<String>.value(encoding.decode(_bytes));
    }

    if (_file != null) {
      return _file.readAsString(encoding: encoding);
    }

    return readAsBytes().then(encoding.decode);
  }

  @override
  Future<Uint8List> readAsBytes() {
    if (_bytes != null) {
      return Future<Uint8List>.value(_bytes);
    }

    if (_file != null) {
      return _file.readAsBytes();
    }

    return openRead().toList().then((List<Uint8List> chunks) {
      return Uint8List.fromList(
          chunks.expand((Uint8List chunk) => chunk).toList());
    });
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    if (_bytes != null) {
      return Stream<Uint8List>.value(
          _bytes.sublist(start ?? 0, end ?? _bytes.length));
    }

    if (_file != null) {
      return _file
          .openRead(start ?? 0, end)
          .map((List<int> chunk) => Uint8List.fromList(chunk));
    }

    return _source!.openRead(start, end);
  }
}
