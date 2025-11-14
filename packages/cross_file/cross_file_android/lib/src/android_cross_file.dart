import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_android/src/document_file.g.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

base class AndroidXFile extends PlatformXFile {
  AndroidXFile(super.params) : super.implementation();

  late final DocumentFile _documentFile = DocumentFile.fromSingleUri(
    path: params.path,
  );

  late final ContentResolver _contentResolver = ContentResolver.instance;

  @override
  Future<DateTime> lastModified() async {
    return DateTime.fromMillisecondsSinceEpoch(
      await _documentFile.lastModified(),
    );
  }

  @override
  Future<int> length() => _documentFile.length();

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    final InputStream inputStream = await _contentResolver.openInputStream(
      params.path,
    );
    InputStreamReadBytesResponse response = await inputStream.readBytes(1024);
    while(response.returnValue != -1) {
      yield response.bytes;
      response = await inputStream.readBytes(1024);
    }
  }

  @override
  Future<Uint8List> readAsBytes() async {
    final InputStream inputStream = await _contentResolver.openInputStream(
      params.path,
    );
    return inputStream.readAllBytes();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    // TODO: implement readAsString
    throw UnimplementedError();
  }

  @override
  Future<bool> canRead() => _documentFile.canRead();

  @override
  Future<bool> exists() => _documentFile.exists();
}
