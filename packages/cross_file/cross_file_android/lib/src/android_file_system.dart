import 'package:cross_file_android/src/document_file.g.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/src/context.dart';
import 'dart:io' as io;

class AndroidFileSystem extends FileSystem {
  const AndroidFileSystem();

  @override
  Directory directory(path) {
    throw UnimplementedError();
  }

  @override
  File file(path) {
    throw UnimplementedError();
  }

  @override
  Future<bool> identical(String path1, String path2) =>
      throw UnimplementedError();

  @override
  bool identicalSync(String path1, String path2) => throw UnimplementedError();

  @override
  bool get isWatchSupported => false;

  @override
  Link link(path) => throw UnimplementedError();

  @override
  Future<FileStat> stat(String path) {
    throw UnimplementedError();
  }

  @override
  FileStat statSync(String path) => throw UnimplementedError();

  @override
  Future<FileSystemEntityType> type(String path, {bool followLinks = true}) => throw UnimplementedError();

  @override
  FileSystemEntityType typeSync(String path, {bool followLinks = true}) => throw UnimplementedError();

  @override
  Directory currentDirectory => throw UnimplementedError();

  @override
  // TODO: implement path
  Context get path => Context();

  @override
  // TODO: implement systemTempDirectory
  Directory get systemTempDirectory => File.systemTempDirectory;
}
