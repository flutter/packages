import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

base class IOXFile extends PlatformXFile with IOXFileExtension {
  IOXFile(super.params) : super.implementation();

  late final File file = File(params.path);

  @override
  PlatformXFileExtension? get extension => this;

  @override
  Future<DateTime> lastModified() => file.lastModified();

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
  Future<bool> exists() => file.exists();
}

mixin IOXFileExtension implements PlatformXFileExtension {
  File get file;
}
