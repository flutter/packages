# Pigeon

Pigeon is a code generator tool to make communication between Flutter and the
host platform type-safe, easier, and faster.

Pigeon removes the necessity to manage strings across multiple platforms and languages.
It also improves efficiency over common method channel patterns. Most importantly though,
it removes the need to write custom platform channel code, since pigeon generates it for you.

For usage examples, see the [Example README](./example/README.md).

## Features

### Supported Platforms

Currently pigeon supports generating:
* Kotlin and Java code for Android
* Swift and Objective-C code for iOS and macOS
* C++ code for Windows
* GObject code for Linux

### Supported Datatypes

Pigeon uses the `StandardMessageCodec` so it supports
[any datatype platform channels support](https://flutter.dev/to/platform-channels-codec).

Custom classes, nested datatypes, and enums are also supported.

Basic inheritance with empty `sealed` parent classes is allowed only in the Swift, Kotlin, and Dart generators.

Nullable enums in Objective-C generated code will be wrapped in a class to allow for nullability.

By default, custom classes in Swift are defined as structs.
Structs don't support some features - recursive data, or Objective-C interop.
Use the @SwiftClass annotation when defining the class to generate the data
as a Swift class instead.

### Synchronous and Asynchronous methods

While all calls across platform channel APIs (such as pigeon methods) are asynchronous,
pigeon methods can be written on the native side as synchronous methods,
to make it simpler to always reply exactly once.

If asynchronous methods are needed, the `@async` annotation can be used. This will require
results or errors to be returned via a provided callback. [Example](./example/README.md#HostApi_Example). 

If preferred, Swift concurrency and Kotlin coroutines may be generated instead of callbacks by using `@Async`. Additionally, whether the Swift method can throw an exception can be specified using the `isSwiftThrows` parameter. [Example](./example/README.md#HostApi_Example).

### Error Handling

#### Kotlin, Java and Swift

All Host API exceptions are translated into Flutter `PlatformException`.
* For synchronous methods, thrown exceptions will be caught and translated.
* For asynchronous methods, there is no default exception handling; errors
should be returned via the provided callback.

To pass custom details into `PlatformException` for error handling,
use `FlutterError` in your Host API. [Example](./example/README.md#HostApi_Example).

For swift, use `PigeonError` instead of `FlutterError` when throwing an error. See [Example#Swift](./example/README.md#Swift) for more details.

#### Objective-C and C++

Host API errors can be sent using the provided `FlutterError` class (translated into `PlatformException`).

For synchronous methods:
* Objective-C - Set the `error` argument to a `FlutterError` reference.
* C++ - Return a `FlutterError`.

For async methods:
* Return a `FlutterError` through the provided callback.


### Task Queue

When targeting a Flutter version that supports the
[TaskQueue API](https://docs.flutter.dev/development/platform-integration/platform-channels?tab=type-mappings-kotlin-tab#channels-and-platform-threading)
the threading model for handling HostApi methods can be selected with the
`TaskQueue` annotation.

### Multi-Instance Support

Host and Flutter APIs now support the ability to provide a unique message channel suffix string
to the api to allow for multiple instances to be created and operate in parallel.

## Usage

1) Add pigeon as a `dev_dependency`.
1) Make a ".dart" file outside of your "lib" directory for defining the
   communication interface.
1) Run pigeon on your ".dart" file to generate the required Dart and
   host-language code: `flutter pub get` then `dart run pigeon`
   with suitable arguments. [Example](./example/README.md#Invocation).
1) Add the generated Dart code to `./lib` for compilation.
1) Implement the host-language code and add it to your build (see below).
1) Call the generated Dart methods.

### Rules for defining your communication interface
[Example](./example/README.md#HostApi_Example)

1) The file should contain no method or function definitions, only declarations.
1) Custom classes used by APIs are defined as classes with fields of the
   supported datatypes (see the supported Datatypes section).
1) APIs should be defined as an `abstract class` with either `@HostApi()` or
   `@FlutterApi()` as metadata.  `@HostApi()` being for procedures that are defined
   on the host platform and the `@FlutterApi()` for procedures that are defined in Dart.
1) Method declarations on the API classes should have arguments and a return
   value whose types are defined in the file, are supported datatypes, or are
   `void`.
1) Event channels are supported only on the Swift, Kotlin, and Dart generators.
1) Event channel methods should be wrapped in an `abstract class` with the metadata `@EventChannelApi`.
1) Event channel definitions should not include the `Stream` return type, just the type that is being streamed.
1) Objective-C and Swift have special naming conventions that can be utilized with the
   `@ObjCSelector` and `@SwiftFunction` respectively.

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

### Flutter calling into Linux steps

1) Add the generated GObject code to your `./linux` directory for compilation, and
   to your `linux/CMakeLists.txt` file.
1) Implement the generated protocol for handling the calls on Linux, set it up
   as the vtable for the API object.

### Calling into Flutter from the host platform

Pigeon also supports calling in the opposite direction. The steps are similar
but reversed.  For more information look at the annotation `@FlutterApi()` which
denotes APIs that live in Flutter but are invoked from the host platform.
[Example](./example/README.md#FlutterApi_Example).

## Stability of generated code

Pigeon is intended to replace direct use of method channels in the internal
implementation of plugins and applications. Because the expected use of Pigeon
is as an internal implementation detail, its development strongly favors
improvements to generated code over consistency with previous generated code,
so breaking changes in generated code are common.

As a result, using Pigeon-generated code in public APIs is
**strongy discouraged**, as doing so will likely create situations where you are
unable to update to a new version of Pigeon without causing breaking changes
for your clients.

### Inter-version compatibility

The generated message channel code used for Pigeon communication is an
internal implementation detail of Pigeon that is subject to change without
warning, and changes to the communication are *not* considered breaking changes.
Both sides of the communication (the Dart code and the host-language code)
must be generated with the **same version** of Pigeon. Using code generated with
different versions has undefined behavior, including potentially crashing the
application.

This means that Pigeon-generated code **should not** be split across packages.
For example, putting the generated Dart code in a platform interface package
and the generated host-language code in a platform implementation package is
very likely to cause crashes for some plugin clients after updates.

## Feedback

File an issue in [flutter/flutter](https://github.com/flutter/flutter) with
"[pigeon]" at the start of the title.
