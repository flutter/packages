import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/document_file.g.dart',
    kotlinOut:
        'android/src/main/kotlin/dev/flutter/packages/cross_file_android/DocumentFile.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.flutter.packages.cross_file_android',
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
}
