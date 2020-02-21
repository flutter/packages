# Pigeon

**Warning: Pigeon is experimental and unsupported.  It can be removed or changed
at any time.**

Pigeon is a code generator tool to make communication between Flutter and the
host platform type-safe and easier.

## Supported Platforms

Currently Pigeon only supports generating Objective-C code for usage on iOS and
Java code for Android.

## Runtime Requirements

Pigeon generates all the code that is needed to communicate between Flutter and
the host platform, there is no extra runtime requirement.  A plugin author
doesn't need to worry about conflicting versions of Pigeon.

## Usage

### Flutter calling into iOS Steps

1) Add Pigeon as a dev_dependency.
1) Make a ".dart" file outside of your "lib" directory for defining the communication interface.
1) Run pigeon on your ".dart" file to generate the required Dart and Objective-C code.
1) Add the generated Dart code to `lib` for compilation.
1) Add the generated Objective-C code to your Xcode project for compilation
   (e.g. `ios/Runner.xcworkspace`).
1) Implement the generated iOS protocol for handling the calls on iOS, set it up
   as the handler for the messages.
1) Call the generated Dart methods.

### Flutter calling into Android Steps

1) Add Pigeon as a dev_dependency.
1) Make a ".dart" file outside of your "lib" directory for defining the communication interface.
1) Run pigeon on your ".dart" file to generate the required Dart and Java code.
1) Add the generated Dart code to `./lib` for compilation.
1) Add the generated Java code to your `./android/app/src/main/java` directory for compilation.
1) Implement the generated Java interface for handling the calls on Android, set it up
   as the handler for the messages.
1) Call the generated Dart methods.

### Rules for defining your communication interface

1) The file should contain no methods or function definitions.
1) Datatypes are defined as classes with fields of the supported datatypes (see
   the supported Datatypes section).
1) Api's should be defined as an `abstract class` with either `HostApi()` or
   `FlutterApi()` as metadata.  The former being for procedures that are defined
   on the host platform and the latter for procedures that are defined in Dart.
1) Method declarations on the Api classes should have one argument and a return
   value whose types are defined in the file.

## Example

See the "Example" tab.

## Supported Datatypes

Pigeon uses the `StandardMessageCodec` so it supports any data-type platform
channels supports
[[documentation](https://flutter.dev/docs/development/platform-integration/platform-channels#codec)].  Nested data-types are supported, too.

Note: Generics for List and Map aren't supported yet.

## Feedback

File an issue in [flutter/flutter](https://github.com/flutter/flutter) with the
word 'pigeon' clearly in the title and cc **@gaaclarke**.
