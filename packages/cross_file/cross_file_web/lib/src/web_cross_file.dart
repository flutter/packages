import 'dart:convert';

import 'dart:typed_data';

import 'package:web/web.dart';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'web_helpers.dart';

base class WebXFileCreationParams extends PlatformXFileCreationParams {
  WebXFileCreationParams({required super.path, this.blob});

  final Blob? blob;
}

base class WebXFile extends PlatformXFile with WebXFileExtension {
  WebXFile(super.params) : super.implementation();

  Blob? _cachedBlob;
  final DateTime defaultLastModified = DateTime.now();

  @override
  PlatformXFileExtension? get extension => this;

  @override
  late final WebXFileCreationParams params =
      super.params is WebXFileCreationParams
      ? super.params as WebXFileCreationParams
      : WebXFileCreationParams(path: params.path);

  Future<Blob> getBlob() async {
    return _cachedBlob ??= params.blob ?? await fetchBlob(params.path);
  }

  @override
  Future<bool> canRead() => exists();

  @override
  Future<bool> exists() async {
    try {
      await getBlob();
      return true;
    } catch (exception) {
      return false;
    }
  }

  @override
  Future<DateTime> lastModified() async {
    final Blob blob = await getBlob();
    if (blob is File) {
      return DateTime.fromMillisecondsSinceEpoch(blob.lastModified);
    }

    return defaultLastModified;
  }

  @override
  Future<int> length() async {
    return (await getBlob()).size;
  }

  @override
  Stream<List<int>> openRead([int? start, int? end]) async* {
    final Blob blob = await getBlob();
    final Blob slice = blob.slice(start ?? 0, end ?? blob.size, blob.type);
    yield await blobToBytes(slice);
  }

  @override
  Future<Uint8List> readAsBytes() async {
    return blobToBytes(await getBlob());
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await readAsBytes());
  }

  @override
  Future<void> download([String? suggestedName]) async {
    final Blob blob = await getBlob();

    String? name;
    if (suggestedName != null) {
      name = suggestedName;
    } else if (blob is File) {
      name = blob.name;
    }

    await downloadBlob(blob, name);
  }
}

mixin WebXFileExtension implements PlatformXFileExtension {
  Future<Blob> getBlob();

  Future<void> download([String? suggestedName]);
}
