import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

base class IOSXFile extends PlatformXFile {
  IOSXFile(super.params) : super.implementation();

  @override
  Future<bool> canRead() {
    // TODO: implement canRead
    throw UnimplementedError();
  }

  @override
  Future<bool> exists() {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  Future<DateTime> lastModified() {
    // TODO: implement lastModified
    throw UnimplementedError();
  }

  @override
  Future<int> length() {
    // TODO: implement length
    throw UnimplementedError();
  }

}
