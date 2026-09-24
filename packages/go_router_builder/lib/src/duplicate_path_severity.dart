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
  /// Code is still generated for every route. This is the default, because a
  /// duplicate path is legal at runtime and is not always dead code.
  ///
  /// `go_router` tries sibling routes in declaration order and takes the first
  /// one that matches the whole URL. So when two different route classes share
  /// a path, navigating to the second class's location lands on the first
  /// class's page, which is almost always a mistake. But matching backtracks:
  /// when a route matches only a prefix and none of its children complete the
  /// URL, matching moves on to the next sibling. Declaring one route class
  /// twice with different children is therefore sound, and is one way to group
  /// children by feature area. Both shapes are reported, since the builder
  /// cannot tell a deliberate grouping from an accidental duplicate.
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
