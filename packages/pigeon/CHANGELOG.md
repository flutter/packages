## 22.5.0

* [swift] Adds implementation for `@ProxyApi`.

## 22.4.2

* Updates `README.md` to replace the deprecated `flutter pub run pigeon` command with `dart run pigeon`.

## 22.4.1

* [dart] Fixes bug where special handling of ints is ignored if no custom types are used.

## 22.4.0

* Adds support for non-nullable types in collections.

## 22.3.0

* Adds support for enums and classes in collections.

## 22.2.0

* [kotlin] Adds implementation for `@ProxyApi`.

## 22.1.0

* Allows generation of classes that aren't referenced in an API.

## 22.0.0

* [dart] Changes codec to send int64 instead of int32.
* **Breaking Change** [swift] Changes generic `map` to nullable keys of `AnyHashable` to conform to other platforms.
* Adds tests to validate collections of ints.

## 21.2.0

* Removes restriction on number of custom types.
* [java] Fixes bug with multiple enums.
* [java] Removes `Object` from generics.
* [objc] Fixes bug with multiple enums per data class.
* Updates `varPrefix` and `classMemberNamePrefix`.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.

## 21.1.0

* Adds GObject (Linux) support.

## 21.0.0

* **Breaking Change** [cpp] Fixes style of enum names. References to enum values
  will need to be updated to `EnumType.kValue` style, instead of the previous
  `EnumType.value`.

## 20.0.2

* [java] Adds `equals` and `hashCode` support for data classes.
* [swift] Fully-qualifies types in Equatable extension test.

## 20.0.1

* [cpp] Fixes handling of null class arguments.

## 20.0.0

* Moves all codec logic to single custom codec per file.
* **Breaking Change** Limits the number of total custom types to 126.
  * If more than 126 custom types are needed, consider breaking up your definition files.
* Fixes bug that prevented collection subtypes from being added properly.
* [swift] Adds `@unchecked Sendable` to codec method.
* [objc] [cpp] Fixes bug that prevented setting custom header import path.

## 19.0.2

* [kotlin] Adds the `@JvmOverloads` to the `HostApi` setUp method. This prevents the calling Java code from having to provide an empty `String` as Kotlin provides it by default

## 19.0.1

* [dart] Updates `PigeonInstanceMangerApi` to use the shared api channel code.

## 19.0.0

* **Breaking Change** [swift] Removes `FlutterError` in favor of `PigeonError`.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 18.0.1

* Fixes unnecessary calls of `toList` and `fromList` when encoding/decoding data classes.
* [kotlin] Changes to some code to make it more idiomatic.
* Removes collisions with the word `list`.

## 18.0.0

* Adds message channel suffix option to all APIs.
* **Breaking Change** [dart] Changes `FlutterApi` `setup` to `setUp`.

## 17.3.0

* [swift] Adds `@SwiftClass` annotation to allow choice between `struct` and `class` for data classes.
* [cpp] Adds support for recursive data class definitions.

## 17.2.0

* [dart] Adds implementation for `@ProxyApi`.

## 17.1.3

* [objc] Fixes double prefixes added to enum names.

## 17.1.2

* [swift] Separates message call code generation into separate methods.

## 17.1.1

* Removes heap allocation in generated C++ code.

## 17.1.0

* [kotlin] Adds `includeErrorClass` to `KotlinOptions`.
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.

## 17.0.0

* **Breaking Change** [kotlin] Converts Kotlin enum case generation to SCREAMING_SNAKE_CASE.
  * Updates `writeEnum` function to adhere to Kotlin naming conventions.
  * Improves handling of complex names with enhanced regex patterns.
  * Expands unit tests for comprehensive name conversion validation.
  * **Migration Note**: This change modifies the naming convention of Kotlin enum cases generated from the Pigeon package. It is recommended to review the impact on your existing codebase and update any dependent code accordingly.

## 16.0.5

* Adds ProxyApi to AST generation.

## 16.0.4

* [swift] Improve style of Swift output.

## 16.0.3

* [kotlin] Separates message call code generation into separate methods.

## 16.0.2

* [dart] Separates message call code generation into separate methods.

## 16.0.1

* [dart] Fixes test generation for missing wrapResponse method if only host Api.

## 16.0.0

* [java] Adds `VoidResult` type for `Void` returns.
* **Breaking Change** [java] Updates all `Void` return types to use new `VoidResult`.

## 15.0.3

* Fixes new lint warnings.

## 15.0.2

* Prevents optional and non-positional parameters in Flutter APIs.
* [dart] Fixes named parameters in test output of host API methods.

## 15.0.1

* [java] Adds @CanIgnoreReturnValue annotation to class builder.

## 15.0.0

* **Breaking Change** [kotlin] Updates Flutter API to use new errorClassName.

## 14.0.1

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Updates issue_tracker link.

## 14.0.0

* **Breaking change** [dart] Renames locally defined host API variables.
  * [dart] Host api static field `codec` changed to `pigeonChannelCodec`.
* [dart] Adds named parameters to host API methods.
* [dart] Adds optional parameters to host API methods.
* [dart] Adds default values for class constructors and host API methods.
* Adds `isEnum` and `isClass` to `TypeDeclaration`s.
* [cpp] Fixes `FlutterError` generation being tied to ErrorOr.

## 13.1.2

* Adds compatibility with `analyzer` 6.x.

## 13.1.1

* [kotlin] Removes unnecessary `;`s in generated code.

## 13.1.0

* [swift] Fixes Flutter Api void return error handling.
  * This shouldn't be breaking for anyone, but if you were incorrectly getting
    success responses, you may now be failing (correctly).
* Adds method channel name to error response when channel fails to connect.
* Reduces code generation duplication.
* Changes some methods to only be generated if needed.

## 13.0.0

* **Breaking Change** [objc] Eliminates boxing of non-nullable primitive types
  (bool, int, double). Changes required:
  * Implementations of host API methods that take non-nullable
    primitives will need to be updated to match the new signatures.
  * Calls to Flutter API methods that take non-nullable primitives will need to
    be updated to pass unboxed values.
  * Calls to non-nullable primitive property methods on generated data classes
    will need to be updated.
  * **WARNING**: Current versions of `Xcode` do not appear to warn about
    implicit `NSNumber *` to `BOOL` conversions, so code that is no longer
    correct after this breaking change may compile without warning. For example,
    `myGeneratedClass.aBoolProperty = @NO` can silently set `aBoolProperty` to
    `YES`. Any data class or Flutter API interactions involving `bool`s should
    be carefully audited by hand when updating.

## 12.0.1

* [swift] Adds protocol for Flutter APIs.

## 12.0.0

* Adds error handling on Flutter API methods.
* **Breaking Change** [kotlin] Flutter API methods now return `Result<return-type>`.
* **Breaking Change** [swift] Flutter API methods now return `Result<return-type, FlutterError>`.
* **Breaking Change** [java] Removes `Reply` class from all method returns and replaces it with `Result`.
  * Changes required: Replace all `Reply` callbacks with `Result` classes that contain both `success` and `failure` methods.
* **Breaking Change** [java] Adds `NullableResult` class for all nullable method returns.
  * Changes required: Any method that returns a nullable type will need to be updated to return `NullableResult` rather than `Result`.
* **Breaking Change** [java] Renames Host API `setup` method to `setUp`.
* **Breaking Change** [objc] Boxes all enum returns to allow for `nil` response on error.
* **Breaking Change** [objc] Renames `<api>Setup` to `SetUp<api>`.

## 11.0.1

* Adds pub topics to package metadata.

## 11.0.0

* Adds primitive enum support.
* [objc] Fixes nullable enums.
* **Breaking Change** [objc] Changes all nullable enums to be boxed in custom classes.
* **Breaking Change** [objc] Changes all enums names to have class prefix.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 10.1.6

* Fixes generation failures when an output file is in a directory that doesn't already exist.

## 10.1.5

* [dart] Fixes import in generated test output when overriding package name.

## 10.1.4

* Adds package name to method channel strings to avoid potential collisions between plugins.
* Adds dartPackageName option to `pigeonOptions`.

## 10.1.3

* Adds generic `Object` field support to data classes.

## 10.1.2

* [swift] Fixes a crash when passing `null` for nested nullable classes.

## 10.1.1

* Updates README to better reflect modern usage.

## 10.1.0

* [objc] Adds macOS support to facilitate code sharing with existing iOS plugins.

## 10.0.1

* Requires `analyzer 5.13.0` and replaces use of deprecated APIs.

## 10.0.0

* [swift] Avoids using `Any` to represent `Optional`.
* [swift] **Breaking Change** A raw `List` (without generic type argument) in Dart will be
  translated into `[Any?]` (rather than `[Any]`).
* [swift] **Breaking Change** A raw `Map` (without generic type argument) in Dart will be
  translated into `[AnyHashable:Any?]` (rather than `[AnyHashable:Any]`).
* Adds an example application that uses Pigeon directly, rather than in a plugin.

## 9.2.5

* Reports an error when trying to use an enum directly in a `List` or `Map`
  argument.

## 9.2.4

* [objc] Fixes a warning due to a C++-style function signature in the codec
  getter's definition.

## 9.2.3

* [java] Fixes `UnknownNullability` and `SyntheticAccessor` warnings.

## 9.2.2

* [cpp] Minor changes to output style.

## 9.2.1

* [swift] Fixes NSNull casting crash.

## 9.2.0

* [cpp] Removes experimental tags.

## 9.1.4

* Migrates off deprecated `BinaryMessenger` API.

## 9.1.3

* [cpp] Requires passing any non-nullable fields of generated data classes as
  constructor arguments, similar to what is done in other languages. This may
  require updates to existing code that creates data class instances on the
  native side.
* [cpp] Adds a convenience constructor to generated data classes to set all
  fields during construction.

## 9.1.2

* [cpp] Fixes class parameters to Flutter APIs.
* Updates minimum Flutter version to 3.3.

## 9.1.1

* [swift] Removes experimental tags.
* [kotlin] Removes experimental tags.

## 9.1.0

* [java] Adds a `GeneratedApi.FlutterError` exception for passing custom error details (code, message, details).
* [kotlin] Adds a `FlutterError` exception for passing custom error details (code, message, details).
* [kotlin] Adds an `errorClassName` option in `KotlinOptions` for custom error class names.
* [java] Removes legacy try catch from async APIs.
* [java] Removes legacy null check on non-nullable method arguments.
* [cpp] Fixes wrong order of items in `FlutterError`.
* Adds `FlutterError` handling integration tests for all platforms.

## 9.0.7

* [swift] Changes all ints to int64.
  May require code updates to existing code.
* Adds integration tests for int64.

## 9.0.6

* [kotlin] Removes safe casting from decode process.
* [swift] Removes safe casting from decode process.

## 9.0.5

* Removes the unnecessary Flutter constraint.
* Removes an unnecessary null check.
* Aligns Dart and Flutter SDK constraints.

## 9.0.4

* Adds parameter to generate Kotlin code in example README.

## 9.0.3

* [kotlin] Fixes compiler warnings in generated output.
* [swift] Fixes compiler warnings in generated output.

## 9.0.2

* [swift] Removes safe casting from decode process.
* [kotlin] Removes safe casting from decode process.

## 9.0.1

* Updates links for the merge of flutter/plugins into flutter/packages.

## 9.0.0

* **Breaking Change** Updates `DartOptions` to be immutable and adds const to the constructor.
* [java] Reverts `final` changes to Flutter Api classes.

## 8.0.0

* [objc] **BREAKING CHANGE**: FlutterApi calls now return a `FlutterError`,
  rather than an `NSError`, on failure.
* [objc] Fixes an unused function warning when only generating FlutterApi.

## 7.2.1

* [kotlin] Fixes Flutter API int errors with updated casting.

## 7.2.0

* [swift] Changes async method completion types.
  May require code updates to existing code.
* [swift] Adds error handling to async methods.
* [kotlin] Changes async method completion types.
  May require code updates to existing code.
* [kotlin] Adds error handling to async methods.
* Adds async error handling integration tests for all platforms.

## 7.1.5

* Updates code to fix strict-cast violations.

## 7.1.4

* [java] Fixes raw types lint issues.

## 7.1.3

* [objc] Removes unused function.

## 7.1.2

* [swift] Adds error handling to sync host API methods.

## 7.1.1

* [c++] Fixes handling of the `cpp*` options in `@ConfigurePigeon` annotations.

## 7.1.0

* Adds `@SwiftFunction` annotation for specifying custom swift function signature.

## 7.0.5

* Requires analyzer 5.0.0 and replaces use of deprecated APIs.

## 7.0.4

* [c++] Fixes minor output formatting issues.

## 7.0.3

* Updates scoped methods to prevent symbol-less use.

## 7.0.2

* [kotlin] Fixes a missed casting of not nullable Dart 'int' to Kotlin 64bit long.

## 7.0.1

* [generator_tools] adds `newln` method for adding empty lines and ending lines.
* Updates generators to more closely match Flutter formatter tool output.

## 7.0.0

* [java] **BREAKING CHANGE**: Makes data classes final.
  Updates generators for 1p linters.

## 6.0.3

* [docs] Updates README.md.

## 6.0.2

* [kotlin] Fixes a bug with a missed line break between generated statements in the `fromList` function of the companion object.

## 6.0.1

* [c++] Fixes most non-class arguments and return values in Flutter APIs. The
  types of arguments and return values have changed, so this may require updates
  to existing code.

## 6.0.0

* Creates StructuredGenerator class and implements it on all platforms.

## 5.0.1

* [c++] Fixes undefined behavior in `@async` methods.

## 5.0.0

* Creates new Generator classes for each language.

## 4.2.16

* [swift] Fixes warnings with `Object` parameters.
* [dart] Fixes warnings with `Object` return values.
* [c++] Generation of APIs that use `Object` no longer fails.

## 4.2.15

* Relocates generator classes. (Reverted)

## 4.2.14

* [c++] Fixes reply sending non EncodableValue wrapped lists.

## 4.2.13

* Add documentation comment support for Enum members.

## 4.2.12

* Updates serialization to use lists instead of maps to improve performance.

## 4.2.11

* [swift] Fixes compressed list data types.

## 4.2.10

* [java] Changes generated enum field to be final.

## 4.2.9

* [kotlin] Fixes a bug with some methods that return `void`.

## 4.2.8

* Adds the ability to use `runWithOptions` entrypoint to allow external libraries to use the pigeon easier.

## 4.2.7

* [swift] Fixes a bug when calling methods that return `void`.

## 4.2.6

* Fixes bug with parsing documentation comments that start with '/'.

## 4.2.5

* [dart] Fixes enum parameter handling in Dart test API class.

## 4.2.4

* [kotlin] Fixes Kotlin generated sync host API error.

## 4.2.3

* [java] Adds assert `args != null`.
* [java] Changes the args of a single element to `ArrayList` from `Arrays.asList` to `Collections.singletonList`.
* [java] Removes cast for `Object`.

## 4.2.2

* Removes unneeded custom codecs for all languages.

## 4.2.1

* Adds documentation comment support for Kotlin.

## 4.2.0

* Adds experimental support for Kotlin generation.

## 4.1.1

* [java] Adds missing `@NonNull` annotations to some methods.

## 4.1.0

* Adds documentation comment support for all currently supported languages.

## 4.0.3

* [swift] Makes swift output work on macOS.

## 4.0.2

* Fixes lint warnings.

## 4.0.1

* Exposes `SwiftOptions`.

## 4.0.0

* [java] **BREAKING CHANGE**: Changes style for enum values from camelCase to snake_case.
  Generated java enum values will now always be in upper snake_case.

## 3.2.9

* Updates text theme parameters to avoid deprecation issues.

## 3.2.8

* [dart] Deduces the correct import statement for Dart test files made with
  `dartHostTestHandler` instead of relying on relative imports.

## 3.2.7

* Requires `analyzer 4.4.0`, and replaces use of deprecated APIs.

## 3.2.6

* [java] Fixes returning int values from FlutterApi methods that fit in 32 bits.

## 3.2.5

* [c++] Fixes style issues in `FlutterError` and `ErrorOr`. The names and
  visibility of some members have changed, so this may require updates
  to existing code.

## 3.2.4

* [c++] Fixes most non-class arguments and return values in host APIs. The
  types of arguments and return values have changed, so this may require updates
  to existing code.

## 3.2.3

* Adds `unnecessary_import` to linter ignore list in generated dart tests.

## 3.2.2

* Adds `unnecessary_import` to linter ignore list for `package:flutter/foundation.dart`.

## 3.2.1

* Removes `@dart = 2.12` from generated Dart code.

## 3.2.0

* Adds experimental support for Swift generation.

## 3.1.7

* [java] Adds option to add javax.annotation.Generated annotation.

## 3.1.6

* Supports newer versions of `analyzer`.

## 3.1.5

* Fixes potential crash bug when using a nullable nested type that has nonnull
  fields in ObjC.

## 3.1.4

* [c++] Adds support for non-nullable fields, and fixes some issues with
  nullable fields. The types of some getters and setter have changed, so this
  may require updates to existing code.

## 3.1.3

* Adds support for enums in arguments to methods for HostApis.

## 3.1.2

* [c++] Fixes minor style issues in generated code. This includes the naming of
  generated methods and arguments, so will require updates to existing code.

## 3.1.1

* Updates for non-nullable bindings.

## 3.1.0

* [c++] Adds C++ code generator.

## 3.0.4

* [objc] Simplified some code output, including avoiding Xcode warnings about
  using `NSNumber*` directly as boolean value.
* [tests] Moved test script to enable CI.

## 3.0.3

* Adds ability for generators to do AST validation.  This can help generators
  without complete implementations to report gaps in coverage.

## 3.0.2

* Fixes non-nullable classes and enums as fields.
* Fixes nullable collections as return types.

## 3.0.1

* Enables NNBD for the Pigeon tool itself.
* [tests] Updates legacy Dart commands.

## 3.0.0

* **BREAKING CHANGE**: Removes the `--dart_null_safety` flag. Generated Dart
  now always uses nullability annotations, and thus requires Dart 2.12 or later.

## 2.0.4

* Fixes bug where Dart `FlutterApi`s would assert that a nullable argument was nonnull.

## 2.0.3

* [java] Makes the generated Builder class final.

## 2.0.2

* [java] Fixes crash for nullable nested type.

## 2.0.1

* Adds support for TaskQueues for serial background execution.

## 2.0.0

* Implements nullable parameters.
* **BREAKING CHANGE** - Nonnull parameters to async methods on HostApis for ObjC
  now have the proper nullability hints.

## 1.0.19

* Implements nullable return types.

## 1.0.18

* [front-end] Fix error caused by parsing `copyrightHeaders` passed to options in `@ConfigurePigeon`.

## 1.0.17

* [dart_test] Adds missing linter ignores.
* [objc] Factors out helper function for reading from NSDictionary's.
* [objc] Renames static variables to match Google style.

## 1.0.16

* Updates behavior of run\_tests.dart with no arguments.
* [debugging] Adds `ast_out` to help with debugging the compiler front-end.
* [front-end, dart] Adds support for non-null fields in data classes in the
  front-end parser and the Dart generator (unsupported languages ignore the
  designation currently).
* [front-end, dart, objc, java] Adds support for non-null fields in data
  classes.

## 1.0.15

* [java] Fix too little information when having an exception

## 1.0.14

* [tests] Port several generator tests to run in Dart over bash

## 1.0.13

* [style] Fixes new style rules for Dart analyzer.

## 1.0.12

* [java] Fixes enum support for null values.

## 1.0.11

* [ci] Starts transition to a Dart test runner, adds windows support.
* [front-end] Starts issuing an error if enums are used in type arguments.
* [front-end] Passes through all enums, referenced or not so they can be used as
  a work around for direct enum support.

## 1.0.10

* [front-end] Made sure that explicit use of Object actually creates the codec
  that can represent custom classes.

## 1.0.9

* [dart] Fixed cast exception that can happen with primitive data types with
  type arguments in FlutterApi's.

## 1.0.8

* [front-end] Started accepting explicit Object references in type arguments.
* [codecs] Fixed nuisance where duplicate entries could show up in custom codecs.

## 1.0.7

* [front-end] Fixed bug where nested classes' type arguments aren't included in
  the output (generated class and codec).

## 1.0.6

* Updated example README for set up steps.

## 1.0.5

* [java] Fixed bug when using Integer arguments to methods declared with 'int'
  arguments.

## 1.0.4

* [front-end] Fixed bug where codecs weren't generating support for types that
  only show up in type arguments.

## 1.0.3

* [objc] Updated assert message for incomplete implementations of protocols.

## 1.0.2

* [java] Made it so `@async` handlers in `@HostApi()` can report errors
  explicitly.

## 1.0.1

* [front-end] Fixed bug where classes only referenced as type arguments for
  generics weren't being generated.

## 1.0.0

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
* [objc] **BREAKING CHANGE:** logic for generating selectors has changed.
  `void add(Input value)` will now translate to
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

* Fixed setting an API to null in Java.

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

* Added support for Android Java.

## 0.1.0-experimental.2

* Added Host->Flutter calls for Objective-C

## 0.1.0-experimental.1

* Fixed warning in the README.md

## 0.1.0-experimental.0

* Initial release.
