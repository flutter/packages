## 1.6.0

*  Provides more specific error codes on iOS for authentication failures.
    * `LockedOut` is now returned for biometric lockout.
    * `UserCancelled` is now returned when the user cancels the prompt.
    * `UserFallback` is now returned when the user selects the fallback option.

## 1.5.0

* Converts implementation to Swift.
* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 1.4.3

* Handles when biometry hardware is available but permissions have been denied for the app.
* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.

## 1.4.2

* Adds compatibility with `intl` 0.20.0.

## 1.4.1

* Updates to the current version of Pigeon.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 1.4.0

* Adds macOS support.

## 1.3.1

* Adjusts implementation for improved testability, and removes use of OCMock.

## 1.3.0

* Adds Swift Package Manager compatibility.

## 1.2.2

* Adds compatibility with `intl` 0.19.0.

## 1.2.1

* Renames the Objective-C plugin classes to avoid runtime conflicts with
  `local_auth_ios` in apps that have transitive dependencies on both.

## 1.2.0

* Renames the package previously published as [`local_auth_ios`](https://pub.dev/packages/local_auth_ios)
