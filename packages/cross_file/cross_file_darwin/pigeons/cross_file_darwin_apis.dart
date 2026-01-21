// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/cross_file_darwin_apis.g.dart',
    swiftOut: 'darwin/Classes/CrossFileDarwinApis.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Result of a call to `CrossFileDarwinApi.fileExists`.
class FileExistsResult {
  /// Whether the file exists.
  late bool exists;

  /// Whether th
  late bool isDirectory;
}

/// Api for getting access to file information.
@HostApi()
abstract class CrossFileDarwinApi {
  /// Attempt to create a bookmarked URL that serves as a persistent reference
  /// to a file.
  String? tryCreateBookmarkedUrl(String url);

  /// Whether the invoking object appears able to read a specified file.
  bool isReadableFile(String url);

  /// Whether a file or directory exists at a specified path.
  FileExistsResult fileExists(String url);

  /// The file’s last modified date.
  int? fileModificationDate(String url);

  /// The file’s size in bytes.
  int? fileSize(String url);

  /// Performs a shallow search of the specified directory and returns the paths
  /// of any contained items.
  List<String> list(String url);
}

/// An object-oriented wrapper for a file descriptor.
///
/// See https://developer.apple.com/documentation/foundation/filehandle.
@ProxyApi()
abstract class FileHandle {
  /// Returns a file handle initialized for reading the file, device, or named
  /// socket at the specified path.
  @static
  FileHandle? forReadingAtPath(String path);

  /// Reads data synchronously up to the specified number of bytes.
  Uint8List? readUpToCount(int count);

  /// Reads the available data synchronously up to the end of file or maximum
  /// number of bytes.
  Uint8List? readToEnd();

  /// Moves the file pointer to the specified offset within the file.
  void seek(int offset);

  /// Disallows further access to the represented file or communications channel
  /// and signals end of file on communications channels that permit writing.
  void close();
}
