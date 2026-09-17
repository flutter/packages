---
name: pigeon
description: Set up and use Pigeon to generate type-safe communication code between Flutter Dart and host platforms (Android Kotlin/Java, iOS/macOS Swift/Objective-C, Windows C++, Linux C++/GObject).
---

# Setting Up and Using Pigeon

Pigeon is a code generator tool that makes communication between Flutter (Dart) and the host platform (Android, iOS, macOS, Windows, Linux) type-safe, structured, and boilerplate-free. It eliminates manual string-based method channel parsing and supports both Platform Channels and direct Native Interop (FFI/JNI).

## 1. Installation

Add `pigeon` as a `dev_dependency` in your plugin or application `pubspec.yaml`:

```bash
flutter pub add dev:pigeon
```

## 2. Create a Pigeon Schema File

Create a `pigeons/` directory at the root of your package and add a Dart definition file (e.g., `pigeons/messages.dart`).

A Pigeon file defines:
1. `@ConfigurePigeon(...)`: Output paths and language-specific options.
2. Data classes and enums passed between Dart and native code.
3. `@HostApi()`: Interfaces implemented on the host platform and called from Dart.
4. `@FlutterApi()`: Interfaces implemented in Dart and called from the host platform.
5. `@ProxyApi()` (Optional): Wrapper APIs around native platform classes with automatic instance management.

### Example `pigeons/messages.dart`

```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut: 'android/src/main/kotlin/com/example/my_plugin/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.my_plugin'),
    swiftOut: 'ios/Classes/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    cppHeaderOut: 'windows/runner/messages.g.h',
    cppSourceOut: 'windows/runner/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'my_plugin'),
    gobjectHeaderOut: 'linux/messages.g.h',
    gobjectSourceOut: 'linux/messages.g.cc',
    gobjectOptions: GObjectOptions(),
  ),
)
enum SearchState {
  pending,
  success,
  error,
}

class SearchRequest {
  SearchRequest({required this.query, this.limit});
  String query;
  int? limit;
}

class SearchReply {
  SearchReply({required this.result, required this.state});
  String result;
  SearchState state;
}

@HostApi()
abstract class SearchHostApi {
  SearchReply searchSync(SearchRequest request);

  @async
  SearchReply searchAsync(SearchRequest request);
}

@FlutterApi()
abstract class SearchFlutterApi {
  void onSearchStateChanged(SearchState state);
}
```

## 3. Run the Code Generator

Run Pigeon from the root of your package to generate the Dart and native code:

```bash
dart run pigeon --input pigeons/messages.dart
```

> **Rule**: Never manually edit `.g.dart`, `.g.kt`, `.g.swift`, `.g.h`, or `.g.cc` files. Always update the `pigeons/*.dart` schema and re-run the generator.

## 4. Implement Host Platform APIs

### Android (Kotlin)
Implement the generated `SearchHostApi` interface and register it with the `BinaryMessenger` in your plugin's `onAttachedToEngine`:

```kotlin
class MyPlugin : FlutterPlugin, SearchHostApi {
  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    SearchHostApi.setUp(binding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    SearchHostApi.setUp(binding.binaryMessenger, null)
  }

  override fun searchSync(request: SearchRequest): SearchReply {
    return SearchReply(result = "Found: ${request.query}", state = SearchState.SUCCESS)
  }

  override fun searchAsync(request: SearchRequest, callback: (Result<SearchReply>) -> Unit) {
    callback(Result.success(SearchReply(result = "Async: ${request.query}", state = SearchState.SUCCESS)))
  }
}
```

### iOS / macOS (Swift)
Implement the generated `SearchHostApi` protocol and register it in your plugin's `register(with:)`:

```swift
public class MyPlugin: NSObject, FlutterPlugin, SearchHostApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = MyPlugin()
    SearchHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
  }

  func searchSync(request: SearchRequest) throws -> SearchReply {
    return SearchReply(result: "Found: \(request.query)", state: .success)
  }

  func searchAsync(request: SearchRequest, completion: @escaping (Result<SearchReply, Error>) -> Void) {
    completion(.success(SearchReply(result: "Async: \(request.query)", state: .success)))
  }
}
```

## 5. Call the Generated API from Dart

Import the generated `messages.g.dart` file and instantiate `SearchHostApi`:

```dart
import 'src/messages.g.dart';

class MySearchClient {
  final SearchHostApi _api = SearchHostApi();

  Future<String> performSearch(String query) async {
    final SearchReply reply = await _api.searchAsync(
      SearchRequest(query: query, limit: 10),
    );
    return reply.result;
  }
}
```

To receive host-to-Dart calls via `@FlutterApi()`, implement `SearchFlutterApi` and register it:

```dart
class _MyFlutterApiHandler extends SearchFlutterApi {
  @override
  void onSearchStateChanged(SearchState state) {
    // Handle state update from native host
  }
}

void initCallbacks() {
  SearchFlutterApi.setUp(_MyFlutterApiHandler());
}
```
