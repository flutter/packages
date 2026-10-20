// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

/// A callback used by [MultiShaderBuilder].
typedef MultiShaderBuilderCallback = Widget Function(
  BuildContext context,
  List<ui.FragmentShader> shaders,
  Widget? child,
);

/// A callback used by [ShaderBuilder].
typedef ShaderBuilderCallback = Widget Function(
  BuildContext context,
  ui.FragmentShader shader,
  Widget? child,
);

/// A widget that loads and caches a single [ui.FragmentProgram] based on an [assetKey].
class ShaderBuilder extends StatelessWidget {
  /// Create a new [ShaderBuilder].
  const ShaderBuilder(
    this.builder, {
    required this.assetKey,
    super.key,
    this.child,
  });

  /// The asset key used to lookup the shader.
  final String assetKey;

  /// The child widget to pass through to the [builder], optional.
  final Widget? child;

  /// The builder that provides access to the [ui.FragmentShader].
  final ShaderBuilderCallback builder;

  @override
  Widget build(BuildContext context) {
    return MultiShaderBuilder(
      (context, shaders, child) => builder(context, shaders.first, child),
      assetKeys: [assetKey],
      child: child,
    );
  }
}

/// A widget that loads and caches [ui.FragmentProgram]s based on asset keys.
///
/// Usage of this widget avoids the need for a user authored stateful widget
/// for managing the lifecycle of loading shaders. Once shaders are cached,
/// subsequent usages of them via a [MultiShaderBuilder] will always be
/// available synchronously. These shaders can also be precached imperatively
/// with [MultiShaderBuilder.precacheShader].
///
/// If the shaders are not yet loaded, the provided child widget or a [SizedBox]
/// is returned instead of invoking the builder callback.
///
/// Example: providing access to [ui.FragmentShader] instances.
///
/// ```dart
/// Widget build(BuildContext context) {
///  return ShaderBuilder(
///    builder: (BuildContext context, List<ui.FragmentShader> shaders, Widget?
/// child) {
///      return WidgetThatUsesFragmentShaders(
///        shaders: shaders,
///        child: child,
///      );
///    },
///    assetKeys: ['shader1.frag', 'shader2.frag'],
///    child: Text('Hello, Shaders'),
///  );
/// }
/// ```
class MultiShaderBuilder extends StatefulWidget {
  /// Create a new [MultiShaderBuilder].
  const MultiShaderBuilder(
    this.builder, {
    required this.assetKeys,
    super.key,
    this.child,
  });

  /// The asset keys used to lookup shaders.
  final List<String> assetKeys;

  /// The child widget to pass through to the [builder], optional.
  final Widget? child;

  /// The builder that provides access to [ui.FragmentShader]s.
  final MultiShaderBuilderCallback builder;

  @override
  State<StatefulWidget> createState() {
    return _MultiShaderBuilderState();
  }

  /// Precache a [ui.FragmentProgram] based on its [assetKey].
  ///
  /// When this future has completed, any newly created [MultiShaderBuilder]s
  /// that reference this asset will be guaranteed to immediately have access to
  /// the shader.
  static Future<void> precacheShader(String assetKey) {
    if (_MultiShaderBuilderState._shaderCache.containsKey(assetKey)) {
      return Future<void>.value();
    }
    return ui.FragmentProgram.fromAsset(assetKey).then(
      (ui.FragmentProgram program) {
        _MultiShaderBuilderState._shaderCache[assetKey] = program;
      },
      onError: (Object error, StackTrace stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace),
        );
      },
    );
  }

  /// Precache multiple [ui.FragmentProgram]s based on their [assetKeys].
  ///
  /// When this future has completed, any newly created [MultiShaderBuilder]s
  /// that reference these assets will be guaranteed to immediately have access
  /// to the shaders.
  static Future<void> precacheShaders(List<String> assetKeys) {
    return Future.wait(
      assetKeys.map(precacheShader),
    );
  }

  /// Returns the cached [ui.FragmentProgram] for [assetKey], or `null` if it
  /// has not been precached yet.
  ///
  /// This is an internal accessor used by the pipeline warm-up path in
  /// [LiquidGlassWidgets.initialize] to reuse already-compiled program objects
  /// rather than loading them a second time from the asset bundle.
  ///
  /// Must only be called after [precacheShaders] has completed for the
  /// requested [assetKey].
  // ignore: library_private_types_in_public_api
  static ui.FragmentProgram? cachedProgram(String assetKey) =>
      _MultiShaderBuilderState._shaderCache[assetKey];
}

class _MultiShaderBuilderState extends State<MultiShaderBuilder> {
  final Map<String, ui.FragmentProgram> _programs = {};
  final Map<String, ui.FragmentShader> _shaders = {};

  static final Map<String, ui.FragmentProgram> _shaderCache =
      <String, ui.FragmentProgram>{};

  @override
  void initState() {
    super.initState();
    _loadShaders(widget.assetKeys);
  }

  @override
  void didUpdateWidget(covariant MultiShaderBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compare by content: ShaderBuilder passes a new list on every build, and
    // reloading would hand out a new FragmentShader on every rebuild.
    if (!listEquals(oldWidget.assetKeys, widget.assetKeys)) {
      _loadShaders(widget.assetKeys);
    }
  }

  @override
  void dispose() {
    // Render objects built from these shaders are unmounted before this state
    // is, so nothing is still drawing with them.
    for (final shader in _shaders.values) {
      shader.dispose();
    }
    _shaders.clear();
    _programs.clear();
    super.dispose();
  }

  void _loadShaders(List<String> assetKeys) {
    // The shaders this state created for the previous keys. Disposed after the
    // frame rather than now: consumers still hold them until they rebuild with
    // the new ones, and this frame may yet paint with them.
    final replaced = _shaders.values.toList();
    if (replaced.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final shader in replaced) {
          shader.dispose();
        }
      });
    }
    _programs.clear();
    _shaders.clear();

    // Check which shaders are already cached
    final uncachedKeys = <String>[];
    for (final assetKey in assetKeys) {
      if (_shaderCache.containsKey(assetKey)) {
        _programs[assetKey] = _shaderCache[assetKey]!;
        _shaders[assetKey] = _programs[assetKey]!.fragmentShader();
      } else {
        uncachedKeys.add(assetKey);
      }
    }

    // If all shaders are cached, we're done
    if (uncachedKeys.isEmpty) {
      return;
    }

    // Load uncached shaders
    for (final assetKey in uncachedKeys) {
      ui.FragmentProgram.fromAsset(assetKey).then(
        (ui.FragmentProgram program) {
          _shaderCache[assetKey] = program;
          // A load that overlapped another for the same key (the keys changed
          // and changed back) must not replace a shader already handed out.
          if (!mounted ||
              !widget.assetKeys.contains(assetKey) ||
              _shaders.containsKey(assetKey)) {
            return;
          }
          setState(() {
            _programs[assetKey] = program;
            _shaders[assetKey] = program.fragmentShader();
          });
        },
        onError: (Object error, StackTrace stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(exception: error, stack: stackTrace),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if all shaders requested by the current widget are loaded.
    // Checking key presence rather than map length prevents crashes if stale
    // shaders finished loading after assetKeys changed.
    final allLoaded =
        widget.assetKeys.every((key) => _shaders.containsKey(key));
    if (!allLoaded) {
      return widget.child ?? const SizedBox.shrink();
    }

    // Build shader list in the same order as assetKeys
    final shaders = widget.assetKeys.map((key) => _shaders[key]!).toList();

    return widget.builder(context, shaders, widget.child);
  }
}
