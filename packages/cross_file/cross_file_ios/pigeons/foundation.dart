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
  bool startAccessingSecurityScopedResource(String url);

  @static
  void stopAccessingSecurityScopedResource(String url);
}

@ProxyApi()
abstract class FileManager {
  @static
  late final FileManager defaultManager;

  bool fileExists(String atPath);

  bool isReadableFile(String atPath);

  Uint8List? contents(String atPath);
}