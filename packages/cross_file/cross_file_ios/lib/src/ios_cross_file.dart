import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_ios/src/foundation.g.dart';
import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

// Note for me: Will probs need a `static Future<IOSXFile> method(Uint8List bookmarkData` method
// instead to create persistent file.
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
    if (bookmarkUrl case URL bookmarkUrl) {
      return FileManager.defaultManager.isReadableFile(
        await bookmarkUrl.path(),
      );
    }

    return false;
  }

  @override
  Future<bool> exists() async {
    final URL? bookmarkUrl = await _bookmarkUrl;
    if (bookmarkUrl case URL bookmarkUrl) {
      return FileManager.defaultManager.fileExists(await bookmarkUrl.path());
    }

    return false;
  }

  @override
  Future<DateTime> lastModified() async {
    final URL? bookmarkUrl = await _bookmarkUrl;
    if (bookmarkUrl case URL bookmarkUrl) {
      final int? lastModifiedSinceEpoch = await FileManager.defaultManager
          .fileModificationDate(await bookmarkUrl.path());
      if (lastModifiedSinceEpoch case int lastModifiedSinceEpoch) {
        return DateTime.fromMillisecondsSinceEpoch(lastModifiedSinceEpoch);
      }
    }

    throw UnsupportedError('cant read: ${params.path}');
  }

  @override
  Future<int> length() async {
    final URL? bookmarkUrl = await _bookmarkUrl;
    if (bookmarkUrl case URL bookmarkUrl) {
      final int? fileSize = await FileManager.defaultManager.fileSize(
        await bookmarkUrl.path(),
      );
      if (fileSize case int fileSize) {
        return fileSize;
      }
    }

    throw UnsupportedError('cant read: ${params.path}');
  }

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Stream<List<int>> openRead([int? start, int? end]) async* {
    if (await _bookmarkUrl case URL url) {
      final FileHandle fileHandle = FileHandle.forReadingFromUrl(url: url);
      try {
        Uint8List? bytes = await fileHandle.readUpToCount(4 * 1024);
        while (bytes != null && bytes.isNotEmpty) {
          yield bytes;
          // TODO: this is only supported on ios 13.4
          bytes = await fileHandle.readUpToCount(4 * 1024);
        }
      } finally {
        await fileHandle.close();
      }
    } else {
      throw UnsupportedError('Cant access bytes to file: ${params.path}');
    }
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
