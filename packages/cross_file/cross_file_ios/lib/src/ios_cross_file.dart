import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file_ios/src/foundation.g.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

base class IOSXFile extends PlatformSharedStorageXFile {
  IOSXFile(super.params) : super.implementation();

  late final Future<URL?> _originalUrl = URL.fileURLWithPath(params.path);

  late final Future<URL?> _bookmarkUrl = () async {
    final URL? url = await _originalUrl;
    if (url case URL url) {
      final bool canRead = await url.startAccessingSecurityScopedResource();
      if (canRead) {
        try {
          final Uint8List? bookmarkData = await url.bookmarkData([], [], null);
          if (bookmarkData case Uint8List bookmarkData) {
            final URLResolvingBookmarkDataResponse response = await URL
                .resolvingBookmarkData(bookmarkData, [], null);
            if (response.isStale) {
              // TODO: create new bookmark
              print('STALE');
              return null;
            }
            return response.url;
          }
        } finally {
          await url.stopAccessingSecurityScopedResource();
        }
      }
    }

    return null;
  }();

  @override
  Future<bool> canRead() async {
    final URL? bookmarkUrl = await _bookmarkUrl;
    return bookmarkUrl != null;
  }

  @override
  Future<bool> exists() {
    return canRead();
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
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Stream<List<int>> openRead([int? start, int? end]) {
    // TODO: implement openRead
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> readAsBytes() async {
    if (await _bookmarkUrl case URL url) {
      final FileHandle fileHandle = FileHandle.forReadingFromUrl(url: url);
      try {
        final Uint8List? bytes = await fileHandle.readToEnd();

        if (bytes case Uint8List bytes) {
          return bytes;
        }
      } finally {
        await fileHandle.close();
      }
    }

    throw UnsupportedError('Cant access bytes to file: ${params.path}');
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await readAsBytes());
  }
}
