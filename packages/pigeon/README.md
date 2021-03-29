# Pigeon

**Warning: Pigeon is prerelease, breaking changes may occur.**

Pigeon is a code generator tool to make communication between Flutter and the
host platform type-safe and easier.

## Supported Platforms

Currently Pigeon only supports generating Objective-C code for usage on iOS and
Java code for Android.  The Objective-C code is
[accessible to Swift](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift)
and the Java code is accessible to Kotlin.

## Runtime Requirements

Pigeon generates all the code that is needed to communicate between Flutter and
the host platform, there is no extra runtime requirement.  A plugin author
doesn't need to worry about conflicting versions of Pigeon.

## Usage

### Flutter calling into iOS Steps

1) Add Pigeon as a dev_dependency.
1) Make a ".dart" file outside of your "lib" directory for defining the communication interface.
1) Run pigeon on your ".dart" file to generate the required Dart and Objective-C code:
   `flutter pub get` then `flutter pub run pigeon` with suitable arguments.
1) Add the generated Dart code to `lib` for compilation.
1) Add the generated Objective-C code to your Xcode project for compilation
   (e.g. `ios/Runner.xcworkspace` or `.podspec`).
1) Implement the generated iOS protocol for handling the calls on iOS, set it up
   as the handler for the messages.
1) Call the generated Dart methods.

### Flutter calling into Android Steps

1) Add Pigeon as a dev_dependency.
1) Make a ".dart" file outside of your "lib" directory for defining the communication interface.
1) Run pigeon on your ".dart" file to generate the required Dart and Java code.
   `flutter pub get` then `flutter pub run pigeon` with suitable arguments.
1) Add the generated Dart code to `./lib` for compilation.
1) Add the generated Java code to your `./android/app/src/main/java` directory for compilation.
1) Implement the generated Java interface for handling the calls on Android, set it up
   as the handler for the messages.
1) Call the generated Dart methods.

### Rules for defining your communication interface

1) The file should contain no method or function definitions, only declarations.
1) Datatypes are defined as classes with fields of the supported datatypes (see
   the supported Datatypes section).
1) Api's should be defined as an `abstract class` with either `HostApi()` or
   `FlutterApi()` as metadata.  The former being for procedures that are defined
   on the host platform and the latter for procedures that are defined in Dart.
1) Method declarations on the Api classes should have one argument and a return
   value whose types are defined in the file or be `void`.

## Example

See the "Example" tab.  A full working example can also be found in the
[video_player plugin](https://github.com/flutter/plugins/tree/master/packages/video_player).

## Supported Datatypes

Pigeon uses the `StandardMessageCodec` so it supports any data-type platform
channels supports
[[documentation](https://flutter.dev/docs/development/platform-integration/platform-channels#codec)].
Nested data-types are supported, too.

Note: Generics for List and Map aren't supported yet.

## Asynchronous Handlers

By default Pigeon will generate synchronous handlers for messages.  If you want
to be able to respond to a message asynchronously you can use the `@async`
annotation as of version 0.1.20.

Example:

```dart
class Value {
  int? number;
}

@HostApi()
abstract class Api2Host {
  @async
  Value calculate(Value value);
}
```

Generates:

```objc
// Objc
@protocol Api2Host
-(void)calculate:(nullable Value *)input 
      completion:(void(^)(Value *_Nullable, FlutterError *_Nullable))completion;
@end
```

```java
// Java
public interface Result<T> {
   void success(T result);
}

/** Generated interface from Pigeon that represents a handler of messages from Flutter.*/
public interface Api2Host {
   void calculate(Value arg, Result<Value> result);
}
```

## Null Safety (NNBD)

Right now Pigeon supports generating null-safe code, but it doesn't yet support
[non-null fields](https://github.com/flutter/flutter/issues/59118).

The default is to generate null-safe code but in order to generate non-null-safe
code run Pigeon with the extra argument `--no-dart_null_safety`. For example:
`flutter pub run pigeon --input ./pigeons/messages.dart --no-dart_null_safety --dart_out stdout`.

## Feedback

File an issue in [flutter/flutter](https://github.com/flutter/flutter) with the
word 'pigeon' clearly in the title and cc **@gaaclarke**.
