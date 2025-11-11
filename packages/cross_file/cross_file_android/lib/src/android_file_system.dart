import 'package:cross_file_android/src/document_file.g.dart';
import 'package:file/file.dart';
import 'package:path/src/context.dart';

class AndroidFileSystem extends FileSystem {
  const AndroidFileSystem();

  @override
  Directory currentDirectory;

  @override
  Directory directory(path) {
    throw UnimplementedError();
  }

  @override
  File file(path) {
    throw UnimplementedError();
  }

  @override
  Future<bool> identical(String path1, String path2) {
    // TODO: implement identical
    throw UnimplementedError();
  }

  @override
  bool identicalSync(String path1, String path2) {
    // TODO: implement identicalSync
    throw UnimplementedError();
  }

  @override
  // TODO: implement isWatchSupported
  bool get isWatchSupported => throw UnimplementedError();

  @override
  Link link(path) {
    // TODO: implement link
    throw UnimplementedError();
  }

  @override
  // TODO: implement path
  Context get path => throw UnimplementedError();

  @override
  Future<FileStat> stat(String path) {
    // TODO: implement stat
    throw UnimplementedError();
  }

  @override
  FileStat statSync(String path) {
    throw UnimplementedError();
  }

  @override
  Directory get systemTempDirectory => throw UnimplementedError();

  @override
  Future<FileSystemEntityType> type(String path, {bool followLinks = true}) {
    throw UnimplementedError();
  }

  @override
  FileSystemEntityType typeSync(String path, {bool followLinks = true}) {
    throw UnimplementedError();
  }
  
}