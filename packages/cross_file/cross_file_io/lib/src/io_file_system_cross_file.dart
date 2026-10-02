// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:path/path.dart' as path;

/// Implementation of [PlatformFileSystemXFileCreationParams] for dart:io.
@immutable
base class IOFileSystemXFileCreationParams extends PlatformFileSystemXFileCreationParams {
  /// Constructs an [IOFileSystemXFileCreationParams].
  IOFileSystemXFileCreationParams(String path) : this.fromFile(File(path));

  /// Constructs an [IOFileSystemXFileCreationParams] from a [File].
  IOFileSystemXFileCreationParams.fromFile(this.file) : super(file.path);

  /// Constructs an [IOFileSystemXFileCreationParams] from a [PlatformFileSystemXFileCreationParams].
  factory IOFileSystemXFileCreationParams.fromCreationParams(
    PlatformFileSystemXFileCreationParams params,
  ) {
    return IOFileSystemXFileCreationParams(params.path);
  }

  /// The underlying [File] for [IOFileSystemXFile].
  final File file;
}

/// Implementation of [PlatformFileSystemXFile] for dart:io.
base class IOFileSystemXFile extends PlatformFileSystemXFile with IOFileSystemXFileExtension {
  /// Constructs an [IOFileSystemXFile].
  IOFileSystemXFile(super.params) : super.implementation();

  @override
  late final IOFileSystemXFileCreationParams params =
      super.params is IOFileSystemXFileCreationParams
      ? super.params as IOFileSystemXFileCreationParams
      : IOFileSystemXFileCreationParams.fromCreationParams(super.params);

  @override
  File get file => params.file;

  @override
  PlatformFileSystemXFileExtension? get extension => this;

  @override
  Future<DateTime?> lastModified() async {
    try {
      return file.lastModifiedSync();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<int?> length() async {
    try {
      return await file.length();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) => file.openRead(start, end).cast();

  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) => file.readAsString(encoding: encoding);

  @override
  Future<bool> exists() async => file.existsSync();

  @override
  Future<String?> name() async => path.basename(file.path);

  @override
  Future<PlatformFileSystemXFile> writeAsBytes(PlatformWriteAsBytesParams params) async {
    final File ioFile = await file.writeAsBytes(params.bytes);
    return IOFileSystemXFile(IOFileSystemXFileCreationParams.fromFile(ioFile));
  }

  @override
  Future<bool> canWrite() async {
    try {
      if (await exists()) {
        final RandomAccessFile access = await file.open(mode: FileMode.append);
        await access.close();
        return true;
      }

      return false;
    } on FileSystemException {
      return false;
    }
  }

  @override
  StreamSink<Uint8List> openWrite(PlatformOpenWriteParams params) {
    return _IOSinkWrapper(file.openWrite());
  }

  @override
  Future<PlatformXFile> writeAsString(PlatformWriteAsStringParams params) async {
    final File newFile = await file.writeAsString(params.contents, encoding: params.encoding);
    return IOFileSystemXFile(IOFileSystemXFileCreationParams.fromFile(newFile));
  }

  @override
  Future<bool> delete(PlatformFileDeleteParams params) async {
    try {
      await file.delete();
      return true;
    } on FileSystemException {
      return false;
    }
  }
}

/// Provides platform-specific features for [IOFileSystemXFile].
mixin IOFileSystemXFileExtension implements PlatformFileSystemXFileExtension {
  /// The underlying file.
  File get file;
}

class _IOSinkWrapper implements StreamSink<Uint8List> {
  _IOSinkWrapper(this._ioSink);

  final IOSink _ioSink;

  @override
  void add(Uint8List event) => _ioSink.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _ioSink.addError(error, stackTrace);

  @override
  Future<dynamic> addStream(Stream<Uint8List> stream) => _ioSink.addStream(stream);

  @override
  Future<dynamic> close() => _ioSink.close();

  @override
  Future<dynamic> get done => _ioSink.done;
}
