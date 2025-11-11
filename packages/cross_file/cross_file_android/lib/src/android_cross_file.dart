import 'dart:convert';
import 'dart:typed_data';

base class AndroidXFile extends PlatformXFile with AndroidXFileExtension {
  AndroidXFile(super.path);

  @override
  PlatformXFileExtension? get extension {
    return this;
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

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
    // TODO: implement openRead
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readAsBytes() {
    // TODO: implement readAsBytes
    throw UnimplementedError();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    // TODO: implement readAsString
    throw UnimplementedError();
  }
}