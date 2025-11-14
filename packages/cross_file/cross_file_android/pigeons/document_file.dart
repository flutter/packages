import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/document_file.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/flutter/packages/cross_file_android/proxies/DocumentFile.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.flutter.packages.cross_file_android.proxies',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.documentfile.provider.DocumentFile',
  ),
)
abstract class DocumentFile {
  DocumentFile.fromSingleUri(String path);

  bool canRead();

  bool delete();

  bool exists();

  int lastModified();

  int length();
}

/// https://developer.android.com/reference/kotlin/android/content/ContentResolver
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.content.ContentResolver',
  ),
)
abstract class ContentResolver {
  @static
  late final ContentResolver instance;

  InputStream? openInputStream(String uri);
}

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

@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(fullClassName: 'java.io.InputStream'),
)
abstract class InputStream {
  InputStreamReadBytesResponse readBytes(int len);

  Uint8List readAllBytes();

  int skip(int n);
}
