# Pigeon
<?code-excerpt path-base="excerpts/packages/pigeon_example"?>

Pigeon is a code generator tool to make communication between Flutter and the
host platform type-safe, easier, and faster.

Pigeon removes the necessity to manage platform channel names as strings across multiple platforms and languages.
It it also improves efficiency over standard data encoding across platform channels.
Most importantly though, it removes the need to write custom platform channel code and codecs,
since Pigeon generates all of that code for you.

For examples on usage, see the [Example README](./example/README.md).

## Features

### Supported Platforms

Currently Pigeon supports generating:
* Kotlin and Java code for Android,
* Swift and Objective-C code for iOS
* Swift code for macOS
* C++ code for Windows

### Supported Datatypes

Pigeon uses the `StandardMessageCodec` so it supports any datatype Platform
Channels supports
[[documentation](https://flutter.dev/docs/development/platform-integration/platform-channels#codec)].

Custom Classes and Nested datatypes are also supported.

### Enums

Pigeon supports enum generation in class fields only. [Example.](./example/README.md#Enums)

### Synchronous and Asynchronous methods

While all calls across platform channel apis (such as Pigeon methods) are asynchronous,
standard Pigeon methods can be treated as synchronous when handling returns and error.

If asynchronous methods are needed, the `@async` annotation can be used. This will require 
results or errors to be returned via a provided callback. [Example.](./example/README.md#Async)

### Error Handling

#### Kotlin, Java and Swift

All Host API exceptions are translated into Flutter `PlatformException`.
* For synchronous methods, thrown exceptions will be caught and translated.
* For asynchronous methods, there is no default exception handling; errors should be returned via the provided callback.

To pass custom details into `PlatformException` for error handling, use `FlutterError` in your Host API. [Example.](./example/README.md#Error-Handling)

#### Objective-C and C++

Likewise, Host API errors can be sent using the provided `FlutterError` class (translated into `PlatformException`).

For synchronous methods:
* Objective-C - Assign the `error` argument to a `FlutterError` reference.
* C++ - Return a `FlutterError` directly (for void methods) or within an `ErrorOr` instance.

For async methods:
* Return a `FlutterError` through the provided callback.


### Task Queue

When targeting a Flutter version that supports the
[TaskQueue API](https://docs.flutter.dev/development/platform-integration/platform-channels?tab=type-mappings-kotlin-tab#channels-and-platform-threading)
the threading model for handling HostApi methods can be selected with the
`TaskQueue` annotation. [Example.](./example/README.md#Task-Queue)

## Usage

1) Add Pigeon as a `dev_dependency`.
1) Make a ".dart" file outside of your "lib" directory for defining the
   communication interface.
1) Run Pigeon on your ".dart" file to generate the required Dart and
   host-language code: `flutter pub get` then `flutter pub run Pigeon`
   with suitable arguments.  [Example.](./example/README.md#Invocation).
1) Add the generated Dart code to `./lib` for compilation.
1) Implement the host-language code and add it to your build (see below).
1) Call the generated Dart methods.

### Rules for defining your communication interface

1) The file should contain no method or function definitions, only declarations.
1) Custom classes used by APIs are defined as classes with fields of the
   supported datatypes (see the supported Datatypes section).
1) APIs should be defined as an `abstract class` with either `@HostApi()` or
   `@FlutterApi()` as metadata.  `@HostApi()` being for procedures that are defined
   on the host platform and the `@FlutterApi()` for procedures that are defined in Dart.
1) Method declarations on the API classes should have arguments and a return
   value whose types are defined in the file, are supported datatypes, or are
   `void`.
1) Generics are supported, but can currently only be used with nullable types
   (example: `List<int?>`).

### Flutter calling into iOS steps

1) Add the generated Objective-C or Swift code to your Xcode project for compilation
   (e.g. `ios/Runner.xcworkspace` or `.podspec`).
1) Implement the generated protocol for handling the calls on iOS, set it up
   as the handler for the messages.

### Flutter calling into Android Steps

1) Add the generated Java or Kotlin code to your `./android/app/src/main/java` directory
   for compilation.
1) Implement the generated Java or Kotlin interface for handling the calls on Android, set
   it up as the handler for the messages.

### Flutter calling into Windows Steps

1) Add the generated C++ code to your `./windows` directory for compilation, and
   to your `windows/CMakeLists.txt` file.
1) Implement the generated C++ abstract class for handling the calls on Windows,
   set it up as the handler for the messages.

### Flutter calling into macOS steps

1) Add the generated Objective-C or Swift code to your Xcode project for compilation
   (e.g. `macos/Runner.xcworkspace` or `.podspec`).
1) Implement the generated protocol for handling the calls on macOS, set it up
   as the handler for the messages.

### Calling into Flutter from the host platform

Flutter also supports calling in the opposite direction.  The steps are similar
but reversed.  For more information look at the annotation `@FlutterApi()` which
denotes APIs that live in Flutter but are invoked from the host platform. 
[Example](./example/README.md#Flutter-Api).

## Feedback

File an issue in [flutter/flutter](https://github.com/flutter/flutter) with 
"[Pigeon]" at the start of the title.
