<?code-excerpt path-base="excerpts/packages/pigeon_example"?>
# Pigeon Examples

The examples here will cover basic usage. For a more thorough set of examples,
check the [core_tests pigeon file](../pigeons/core_tests.dart) and 
[platform test folder](../platform_tests/) ([shared_test_plugin_code](../platform_tests/shared_test_plugin_code/) and [alternate_language_test_plugin](../platform_tests/alternate_language_test_plugin/) especially).

## Invocation

This is an example call to Pigeon that would ingest a definition file
`pigeons/message.dart` and generate corresponding output code for each
supported language. In actual use, you would use just the languages matching
your project.

```sh
flutter pub run pigeon \
  --input pigeons/message.dart \
  --dart_out lib/pigeon.dart \
  --objc_header_out ios/Runner/pigeon.h \
  --objc_source_out ios/Runner/pigeon.m \
  --swift_out ios/Runner/Pigeon.swift \
  --kotlin_out android/app/src/main/kotlin/dev/flutter/pigeon/Pigeon.kt \
  --kotlin_package "dev.flutter.pigeon" \
  --java_out android/app/src/main/java/dev/flutter/pigeon/Pigeon.java \
  --java_package "dev.flutter.pigeon" \
  --cpp_header_out windows/runner/pigeon.h \
  --cpp_source_out windows/runner/pigeon.cpp \
  --cpp_namespace pigeon
```

It is usually preferable to add a config into the pigeon input
file directly. 

<?code-excerpt "../../pigeons/message.dart (config)"?>
```dart
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/message.g.dart',
  dartOptions: DartOptions(),
  copyrightHeader: 'pigeons/copyright.txt',
  javaOut: 'platforms_pigeon_out/message_java.java',
  javaOptions: JavaOptions(),
  objcHeaderOut: 'platforms_pigeon_out/message_objc.h',
  objcSourceOut: 'platforms_pigeon_out/message_objc.m',
  objcOptions: ObjcOptions(),
  swiftOut: 'platforms_pigeon_out/message_swift.swift',
  swiftOptions: SwiftOptions(),
  kotlinOut: 'platforms_pigeon_out/message_kt.kt',
  kotlinOptions: KotlinOptions(),
  cppHeaderOut: 'platforms_pigeon_out/message_cpp.h',
  cppSourceOut: 'platforms_pigeon_out/message_cpp.cpp',
  cppOptions: CppOptions(),
))
```

## HostApi Example

This example gives an overview of how to use Pigeon to call into the
host-platform from Flutter.

For instructions to set up your own Pigeon usage see these [steps](../README.md#usage).

### Dart input (message.dart)

This is the Pigeon file that describes the interface that will be used to call
from Flutter to the host-platform.

<?code-excerpt "../../pigeons/message.dart (host-definitions)"?>
```dart
class CreateMessage {
  CreateMessage({required this.code, required this.httpHeaders});
  String? asset;
  String? uri;
  int code;
  Map<String?, String?> httpHeaders;
}

@HostApi()
abstract class MessageHostApi {
  void initialize();
  bool sendMessage(CreateMessage message);
  int add(int a, int b);
}
```

### main.dart

This is the code that will use the generated dart code to make calls from flutter to 
the host platform.

<?code-excerpt "main.dart (main-dart)"?>
```dart 
import 'src/message.g.dart';

/// Example plugin for pigeon code excerpts and examples.
class ExamplePluginClass {
  /// Creates a new plugin implementation instance.
  ExamplePluginClass();

  final MessageHostApi _api = MessageHostApi();

  /// Calls host method `add` with provided arguments.
  Future<int> callAddPlusOne(int a, int b) async {
    final int resultOfAdd = await _api.add(a, b);
    return resultOfAdd + 1;
  }

  /// Sends message through host api using `CreateMessage` class
  /// and api `sendMessage` method.
  Future<bool> sendMessage(String messageText) {
    final CreateMessage message = CreateMessage(
      code: 42,
      httpHeaders: <String?, String?>{'header': 'this is a header'},
      uri: 'uri text',
    );
    return _api.sendMessage(message);
  }
}
```

### AppDelegate.m

This is the code that will use the generated Objective-C code to receive calls
from Flutter.

```objc

```

### AppDelegate.swift

This is the code that will use the generated Swift code to receive calls from Flutter.

```swift

```

### StartActivity.java

This is the code that will use the generated Java code to receive calls from Flutter.

```java

```

### kotlin
``` 

```
### c++
```

```

### test.dart

This is the Dart code that will call into the host-platform using the generated
Dart code.

```dart

```

## FlutterApi Example
lorem

```
ipsum
```

## Swift / Kotlin Plugin Example

A downloadable example of using Pigeon to create a Flutter Plugin with Swift and
Kotlin can be found at
[gaaclarke/flutter_plugin_example](https://github.com/gaaclarke/pigeon_plugin_example).

## Swift / Kotlin Add-to-app Example

A full example of using Pigeon for add-to-app with Swift on iOS can be found at
[samples/add_to_app/books](https://github.com/flutter/samples/tree/master/add_to_app/books).

## Video player plugin

A full real-world example can also be found in the
[video_player plugin](https://github.com/flutter/packages/tree/main/packages/video_player).
