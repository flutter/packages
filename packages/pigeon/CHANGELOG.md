## NEXT

* Started allowing primitive data types as arguments and return types.
* Generics support.
* Support for functions with more than one argument.
* [command-line] Added `one_language` flag for allowing Pigeon to only generate
  code for one platform.
* [command-line] Added the optional sdkPath parameter for specifying Dart SDK
  path.
* [dart] Fixed copyright headers for Dart test output.
* [front-end] Added more errors for incorrect usage of Pigeon (previously they
  were just ignored).
* [generators] Moved Pigeon to using a custom codec which allows collection
  types to contain custom classes.
* [java] Fixed NPE in Java generated code for nested types.
* [objc] BREAKING CHANGE: logic for generating Objective-C selectors has
  changed. `void add(Input value)` will now translate to
  `-(void)addValue:(Input*)value`, methods with no arguments will translate to
  `...WithError:` or `...WithCompletion:`.
* [objc] Added `@ObjCSelector` for specifying custom objc selectors.

## 0.3.0

* Updated the front-end parser to use dart
  [`analyzer`](https://pub.dev/packages/analyzer) instead of `dart:mirrors`.
  `dart:mirrors` doesn't support null-safe code so there were a class of
  features we couldn't implement without this migration.
* **BREAKING CHANGE** - the `configurePigeon` function has been migrated to a
  `@ConfigurePigeon` annotation.  See `./pigeons/message.dart` for an example.
  The annotation can be attached to anything in the file to take effect.
* **BREAKING CHANGE** - Now Pigeon files must be in one file per invocation of
  Pigeon.  For example, the classes your APIs use must be in the same file as
  your APIs.  If your Pigeon file imports another source file, it won't actually
  import it.

## 0.2.4

* bugfix in front-end parser for recursively referenced datatypes.

## 0.2.3

* bugfix in iOS async handlers of functions with no arguments.

## 0.2.2

* Added support for enums.

## 0.2.1

* Java: Fixed issue where multiple async HostApis can generate multiple Result interfaces.
* Dart: Made it so you can specify the BinaryMessenger of the generated APIs.

## 0.2.0

* **BREAKING CHANGE** - Pigeon files must be null-safe now.  That means the
  fields inside of the classes must be declared nullable (
  [non-null fields](https://github.com/flutter/flutter/issues/59118) aren't yet
  supported).  Migration example:

```dart
// Version 0.1.x
class Foo {
  int bar;
  String baz;
}

// Version 0.2.x
class Foo {
  int? bar;
  String? baz;
}
```

* **BREAKING CHANGE** - The default output from Pigeon is now null-safe.  If you
  want non-null-safe code you must provide the `--no-dart_null_safety` flag.
* The Pigeon source code is now null-safe.
* Fixed niladic non-value returning async functions in the Java generator.
* Made `runCommandLine` return an the status code.

## 0.1.24

* Moved logic from bin/ to lib/ to help customers wrap up the behavior.
* Added some more linter ignores for Dart.

## 0.1.23

* More Java linter and linter fixes.

## 0.1.22

* Java code generator enhancements:
  * Added linter tests to CI.
  * Fixed some linter issues in the Java code.

## 0.1.21

* Fixed decode method on generated Flutter classes that use null-safety and have
  null values.

## 0.1.20

* Implemented `@async` HostApi's for iOS.
* Fixed async FlutterApi methods with void return.

## 0.1.19

* Fixed a bug introduced in 0.1.17 where methods without arguments were
  no longer being called.

## 0.1.18

* Null safe requires Dart 2.12.

## 0.1.17

* Split out test code generation for Dart into a separate file via the
  --dart_test_out flag.

## 0.1.16

* Fixed running in certain environments where NNBD is enabled by default.

## 0.1.15

* Added support for running in versions of Dart that support NNBD.

## 0.1.14

* [Windows] Fixed executing from drives other than C:.

## 0.1.13

* Fixed execution on Windows with certain setups where Dart didn't allow
  backslashes in `import` statements.

## 0.1.12

* Fixed assert failure with creating a PlatformException as a result of an
  exception in Java handlers.

## 0.1.11

* Added flag to generate null safety annotated Dart code `--dart_null_safety`.
* Made it so Dart API setup methods can take null.

## 0.1.10+1

* Updated the examples page.

## 0.1.10

* Fixed bug that prevented running `pigeon` on Windows (introduced in `0.1.8`).

## 0.1.9

* Fixed bug where executing pigeon without arguments would crash (introduced in 0.1.8).

## 0.1.8

* Started spawning pigeon_lib in an isolate instead of a subprocess.  The
  subprocess could have lead to errors if the dart version on $PATH didn't match
  the one that comes with flutter.

## 0.1.7

* Fixed Dart compilation for later versions that support null safety, opting out
  of it for now.
* Fixed nested types in the Java runtime.

## 0.1.6

* Fixed unused variable linter warning in Dart code under certain conditions.

## 0.1.5

* Made array datatypes correctly get imported and exported avoiding the need to
  add extra imports to generated code.

## 0.1.4

* Fixed nullability for NSError's in generated objc code.
* Fixed nullability of nested objects in the Dart generator.
* Added test to make sure the pigeon version is correct in generated code headers.

## 0.1.3

* Added error message if supported datatypes are used as arguments or return
  types directly, without an enclosing class.
* Added support for List and Map datatypes in Java and Objective-C targets.

## 0.1.2+1

* Updated the Readme.md.

## 0.1.2

* Removed static analysis warnings from generated Java code.

## 0.1.1

* Fixed issue where nested types didn't work if they weren't present in the Api.

## 0.1.0

* Added pigeon.dart.
* Fixed some Obj-C linter problems.
* Added the ability to generate a mock handler in Dart.

## 0.1.0-experimental.11

* Fixed setting an api to null in Java.

## 0.1.0-experimental.10

* Added support for void argument functions.
* Added nullability annotations to generated objc code.

## 0.1.0-experimental.9

* Added e2e tests for iOS.

## 0.1.0-experimental.8

* Renamed `setupPigeon` to `configurePigeon`.

## 0.1.0-experimental.7

* Suppressed or got rid of warnings in generated Dart code.

## 0.1.0-experimental.6

* Added support for void return types.

## 0.1.0-experimental.5

* Fixed runtime exception in Android with values of ints less than 2^32.
* Incremented codegen version warning.

## 0.1.0-experimental.4

* Fixed primitive types for Android Java.

## 0.1.0-experimental.3

* Added support for for Android Java.

## 0.1.0-experimental.2

* Added Host->Flutter calls for Objective-C

## 0.1.0-experimental.1

* Fixed warning in the README.md

## 0.1.0-experimental.0

* Initial release.
