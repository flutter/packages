import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_android/src/document_file.g.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

base class AndroidXFile extends PlatformSharedStorageXFile {
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
    final InputStream? inputStream = await _contentResolver.openInputStream(
      params.path,
    );
    // TODO: add support for start and end.
    if (inputStream case InputStream inputStream) {
      InputStreamReadBytesResponse response = await inputStream.readBytes(1024);
      while (response.returnValue != -1) {
        yield response.bytes;
        response = await inputStream.readBytes(4 * 1024);
      }
    } else {
      throw _createNullInputStreamError();
    }
  }

  @override
  Future<Uint8List> readAsBytes() async {
    final InputStream? inputStream = await _contentResolver.openInputStream(
      params.path,
    );
    if (inputStream case InputStream inputStream) {
      return inputStream.readAllBytes();
    }

    throw _createNullInputStreamError();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    return utf8.decodeStream(openRead());
  }

  @override
  Future<bool> canRead() => _documentFile.canRead();

  @override
  Future<bool> exists() {
    // TODO: shoulc also call _documentFile.isFile
    return _documentFile.exists();
  }

  UnsupportedError _createNullInputStreamError() {
    return UnsupportedError(
      'Failed to get native InputStream from file with path: ${params.path}. '
      'App may not have permissions to access file.',
    );
  }

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }
}
