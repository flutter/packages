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
  gobjectHeaderOut: 'linux/messages.g.h',
  gobjectSourceOut: 'linux/messages.g.cc',
  gobjectOptions: GObjectOptions(),
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
  dartPackageName: 'pigeon_example_package',
))
```
Then make a simple call to run pigeon on the Dart file containing your definitions.

```sh
dart run pigeon --input path/to/input.dart
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
  Map<String, String> data;
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
    data: <String, String>{'header': 'this is a header'},
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
Unlike other languages, when throwing an error, use `PigeonError` instead of `FlutterError`, as `FlutterError` does not conform to `Swift.Error`.
<?code-excerpt "ios/Runner/AppDelegate.swift (swift-class)"?>
```swift
private class PigeonApiImplementation: ExampleHostApi {
  func getHostLanguage() throws -> String {
    return "Swift"
  }

  func add(_ a: Int64, to b: Int64) throws -> Int64 {
    if a < 0 || b < 0 {
      throw PigeonError(code: "code", message: "message", details: "details")
    }
    return a + b
  }

  func sendMessage(message: MessageData, completion: @escaping (Result<Bool, Error>) -> Void) {
    if message.code == Code.one {
      completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
      return
    }
    completion(.success(true))
  }
}
```

### Kotlin
<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt (kotlin-class)"?>
```kotlin
private class PigeonApiImplementation : ExampleHostApi {
  override fun getHostLanguage(): String {
    return "Kotlin"
  }

  override fun add(a: Long, b: Long): Long {
    if (a < 0L || b < 0L) {
      throw FlutterError("code", "message", "details")
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
    if (message.code() == Code::kOne) {
      result(FlutterError("code", "message", "details"));
      return;
    }
    result(true);
  }
};
```

### GObject
<?code-excerpt "linux/my_application.cc (vtable)"?>
```c++
static PigeonExamplePackageExampleHostApiGetHostLanguageResponse*
handle_get_host_language(gpointer user_data) {
  return pigeon_example_package_example_host_api_get_host_language_response_new(
      "C++");
}

static PigeonExamplePackageExampleHostApiAddResponse* handle_add(
    int64_t a, int64_t b, gpointer user_data) {
  if (a < 0 || b < 0) {
    g_autoptr(FlValue) details = fl_value_new_string("details");
    return pigeon_example_package_example_host_api_add_response_new_error(
        "code", "message", details);
  }

  return pigeon_example_package_example_host_api_add_response_new(a + b);
}

static void handle_send_message(
    PigeonExamplePackageMessageData* message,
    PigeonExamplePackageExampleHostApiResponseHandle* response_handle,
    gpointer user_data) {
  PigeonExamplePackageCode code =
      pigeon_example_package_message_data_get_code(message);
  if (code == PIGEON_EXAMPLE_PACKAGE_CODE_ONE) {
    g_autoptr(FlValue) details = fl_value_new_string("details");
    pigeon_example_package_example_host_api_respond_error_send_message(
        response_handle, "code", "message", details);
    return;
  }

  pigeon_example_package_example_host_api_respond_send_message(response_handle,
                                                               TRUE);
}

static PigeonExamplePackageExampleHostApiVTable example_host_api_vtable = {
    .get_host_language = handle_get_host_language,
    .add = handle_add,
    .send_message = handle_send_message};
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
  MessageFlutterApi.setUp(_ExampleFlutterApi());
```

### Swift

<?code-excerpt "ios/Runner/AppDelegate.swift (swift-class-flutter)"?>
```swift
private class PigeonFlutterApi {
  var flutterAPI: MessageFlutterApi

  init(binaryMessenger: FlutterBinaryMessenger) {
    flutterAPI = MessageFlutterApi(binaryMessenger: binaryMessenger)
  }

  func callFlutterMethod(
    aString aStringArg: String?, completion: @escaping (Result<String, PigeonError>) -> Void
  ) {
    flutterAPI.flutterMethod(aString: aStringArg) {
      completion($0)
    }
  }
}
```

### Kotlin

<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt (kotlin-class-flutter)"?>
```kotlin
private class PigeonFlutterApi(binding: FlutterPlugin.FlutterPluginBinding) {
  var flutterApi: MessageFlutterApi? = null

  init {
    flutterApi = MessageFlutterApi(binding.binaryMessenger)
  }

  fun callFlutterMethod(aString: String, callback: (Result<String>) -> Unit) {
    flutterApi!!.flutterMethod(aString) { echo -> callback(echo) }
  }
}
```

### C++

<?code-excerpt "windows/runner/flutter_window.cpp (cpp-method-flutter)"?>
```c++
class PigeonFlutterApi {
 public:
  PigeonFlutterApi(flutter::BinaryMessenger* messenger)
      : flutterApi_(std::make_unique<MessageFlutterApi>(messenger)) {}

  void CallFlutterMethod(
      const std::string& a_string,
      std::function<void(ErrorOr<std::string> reply)> result) {
    flutterApi_->FlutterMethod(
        &a_string, [result](const std::string& echo) { result(echo); },
        [result](const FlutterError& error) { result(error); });
  }

 private:
  std::unique_ptr<MessageFlutterApi> flutterApi_;
};
```

### GObject

<?code-excerpt "linux/my_application.cc (flutter-method-callback)"?>
```c++
static void flutter_method_cb(GObject* object, GAsyncResult* result,
                              gpointer user_data) {
  g_autoptr(GError) error = nullptr;
  g_autoptr(
      PigeonExamplePackageMessageFlutterApiFlutterMethodResponse) response =
      pigeon_example_package_message_flutter_api_flutter_method_finish(
          PIGEON_EXAMPLE_PACKAGE_MESSAGE_FLUTTER_API(object), result, &error);
  if (response == nullptr) {
    g_warning("Failed to call Flutter method: %s", error->message);
    return;
  }

  g_printerr(
      "Got result from Flutter method: %s\n",
      pigeon_example_package_message_flutter_api_flutter_method_response_get_return_value(
          response));
}
```

<?code-excerpt "linux/my_application.cc (flutter-method)"?>
```c++
self->flutter_api =
    pigeon_example_package_message_flutter_api_new(messenger, nullptr);
pigeon_example_package_message_flutter_api_flutter_method(
    self->flutter_api, "hello", nullptr, flutter_method_cb, self);
```

## Event Channel Example

This example gives a basic overview of how to use Pigeon to set up an event channel.

### Dart input

<?code-excerpt "pigeons/event_channel_messages.dart (event-definitions)"?>
```dart
@EventChannelApi()
abstract class EventChannelMethods {
  PlatformEvent streamEvents();
}
```

### Dart

The generated Dart code will include a method that returns a `Stream` when invoked. 

<?code-excerpt "lib/main.dart (main-dart-event)"?>
```dart
Stream<String> getEventStream() async* {
  final Stream<PlatformEvent> events = streamEvents();
  await for (final PlatformEvent event in events) {
    switch (event) {
      case IntEvent():
        final int intData = event.data;
        yield '$intData, ';
      case StringEvent():
        final String stringData = event.data;
        yield '$stringData, ';
    }
  }
}
```

### Swift

Define the stream handler class that will handle the events.

<?code-excerpt "ios/Runner/AppDelegate.swift (swift-class-event)"?>
```swift
class EventListener: StreamEventsStreamHandler {
  var eventSink: PigeonEventSink<PlatformEvent>?

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<PlatformEvent>) {
    eventSink = sink
  }

  func onIntEvent(event: Int64) {
    if let eventSink = eventSink {
      eventSink.success(IntEvent(data: event))
    }
  }

  func onStringEvent(event: String) {
    if let eventSink = eventSink {
      eventSink.success(StringEvent(data: event))
    }
  }

  func onEventsDone() {
    eventSink?.endOfStream()
    eventSink = nil
  }
}
```

Register the handler with the generated method.

<?code-excerpt "ios/Runner/AppDelegate.swift (swift-init-event)"?>
```swift
let eventListener = EventListener()
StreamEventsStreamHandler.register(
  with: controller.binaryMessenger, streamHandler: eventListener)
```

### Kotlin

Define the stream handler class that will handle the events.

<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt (kotlin-class-event)"?>
```kotlin
class EventListener : StreamEventsStreamHandler() {
  private var eventSink: PigeonEventSink<PlatformEvent>? = null

  override fun onListen(p0: Any?, sink: PigeonEventSink<PlatformEvent>) {
    eventSink = sink
  }

  fun onIntEvent(event: Long) {
    eventSink?.success(IntEvent(data = event))
  }

  fun onStringEvent(event: String) {
    eventSink?.success(StringEvent(data = event))
  }

  fun onEventsDone() {
    eventSink?.endOfStream()
    eventSink = null
  }
}
```


Register the handler with the generated method.

<?code-excerpt "android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt (kotlin-init-event)"?>
```kotlin
val eventListener = EventListener()
StreamEventsStreamHandler.register(flutterEngine.dartExecutor.binaryMessenger, eventListener)
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
