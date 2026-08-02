// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:build/build.dart';
import 'package:collection/collection.dart';

/// The `build.yaml` option that selects a [DuplicatePathSeverity].
const String duplicateRoutePathsOption = 'duplicate_route_paths';

/// How the builder reports sibling routes that resolve to the same URL pattern.
enum DuplicatePathSeverity {
  /// Duplicate paths are not reported at all.
  ignore,

  /// Duplicate paths are reported as build warnings.
  ///
  /// Code is still generated for every route. This is the default, because
  /// duplicate paths are legal at runtime: `go_router` matches the first route
  /// that fits, so the later route is unreachable rather than invalid.
  warning,

  /// Duplicate paths fail the build.
  error,
}

/// Reads the [DuplicatePathSeverity] from `build.yaml` builder [options].
///
/// Defaults to [DuplicatePathSeverity.warning] when the option is absent.
DuplicatePathSeverity duplicatePathSeverityFromOptions(BuilderOptions options) {
  final Object? value = options.config[duplicateRoutePathsOption];
  if (value == null) {
    return DuplicatePathSeverity.warning;
  }
  final DuplicatePathSeverity? severity = DuplicatePathSeverity.values.firstWhereOrNull(
    (DuplicatePathSeverity severity) => severity.name == value,
  );
  if (severity == null) {
    throw ArgumentError.value(
      value,
      duplicateRoutePathsOption,
      'Must be one of '
      '${DuplicatePathSeverity.values.map((DuplicatePathSeverity e) => e.name).join(', ')}',
    );
  }
  return severity;
}
