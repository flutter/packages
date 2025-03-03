## 2.8.1

- Fixes an issue when navigate to router with invalid params 

## 2.8.0

- Adds support for passing `preload` parameter to `StatefulShellBranchData`.

## 2.7.5

- Fixes trailing `?` in the location when a go route has an empty default value.

## 2.7.4

- Fixes an issue by removing unnecessary `const` in StatefulShellRouteData generation.

## 2.7.3

- Fixes an issue when using a not null List or Set param.

## 2.7.2

- Supports the latest `package:analyzer` and `package:source_gen`.
- Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 2.7.1

- Fixes readme typos and uses code excerpts.

## 2.7.0

- Adds an example and a test with `onExit`.
- Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 2.6.2

* Fixes a bug in the example app when accessing `BuildContext`.

## 2.6.1

* Fixes typo in `durationDecoderHelperName`.
* Updates development dependency to `dart_style-2.3.6` (compatible with `analyzer-6.5.0`).

## 2.6.0

* Adds support for passing observers to the StatefulShellBranch for the nested Navigator.

## 2.5.1

- Updates examples to use uri.path instead of uri.toString() for accessing the current location.

## 2.5.0

* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.
* Updates dependencies to require `analyzer` 5.2.0 or later.
* Adds `restorationScopeId` to `ShellRouteData`.

## 2.4.1

* Fixes new lint warnings.

## 2.4.0

* Adds support for passing observers to the ShellRoute for the nested Navigator.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 2.3.4

* Fixes a bug of typeArguments losing NullabilitySuffix

## 2.3.3

* Adds `initialLocation` for `StatefulShellBranchConfig`

## 2.3.2

* Supports the latest `package:analyzer`.

## 2.3.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.3.0

* Adds Support for StatefulShellRoute

## 2.2.5

* Fixes a bug where shell routes without const constructor were not generated correctly.

## 2.2.4

* Bumps example go_router version to v10.0.0 and migrate example code.

## 2.2.3

* Removes `path_to_regexp` from the dependencies.

## 2.2.2

* Bumps example go_router version and migrate example code.

## 2.2.1

* Cleans up go_router_builder code.

## 2.2.0

* Adds replace methods to the generated routes.

## 2.1.1

* Fixes a bug that the required/positional parameters are not added to query parameters correctly.

## 2.1.0

* Supports required/positional parameters that are not in the path.

## 2.0.2

* Fixes unawaited_futures violations.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 2.0.1

* Supports name parameter for `TypedGoRoute`.
## 2.0.0

* Updates the documentation to go_router v7.0.0.
* Bumps go_router version in example folder to v7.0.0.

## 1.2.2

* Supports returning value in generated `push` method. [go_router CHANGELOG](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md#650)

## 1.2.1

* Supports opt-in required extra parameters. [#117261](https://github.com/flutter/flutter/issues/117261)

## 1.2.0

* Adds Support for ShellRoute

## 1.1.7

* Supports default values for `Set`, `List` and `Iterable` route parameters.

## 1.1.6

* Generates the const enum map for enums used in `List`, `Set` and `Iterable`.

## 1.1.5

* Replaces unnecessary Flutter SDK constraint with corresponding Dart
  SDK constraint.

## 1.1.4

* Fixes the example for the default values in the README.

## 1.1.3

* Updates router_config to not passing itself as `extra`.

## 1.1.2

* Adds support for Iterables, Lists and Sets in query params for TypedGoRoute. [#108437](https://github.com/flutter/flutter/issues/108437).

## 1.1.1

* Support for the generation of the pushReplacement method has been added.

## 1.1.0

* Supports default value for the route parameters.

## 1.0.16

* Update the documentation to go_router v6.0.0.
* Bumps go_router version in example folder to v6.0.0.

## 1.0.15

* Avoids using deprecated DartType.element2.

## 1.0.14

* Bumps go_router version in example folder to v5.0.0.
* Bumps flutter version to 3.3.0.

## 1.0.13

* Supports the latest `package:analyzer`.

## 1.0.12

* Adds support for enhanced enums. [#105876](https://github.com/flutter/flutter/issues/105876).

## 1.0.11

* Replace mentions of the deprecated `GoRouteData.buildPage` with `GoRouteData.buildPageWithState`.

## 1.0.10

* Adds a lint ignore for deprecated member in the example.

## 1.0.9

* Fixes lint warnings.

## 1.0.8

* Updates `analyzer` to 4.4.0.
* Removes the usage of deprecated API in `analyzer`.

## 1.0.7

* Supports newer versions of `analyzer`.

## 1.0.6

* Uses path-based deps in example.

## 1.0.5

* Update example to avoid using `push()` to push the same page since is not supported. [#105150](https://github.com/flutter/flutter/issues/105150)

## 1.0.4

* Adds `push` method to generated GoRouteData's extension. [#103025](https://github.com/flutter/flutter/issues/103025)

## 1.0.3

* Fixes incorrect separator at location path on Windows. [#102710](https://github.com/flutter/flutter/issues/102710)

## 1.0.2

* Changes the parameter name of the auto-generated `go` method from `buildContext` to `context`.

## 1.0.1

* Documentation fixes. [#102713](https://github.com/flutter/flutter/issues/102713).

## 1.0.0

* First release.
