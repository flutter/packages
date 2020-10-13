## 0.1.12

* Fixed assert failure with creating a PlatformException as a result of an
  exception in Java handlers.

## 0.1.11

* Added flag to generate null safety annotated Dart code `--dart-null-safety`.
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
