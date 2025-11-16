import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/foundation.g.dart',
    swiftOut: 'ios/Classes/proxies/Foundation.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)

@ProxyApi()
abstract class URL {
  @static
  URL? fileURLWithPath(String path);

  bool startAccessingSecurityScopedResource();

  void stopAccessingSecurityScopedResource();
}

@ProxyApi()
abstract class FileHandle {
  FileHandle.forReadingFromUrl(URL url);

  Uint8List? readToEnd();

  void close();
}
