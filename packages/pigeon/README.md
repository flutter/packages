# Pigeon

// TODO: how to frame this?
// To get started, see the Quickstart Guide in the [Example README](./example/README.md).

Pigeon is a code generator tool to make communication between Flutter and the
host platform type-safe, easier, and faster.

Pigeon works by reading a special file or files, which are placed outside of the
`/lib` directory which hosts all of your application code. You define special
data classes and endpoints, which Pigeon will then consume and use to generate
matching Dart and native code at the paths you specify.

Internally, the generated code uses `MethodChannel`s to communicate between Flutter's
UI thread and the Platform thread where your host app is initially launched. The value
in Pigeon comes from automatically keeping this unpleasant boilerplate in sync and
efficiently marshalling data between languages.

The generated code can either flow from Dart to native code, or native code back
to Dart. Generated code on the receiving end uses interfaces or abstract classes,
allowing you to provide implementations in concrete classes.

Pigeon works in both complete Flutter apps and hybrid apps using the add-to-app paradigm.

## Quickstart

### Installation

Begin by adding Pigeon to your Dart project's `pubspec.yaml` file:

```sh
$ flutter pub add pigeon --dev
$ flutter pub get
```

### Setup

To specify what code Pigeon should generate, create your interface definition file.
This guide will place all such definitions at `/pigeons/messages.dart`, but you
are free to choose any file name you like, inside a dedicated folder or not.

Begin by instantiating a `PigeonOptions` object, wrapped in the `@ConfigurePigeon`
decorator. Later, you will pass named parameters to your `PigeonOptions` object
to specify your desired behavior.

```dart
// pigeons/messages.dart

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions()
);
```

### Define your messages

The next step to use Pigeon is to define the data structures Dart will exchange
with native code. You do this by writing plain Dart enums or classes in your
definition file. These messages should only contain simple constructors and direct
attributes. Methods, factory constructors, constructor bodies, and computed
properties are all not allowed.

```dart
// pigeons/messages.dart

enum Code { a, b }

class MessageData {
  MessageData({required this.code, required this.data});
  String? name;
  String? description;
  Code code;
  Map<String, String> data;
}
```

No extra steps are necessary to register these classes - their inclusion
in your definitions file ensures Pigeon will generate matching Dart and native
implementations.

### Define which methods to expose

The point of Pigeon and the `MethodChannel`s it utilizes is to call native functions
living on the Platform thread from Dart, or to call Dart functions living on the UI
thread from native code. Either way, you must declare methods in your definitions
file which tell Pigeon what function signatures its generated code must support.

#### Call native code from Dart

To expose a native function to be called from Dart, write an abstract class in
your Pigeon file and mark it with `@HostApi()`.

```dart
// pigeons/messages.dart

@HostApi()
abstract class ExampleHostApi {
   String getHostLanguage();
   int add(int a, int b);

   @async
   void sendMessage(MessageData message);
}
```

> Note: For more information on the `@async` decorator, see the [section on
> asynchronous](#Synchronous-and-Asynchronous-methods) methods below.

Later, the Pigeon generator will produce a matching interface in native code and
you will register a concrete implementation. This concrete version of the class
will be where you either perform the necessary native operations or call out to
other native libraries.

#### Call Dart code from native

To expose a Dart function to your app's native code, write an abstract class in
your Pigeon file and mark it with `@FlutterApi()`.

```dart
// pigeons/messages.dart

@FlutterApi()
abstract class MessageFlutterApi {
   String flutterMethod(String? aString);
}
```

Later, you will register a concrete implementation of this Dart abstract class, but
for now this is enough for you to run the generator. The concrete class you supply
will be the bridge to the rest of your application's business logic.

### Configure your output

It is time to pass values to the `PigeonOptions` object to configure your desired
behavior. To begin, specify a `dartOut` value where your Dart code should live and,
optionally, a `DartOptions` instance.

```dart
@ConfigurePigeon(
   PigeonOptions(
      dartOut: 'lib/src/messages.g.dart',
      dartOptions: DartOptions(), // Optional
   ),
)
```
Next, add sections for each native platform your app should support.

> Note: The paths to your native projects can vary depending on whether your
> app is entirely Flutter, or whether you are adding Flutter into an existing
> native app. These code paths will assume your app is entirely Flutter, but
> add-to-app users should see the [`Add to app usage`](Add-to-app-usage)
> section for specific guidance.


#### Add iOS and/or macOS support

To instruct Pigeon to generate Swift code for your app on iOS, provide a path
for the `swiftOut` parameter and, optionally, a `SwiftOptions` instance.

```dart
@ConfigurePigeon(
   PigeonOptions(
      ...
      swiftOut: 'ios/Runner/Messages.g.swift',
      swiftOptions: SwiftOptions(), // Optional
   ),
)
```

To instruct Pigeon to generate Objective-C code for your app on iOS, provide paths
for the `objcHeaderOut` and `objcSourceOut` parameters and, optionally, an
`ObjcOptions` instance.

```dart
@ConfigurePigeon(
   PigeonOptions(
      ...
      objcHeaderOut: 'ios/Runner/Messages.g.h',
      objcSourceOut: 'ios/Runner/Messages.g.m',
      // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
      objcOptions: ObjcOptions(prefix: 'PGN'),
   ),
)
```

> Note: Pigeon generates code on a per-language basis, not a per-platform basis.
> This is important for Pigeon to support all the platforms Flutter will build
> to in the future, but it does introduce a wrinkle if you want the same definitions
> generated for two different platforms; e.g., Swift code on iOS and macOS. To
> achieve this, you can either symlink your iOS files into your macOS directory,
> or you can use a separate Pigeon file (e.g., `/pigeons/macos_messages.dart`)
> which specifies macOS paths (e.g., `macos/Runner/Messages.g.swift`).

#### Add Android support

To instruct Pigeon to generate Kotlin code for your app on Android, provide a path
for the `kotlinOut` parameter and, optionally, a `KotlinOptions` instance.

```dart
@ConfigurePigeon(
   PigeonOptions(
      ...
      kotlinOut: 'android/app/src/main/kotlin/dev/flutter/my_app_name/Messages.g.kt',
      kotlinOptions: KotlinOptions(), // Optional
   ),
)
```

To instruct Pigeon to generate Java code for your app on Android, provide a path
for the `javaOut` parameter and, optionally, a `JavaOptions` instance.

```dart
@ConfigurePigeon(
   PigeonOptions(
      ...
      javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
      javaOptions: JavaOptions(), // Optional
   ),
)
```

#### Add Windows support

To instruct Pigeon to generate C++ code for your app on Windows, provide paths
for the `cppHeaderOut` and `cppSourceOut` parameters and, optionally, a
`CppOptions` instance.

```dart
@ConfigurePigeon(
   PigeonOptions(
      ...
      cppHeaderOut: 'windows/runner/messages.g.h',
      cppSourceOut: 'windows/runner/messages.g.cpp',
      cppOptions: CppOptions(namespace: 'pigeon_example'),
   ),
)
```

#### Add Linux support

To instruct Pigeon to generate GObject code for your app on Linux, provide paths
for the `gobjectHeaderOut` and `gobjectSourceOut` parameters and, optionally, a
`GObjectOptions` instance.

```dart
@ConfigurePigeon(
   PigeonOptions(
      ...
      gobjectHeaderOut: 'linux/messages.g.h',
      gobjectSourceOut: 'linux/messages.g.cc',
      gobjectOptions: GObjectOptions(),
   ),
)
```

#### A note on Web support

Pigeon does not support the Web because Flutter apps compiled to the Web can
already directly call any JavaScript code without switching threads, as is
currently required in Flutter on mobile or desktop. Pigeon generates code which
performs two roles:

1. Using Flutter's `MethodChannel`s concept to jump from the UI thread to the
Platform thread (or in the other direction), and
2. Marshalling data between Dart and the native language.

Flutter Web apps intrinsically do not encounter the first problem and only
encounter a form of the second problem if you need to interface with a
library's `d.ts` interface. In this case, you may need to author custom Dart
classes which match those TypeScript definitions. Check pub.dev for existing solutions.

### Run the builder

Once your Pigeon files define any data classes and functions you wish to invoke,
you can run the builder:

```sh
$ dart run pigeon --input pigeons/messages.dart
```

### Use the generated code

You should now see matching output files at the locations you specified in your
`PigeonOptions` instance, or in your command line arguments. The two primary
scenarios to explore are calling native code from Dart and calling Dart code from
native.

#### Calling native code from Dart

The sample code in this Quickstart defines an example native API named `ExampleHostApi`.
Pigeon will generate a complete Dart implementation and the equivalent of an abstract
class in each native language (for example, a `protocol` in Swift and an `interface`
in Kotlin).

See the [language-specific guides](example/README.md#HostApi-Example) for help instantiating the native classes
generated by Pigeon.

In Dart, typical use within a `StatefulWidget` might look like this:

```dart
late final ExampleHostApi;

@override
void initState() {
   _hostApi = ExampleHostApi();
   super.initState();
}

Future<String> getHostLanguage() async 
   => _hostApi.getHostLanguage();

Future<int> add(int a, int b) async
   => _hostApi.add(a, b);

Future<void> sendMessage(MessageData message) async
   => _hostApi.sendMessage(message);
```

#### Calling Dart code from native

The sample code in this Quickstart defined an example Dart API named `MessageFlutterApi`.
Define a concrete implementation of this abstract class with your real business logic:

```dart
class _MessageFlutterApi implements MessageFlutterApi {
  @override
  String flutterMethod(String? aString) => aString ?? '';
}
```

Next, register your implementation with the `MessageChannel` harness that Pigeon
generated. You must complete this call to `setUp` before invoking the
`flutterMethod` method from your native code.

```dart
MessageFlutterApi.setUp(_MessageFlutterApi());
```

Pigeon will have generated a native implementation of `MessageFlutterApi` in your
designated languages and files, and you should now be ready to instantiate that
class and invoke its methods. See the language-specific sections below for help
instantiating the native classes generated by Pigeon.

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
1) Generics are supported, but can currently only be used with nullable types
   (example: `List<int?>`).
1) Objc and Swift have special naming conventions that can be utilized with the
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

## Feedback

File an issue in [flutter/flutter](https://github.com/flutter/flutter) with 
"[pigeon]" at the start of the title.
