## 1.2.2

* Moves flutter_test and test dependencies to dev_dependencies.

## 1.2.1

* Removes a few deprecated API usages.

## 1.2.0

* Updates to web code to package `web: ^0.5.0`.
* Updates SDK version to Dart `^3.3.0`. Flutter `^3.19.0`.

## 1.1.1

* Fixes new lint warnings.

## 1.1.0

* Adds `computeAverage` and `computeDelta` methods to support analysis of benchmark results.

## 1.0.1

* Adds `parse` constructors for the `BenchmarkResults` and `BenchmarkScore` classes.

## 1.0.0

* **Breaking change:** replace the `useCanvasKit` parameter in the `serveWebBenchmark`
method with a new parameter `compilationOptions`, which allows you to:
  * specify the web renderer to use for the benchmark app (html, canvaskit, or skwasm)
  * specify whether to use WebAssembly to build the benchmark app
* **Breaking change:** `serveWebBenchmark` now uses `canvaskit` instead of `html` as the
default web renderer.

## 0.1.0+11

* Migrates benchmark recorder from `dart:html` to `package:web` to support WebAssembly.

## 0.1.0+10

* Ensure the benchmark client reloads with the proper `initialPage`.
* Migrates benchmark recorder away from deprecated `js_util` APIs.

## 0.1.0+9

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Adds an optional parameter `initialPage` to `serveWebBenchmark`.

## 0.1.0+8

* Adds an optional parameter `treeShakeIcons` to `serveWebBenchmark`.
* Adds a required and named parameter `treeShakeIcons` to `BenchmarkServer`.

## 0.1.0+7

* Updates `package:process` version constraints.

## 0.1.0+6

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.1.0+5

* Fixes unawaited_futures violations.

## 0.1.0+4

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 0.1.0+3

* Migrates from SingletonFlutterWindow to PlatformDispatcher API.

## 0.1.0+2

* Updates code to fix strict-cast violations.

## 0.1.0+1

* Fixes lint warnings.

## 0.1.0

* Migrates to null safety.
* **BREAKING CHANGES**:
    * Required parameters are non-nullable.

## 0.0.7+1

* Updates text theme parameters to avoid deprecation issues.

## 0.0.7

* Updates BlinkTraceEvents to match with changes in Chromium v89+

## 0.0.6

* Update implementation of `_RecordingWidgetsBinding` to match the [new Binding API](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/foundation/binding.dart#L96-L128)

## 0.0.5

* Updated dependencies to allow broader versions for upstream packages.

## 0.0.4

* Updated dependencies to allow broader versions for upstream packages.

## 0.0.3

* Fixed benchmarks failing due to trace format change for begin frame.

## 0.0.2

* Improve console messages.

## 0.0.1 - Initial release.

* Provide a benchmark server (host-side) and a benchmark client (browser-side).
