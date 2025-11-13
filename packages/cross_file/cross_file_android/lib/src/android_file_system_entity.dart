import 'dart:io' as io;

import 'package:cross_file_android/src/document_file.g.dart';
import 'package:file/file.dart';

import 'android_file_system.dart';

mixin AndroidFileSystemEntity on FileSystemEntity {
  DocumentFile get nativeFile;

  /// Returns the file system responsible for this entity.
  FileSystem get fileSystem => const AndroidFileSystem();

  /// Gets the part of this entity's path after the last separator.
  ///
  ///     context.basename('path/to/foo.dart'); // -> 'foo.dart'
  ///     context.basename('path/to');          // -> 'to'
  ///
  /// Trailing separators are ignored.
  ///
  ///     context.basename('path/to/'); // -> 'to'
  String get basename => fileSystem.path.basename(path);

  /// Gets the part of this entity's path before the last separator.
  ///
  ///     context.dirname('path/to/foo.dart'); // -> 'path/to'
  ///     context.dirname('path/to');          // -> 'path'
  ///     context.dirname('foo.dart');         // -> '.'
  ///
  /// Trailing separators are ignored.
  ///
  ///     context.dirname('path/to/'); // -> 'path'
  String get dirname => fileSystem.path.dirname(path);

  // Override method definitions to codify the return type covariance.
  @override
  Future<FileSystemEntity> delete({bool recursive = false});

  @override
  Directory get parent;
}
