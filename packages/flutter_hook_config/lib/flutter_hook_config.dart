// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A `package:hooks` protocol extension that exposes Flutter engine host-tool
/// paths (such as `impellerc` and `libtessellator`) to build and link hooks.
///
/// Hook authors read the injected configuration via [HookConfigFlutterConfig],
/// checking [HookConfigFlutterConfig.buildForFlutter] first:
///
/// ```dart
/// import 'package:flutter_hook_config/flutter_hook_config.dart';
/// import 'package:hooks/hooks.dart';
///
/// void main(List<String> args) async {
///   await build(args, (input, output) async {
///     if (input.config.buildForFlutter) {
///       final impellerc = input.config.flutter.impellerc;
///       // ... invoke impellerc ...
///     }
///   });
/// }
/// ```
///
/// The Flutter SDK (`flutter_tools`) populates the configuration by passing a
/// [FlutterExtension] to the hook runner.
library;

export 'src/config.dart'
    show FlutterConfig, HookConfigBuilderFlutterConfig, HookConfigFlutterConfig;
export 'src/extension.dart' show FlutterExtension;
