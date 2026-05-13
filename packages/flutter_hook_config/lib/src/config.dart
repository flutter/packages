// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:hooks/hooks.dart';

/// The hook config field that holds protocol-extension namespaces.
const String _extensionsKey = 'extensions';

/// The key under which Flutter-specific configuration is stored inside the hook
/// config's [_extensionsKey] map.
const String _flutterExtensionKey = 'flutter';

const String _engineVersionKey = 'engine_version';
const String _impellercKey = 'impellerc';
const String _libtessellatorKey = 'libtessellator';

/// Flutter-specific configuration supplied to a build or link hook.
///
/// Obtained via [HookConfigFlutterConfig.flutter]. Only available when the hook
/// is invoked by a Flutter SDK that supports this extension; check
/// [HookConfigFlutterConfig.buildForFlutter] before accessing it.
///
/// `hooks_runner` keys the hook cache on the contents of this config, so
/// changes to any field here invalidate the cache and force the hook to be
/// re-run. In particular, [engineVersion] changes whenever the Flutter SDK is
/// upgraded, which is what causes hooks consuming engine host tools (such as
/// `impellerc`) to re-run with the new binaries even though [impellerc] and
/// [libtessellator] point at the same paths.
final class FlutterConfig {
  FlutterConfig._(this._json);

  final Map<String, Object?> _json;

  /// An opaque identifier for the Flutter engine the invoking SDK targets.
  ///
  /// This is the Flutter engine revision under a normal `flutter` invocation,
  /// or a stable identifier derived from the local engine output directory
  /// under `--local-engine`. Treat the value as opaque: it is only meaningful
  /// for equality comparison and for ensuring that a different Flutter SDK
  /// produces a different value (so that the hook cache invalidates).
  String get engineVersion => _string(_engineVersionKey);

  /// The absolute path to the `impellerc` offline shader compiler that ships
  /// with the engine artifacts of the invoking Flutter SDK.
  ///
  /// When the SDK is invoked with `--local-engine`, this points at the locally
  /// built `impellerc`, matching the engine the app is being built against.
  Uri get impellerc => _filePath(_impellercKey);

  /// The absolute path to the `libtessellator` dynamic library that ships with
  /// the engine artifacts of the invoking Flutter SDK.
  ///
  /// When the SDK is invoked with `--local-engine`, this points at the locally
  /// built `libtessellator`.
  Uri get libtessellator => _filePath(_libtessellatorKey);

  Uri _filePath(String key) => Uri.file(_string(key));

  String _string(String key) {
    final Object? value = _json[key];
    if (value is! String) {
      throw FormatException(
        'Expected a String at '
        "'config.$_extensionsKey.$_flutterExtensionKey.$key' in the hook "
        'input, got: $value',
      );
    }
    return value;
  }
}

/// Extension on [HookConfig] providing access to Flutter-specific
/// configuration.
extension HookConfigFlutterConfig on HookConfig {
  /// Whether this hook is being invoked as part of a Flutter build.
  ///
  /// When `false`, the hook is being invoked by a plain `dart` build, or by a
  /// Flutter SDK that predates the `flutter_hook_config` extension, and
  /// [flutter] must not be accessed. Hooks that need Flutter-supplied
  /// configuration should fall back to their own discovery logic in that case.
  bool get buildForFlutter => _flutterExtensionJson != null;

  /// The Flutter-specific configuration for this hook invocation.
  ///
  /// Only valid when [buildForFlutter] is `true`; throws a [StateError]
  /// otherwise.
  FlutterConfig get flutter {
    final Map<String, Object?>? extensionJson = _flutterExtensionJson;
    if (extensionJson == null) {
      throw StateError(
        'No Flutter-specific hook configuration is available. The hook is not '
        'being invoked by a Flutter SDK, or the Flutter SDK predates '
        'flutter_hook_config support. Check `config.buildForFlutter` first.',
      );
    }
    return FlutterConfig._(extensionJson);
  }

  Map<String, Object?>? get _flutterExtensionJson {
    final Object? extensions = json[_extensionsKey];
    if (extensions is! Map<String, Object?>) {
      return null;
    }
    final Object? flutterJson = extensions[_flutterExtensionKey];
    return flutterJson is Map<String, Object?> ? flutterJson : null;
  }
}

/// Extension on [HookConfigBuilder] for writing Flutter-specific configuration
/// onto a hook input.
///
/// This is intended for use by the Flutter SDK (`flutter_tools`) via
/// [FlutterExtension]; ordinary hook authors do not call this directly.
extension HookConfigBuilderFlutterConfig on HookConfigBuilder {
  /// Records the Flutter-specific configuration on a build or link hook input.
  ///
  /// [engineVersion] is an opaque identifier that must change whenever any
  /// engine artifact exposed here can change (typically the engine revision
  /// for a stock SDK; a stable identifier for the local engine output
  /// directory under `--local-engine`). Surfacing it as part of the config
  /// ensures the hook cache invalidates when the Flutter SDK is upgraded.
  ///
  /// [impellerc] and [libtessellator] must be absolute file URIs.
  void setupFlutter({
    required String engineVersion,
    required Uri impellerc,
    required Uri libtessellator,
  }) {
    assert(engineVersion.isNotEmpty, 'engineVersion must not be empty');
    assert(
      impellerc.isAbsolute && impellerc.isScheme('file'),
      'impellerc must be an absolute file URI',
    );
    assert(
      libtessellator.isAbsolute && libtessellator.isScheme('file'),
      'libtessellator must be an absolute file URI',
    );
    final extensions =
        (json[_extensionsKey] ??= <String, Object?>{}) as Map<String, Object?>;
    extensions[_flutterExtensionKey] = <String, Object?>{
      _engineVersionKey: engineVersion,
      _impellercKey: impellerc.toFilePath(),
      _libtessellatorKey: libtessellator.toFilePath(),
    };
  }
}
