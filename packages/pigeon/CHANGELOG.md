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
