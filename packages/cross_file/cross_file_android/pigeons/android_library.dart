// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/android_library.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/flutter/packages/cross_file_android/proxies/AndroidLibrary.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.flutter.packages.cross_file_android.proxies',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
/// Representation of a document backed by either a
/// android.provider.DocumentsProvider or a raw file on disk.
///
/// See https://developer.android.com/reference/androidx/documentfile/provider/DocumentFile.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.documentfile.provider.DocumentFile',
  ),
)
abstract class DocumentFile {
  /// Create a DocumentFile representing the single document at the given Uri.
  DocumentFile.fromSingleUri(String singleUri);

  DocumentFile.fromTreeUri(String treeUri);

  /// Indicates whether the current context is allowed to read from this file.
  bool canRead();

  /// Deletes this file.
  bool delete();

  /// Returns a boolean indicating whether this file can be found.
  bool exists();

  /// Returns the time when this file was last modified, measured in
  /// milliseconds since January 1st, 1970, midnight.
  int lastModified();

  /// Returns the length of this file in bytes.
  int length();

  /// Indicates if this file represents a *file*.
  bool isFile();

  /// Indicates if this file represents a *directory*.
  bool isDirectory();

  /// Returns an list of files contained in the directory represented by this
  /// file.
  List<DocumentFile> listFiles();

  /// A Uri for the underlying document represented by this file.
  String getUri();
}

/// This class provides applications access to the content model.
///
/// See https://developer.android.com/reference/kotlin/android/content/ContentResolver
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.content.ContentResolver',
  ),
)
abstract class ContentResolver {
  /// Helper field for accessing the `ContentResolver` from the current Android
  /// `Context`.
  @static
  late final ContentResolver instance;

  /// Open a stream on to the content associated with a content URI.
  InputStream? openInputStream(String uri);
}

/// Return type for [InputStream.readBytes] that handles returning two values.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'dev.flutter.packages.cross_file_android.InputStreamReadBytesResponse',
  ),
)
abstract class InputStreamReadBytesResponse {
  late final int returnValue;

  late final Uint8List bytes;
}

/// This abstract class is the superclass of all classes representing an input
/// stream of bytes.
///
/// See https://developer.android.com/reference/java/io/InputStream.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(fullClassName: 'java.io.InputStream'),
)
abstract class InputStream {
  /// Reads some number of bytes from the input stream and stores them into the
  /// returns them.
  InputStreamReadBytesResponse readBytes(int len);

  /// Reads all remaining bytes from the input stream.
  Uint8List readAllBytes();

  /// Skips over and discards n bytes of data from this input stream.
  int skip(int n);
}
