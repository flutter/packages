import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/foundation.g.dart',
    swiftOut: 'ios/Classes/proxies/Foundation.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
enum URLBookmarkCreationOptions { minimalBookmark, suitableForBookmarkOptions }

enum URLResourceKeyEnum { isDirectoryKey, parentDirectoryURLKey }

enum URLBookmarkResolutionOptions { withoutUI, withoutMounting }

@ProxyApi()
abstract class URLResolvingBookmarkDataResponse {
  late final URL url;
  late final bool isStale;
}

@ProxyApi()
abstract class URL {
  @static
  URL? fileURLWithPath(String path);

  @static
  URLResolvingBookmarkDataResponse resolvingBookmarkData(
    Uint8List data,
    List<URLBookmarkResolutionOptions> options,
    URL? relativeTo,
  );

  Uint8List bookmarkData(
    List<URLBookmarkCreationOptions> options,
    List<URLResourceKeyEnum>? keys,
    URL? relativeTo,
  );

  bool startAccessingSecurityScopedResource();

  void stopAccessingSecurityScopedResource();
}

@ProxyApi()
abstract class FileHandle {
  FileHandle.forReadingFromUrl(URL url);

  Uint8List? readToEnd();

  void close();
}
