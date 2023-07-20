<?code-excerpt path-base="app"?>
# Pigeon Examples

The examples here will cover basic usage. For a more thorough set of examples,
check the [core_tests pigeon file](../pigeons/core_tests.dart) and 
[platform test folder](../platform_tests/) ([shared_test_plugin_code](../platform_tests/shared_test_plugin_code/) and [alternate_language_test_plugin](../platform_tests/alternate_language_test_plugin/) especially).

## Invocation

Begin by configuring pigeon at the top of the `.dart` input file.
In actual use, you would include only the languages
needed for your project.

<?code-excerpt "pigeons/messages.dart (config)"?>
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
  objcHeaderOut: 'macos/Runner/messages.g.h',
  objcSourceOut: 'macos/Runner/messages.g.m',
  // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
  objcOptions: ObjcOptions(prefix: 'PGN'),
  copyrightHeader: 'pigeons/copyright.txt',
))
```
Then make a simple call to run pigeon on the Dart file containing your definitions.

```sh
flutter pub run pigeon --input path/to/input.dart
```

## HostApi Example

This example gives an overview of how to use Pigeon to call into the
host platform from Flutter.

### Dart input

This is the Pigeon file that describes the interface that will be used to call
from Flutter to the host-platform.

<?code-excerpt "pigeons/messages.dart (host-definitions)"?>
```dart
enum Code { one, two }

class MessageData {
  MessageData({required this.code, required this.data});
  String? name;
  String? description;
  Code code;
  Map<String?, String?> data;
}

@HostApi()
abstract class ExampleHostApi {
  String getHostLanguage();

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  @ObjCSelector('addNumber:toNumber:')
  @SwiftFunction('add(_:to:)')
  int add(int a, int b);

  @async
  bool sendMessage(MessageData message);
}
```

### Dart

This is the code that will use the generated Dart code to make calls from Flutter to 
the host platform.

<?code-excerpt "lib/main.dart (main-dart)"?>
```dart
final ExampleHostApi _api = ExampleHostApi();

/// Calls host method `add` with provided arguments.
Future<int> add(int a, int b) async {
  try {
    return await _api.add(a, b);
  } catch (e) {
    // handle error.
    return 0;
  }
}

/// Sends message through host api using `MessageData` class
/// and api `sendMessage` method.
Future<bool> sendMessage(String messageText) {
  final MessageData message = MessageData(
    code: Code.one,
    data: <String?, String?>{'header': 'this is a header'},
    description: 'uri text',
  );
  try {
    return _api.sendMessage(message);
  } catch (e) {
    // handle error.
    return Future<bool>(() => true);
  }
}
```

### Swift

This is the code that will use the generated Swift code to receive calls from Flutter.
packages/pigeon/example/app/ios/Runner/AppDelegate.swift
<?code-excerpt "ios/Runner/AppDelegate.swift (swift-class)"?>
```swift
// This extension of Error is required to do use FlutterError in any Swift code.
extension FlutterError: Error {}

private class PigeonApiImplementation: ExampleHostApi {
  func getHostLanguage() throws -> String {
    return "Swift"
  }

  func add(_ a: Int64, to b: Int64) throws -> Int64 {
    if (a < 0 || b < 0) {
      throw FlutterError(code: "code", message: "message", details: "details");
    }
    return a + b
  }

  func sendMessage(message: MessageData, completion: @escaping (Result<Bool, Error>) -> Void) {
    if (message.code == Code.one) {
      completion(.failure(FlutterError(code: "code", message: "message", details: "details")))
      return
    }
    completion(.success(true))
  }
}
```

### Kotlin
<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt (kotlin-class)"?>
```kotlin
private class PigeonApiImplementation: ExampleHostApi {
  override fun getHostLanguage(): String {
    return "Kotlin"
  }

  override fun add(a: Long, b: Long): Long {
    if (a < 0L || b < 0L) {
      throw FlutterError("code", "message", "details");
    }
    return a + b
  }

  override fun sendMessage(message: MessageData, callback: (Result<Boolean>) -> Unit) {
    if (message.code == Code.ONE) {
      callback(Result.failure(FlutterError("code", "message", "details")))
      return
    }
    callback(Result.success(true))
  }
}
```

### C++
<?code-excerpt "windows/runner/flutter_window.cpp (cpp-class)"?>
```c++
class PigeonApiImplementation : public ExampleHostApi {
 public:
  PigeonApiImplementation() {}
  virtual ~PigeonApiImplementation() {}

  ErrorOr<std::string> GetHostLanguage() override { return "C++"; }
  ErrorOr<int64_t> Add(int64_t a, int64_t b) {
    if (a < 0 || b < 0) {
      return FlutterError("code", "message", "details");
    }
    return a + b;
  }
  void SendMessage(const MessageData& message,
                   std::function<void(ErrorOr<bool> reply)> result) {
    if (message.code == Code.one) {
      result(FlutterError("code", "message", "details"));
      return;
    }
    result(true);
  }
};
```

## FlutterApi Example

This example gives an overview of how to use Pigeon to call into the Flutter
app from the host platform.

### Dart input

<?code-excerpt "pigeons/messages.dart (flutter-definitions)"?>
```dart
@FlutterApi()
abstract class MessageFlutterApi {
  String flutterMethod(String? aString);
}
```

### Dart

This is the code that will use the generated Dart code to handle calls made to 
Flutter from the host platform.

<?code-excerpt "lib/main.dart (main-dart-flutter)"?>
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

### Swift

<?code-excerpt "ios/Runner/AppDelegate.swift (swift-class-flutter)"?>
```swift
private class PigeonFlutterApi {
  var flutterAPI: MessageFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = MessageFlutterApi(binaryMessenger: binaryMessenger)
  }

  func callFlutterMethod(aString aStringArg: String?, completion: @escaping (Result<String, Error>) -> Void) {
    flutterAPI.flutterMethod(aString: aStringArg) {
      completion(.success($0))
    }
  }
}
```

### Kotlin

<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt (kotlin-class-flutter)"?>
```kotlin
private class PigeonFlutterApi {

  var flutterApi: MessageFlutterApi? = null

  constructor(binding: FlutterPlugin.FlutterPluginBinding) {
    flutterApi = MessageFlutterApi(binding.getBinaryMessenger())
  }

  fun callFlutterMethod(aString: String, callback: (Result<String>) -> Unit) {
    flutterApi!!.flutterMethod(aString) {
      echo -> callback(Result.success(echo))
    }
  }
}
```

### C++

<?code-excerpt "windows/runner/flutter_window.cpp (cpp-method-flutter)"?>
```c++
void TestPlugin::CallFlutterMethod(
    String aString, std::function<void(ErrorOr<int64_t> reply)> result) {
  MessageFlutterApi->FlutterMethod(
      aString, [result](String echo) { result(echo); },
      [result](const FlutterError& error) { result(error); });
}
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
