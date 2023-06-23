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

<?code-excerpt "../../app/pigeons/messages.dart (config)"?>
```dart
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'pigeon_example'),
  cppHeaderOut: 'windows/runner/messages.g.h',
  cppSourceOut: 'windows/runner/messages.g.cpp',
  kotlinOut:
      'android/app/src/main/kotlin/dev/flutter/pigeon_example_app/Messages.g.kt',
  kotlinOptions: KotlinOptions(),
  javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
  javaOptions: JavaOptions(),
  swiftOut: 'ios/Runner/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  objcHeaderOut: 'macos/runner/messages_objc.h',
  objcSourceOut: 'macos/runner/message_objc.m',
  objcOptions: ObjcOptions(),
  copyrightHeader: 'pigeons/copyright.txt',
))
```

## HostApi Example

This example gives an overview of how to use Pigeon to call into the
host-platform from Flutter.

For instructions to set up your own Pigeon usage see these [steps](../README.md#usage).

### Dart input (message.dart)

This is the Pigeon file that describes the interface that will be used to call
from Flutter to the host-platform.

<?code-excerpt "../../app/pigeons/messages.dart (host-definitions)"?>
```dart
class CreateMessage {
  CreateMessage({required this.code, required this.httpHeaders});
  String? asset;
  String? uri;
  int code;
  Map<String?, String?> httpHeaders;
}

@HostApi()
abstract class ExampleHostApi {
  String getHostLanguage();
  int add(int a, int b);
  @async
  bool sendMessage(CreateMessage message);
}
```

### main.dart

This is the code that will use the generated dart code to make calls from Flutter to 
the host platform.

<?code-excerpt "../../app/lib/main.dart (main-dart)"?>
```dart 
final ExampleHostApi _api = ExampleHostApi();

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
```

### AppDelegate.swift

This is the code that will use the generated Swift code to receive calls from Flutter.
packages/pigeon/example/app/ios/Runner/AppDelegate.swift
<?code-excerpt "../../app/ios/Runner/AppDelegate.swift (swift-class)"?>
```swift
private class PigeonApiImplementation: ExampleHostApi {
  func getHostLanguage() throws -> String {
    return "Swift"
  }

  func sendMessage(message: CreateMessage, completion: @escaping (Result<Bool, Error>) -> Void) {
    completion(Result(true, nil))
  }

  func add(a: Int64, b: Int64) throws -> Int64 {
    return a + b
  }
}
```

### kotlin
<?code-excerpt "../../app/android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt (kotlin-class)"?>
```kotlin
private class PigeonApiImplementation: ExampleHostApi {
    override fun getHostLanguage(): String {
        return "Kotlin"
    }

    fun add(a: Long, b: Long): Long {
        return a + b
    }

    fun sendMessage(message: CreateMessage, callback: (Result<Boolean>) -> Unit) {
        callback(Result.success(true))
    }
}
```

### c++
<?code-excerpt "../../app/windows/runner/flutter_window.cpp (cpp-class)"?>
```c++
class PigeonApiImplementation : public ExampleHostApi {
 public:
  PigeonApiImplementation() {}
  virtual ~PigeonApiImplementation() {}

  ErrorOr<std::string> GetHostLanguage() override { return "C++"; }
  ErrorOr<int64_t> Add(int64_t a, int64_t b) { return a + b; }
  void SendMessage(const CreateMessage& message,
                   std::function<void(ErrorOr<bool> reply)> result) {
    result(true);
  }
};
```

## FlutterApi Example

This example gives an overview of how to use Pigeon to call into the Flutter
app from the host platform.

### Dart input (message.dart)

<?code-excerpt "../../app/pigeons/messages.dart (flutter-definitions)"?>
```dart
@FlutterApi()
abstract class MessageFlutterApi {
  String flutterMethod(String? aString);
}
```

### main.dart

This is the code that will use the generated dart code to make calls from Flutter to 
the host platform.

<?code-excerpt "../../app/lib/main.dart (main-dart-flutter)"?>
```dart 
class _ExampleFlutterApi implements MessageFlutterApi {
  @override
  String flutterMethod(String? aString) {
    return aString ?? '';
  }
}
// ···
  MessageFlutterApi.setup(_ExampleFlutterApi());
```

### AppDelegate.swift

<?code-excerpt "../../app/ios/Runner/AppDelegate.swift (swift-class-flutter)"?>
```swift
private class PigeonFlutterApi {
  var flutterAPI: MessageFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = MessageFlutterApi(binaryMessenger: binaryMessenger)
  }

  func callFlutterMethod(String: aString) {
    flutterAPI.flutterMethod(aString) {
      completion(.success($0))
    }
  }
}
```

### kotlin

<?code-excerpt "../../app/android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt (kotlin-class-flutter)"?>
```kotlin
private class PigeonFlutterApi {

  var flutterApi: MessageFlutterApi? = null

  fun init(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    flutterApi = MessageFlutterApi(binding.getBinaryMessenger())
  }

  fun callFlutterMethod(aString: String) {
    flutterAPI!!.flutterMethod(aString) {
      echo -> callback(Result.success(echo))
    }
  }
}
```

### c++

<?code-excerpt "../../app/windows/runner/flutter_window.cpp (cpp-class-flutter)"?>
```c++

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
