import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/foundation.g.dart',
    swiftOut: 'ios/Classes/proxies/Foundation.swift',
    kotlinOut:
    'android/src/main/kotlin/dev/flutter/packages/cross_file_android/proxies/DocumentFile.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.flutter.packages.cross_file_android.proxies',
    ),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
abstract class A {

}