// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A callback used by [ShaderBuilder].
typedef ShaderBuilderCallback = Widget Function(
    BuildContext, ui.FragmentShader, Widget?);

/// A widget that loads and caches [FragmentProgram]s based on the asset key.
///
/// Usage of this widget avoids the need for a user authored stateful widget
/// for managing the lifecycle of loading a shader. Once a shader is cached,
/// subsequent usages of it via a [ShaderBuilder] will always be available
/// synchronously. These shaders can also be precached imperatively with
/// [ShaderBuilder.precacheShader].
///
/// If the shader is not yet loaded, the provided child widget or a [SizedBox]
/// is returned instead of invoking the builder callback.
///
/// Example: providing access to a [FragmentShader] instance.
///
/// ```dart
/// Widget build(BuildContext context) {
///  return ShaderBuilder(
///    builder: (BuildContext context, ui.FragmentShader shader, Widget? child) {
///      return WidgetThatUsesFragmentShader(
///        shader: shader,
///        child: child,
///      );
///    },
///    child: Text('Hello, Shader'),
///  );
/// }
/// ```
class ShaderBuilder extends StatefulWidget {
  /// Create a new [ShaderBuilder].
  const ShaderBuilder(
    this.builder, {
    super.key,
    required this.assetKey,
    this.child,
  });

  /// The asset key used to a lookup a shader.
  final String assetKey;

  /// The child widget to pass through to the [builder], optional.
  final Widget? child;

  /// The builder that provides access to a [FragmentShader].
  final ShaderBuilderCallback builder;

  @override
  State<StatefulWidget> createState() {
    return _ShaderBuilderState();
  }

  /// Precache a [FragmentProgram] based on its [assetKey].
  ///
  /// When this future has completed, any newly created [ShaderBuilder]s that
  /// reference this asset will be guaranteed to immediately have access to the
  /// shader.
  static Future<void> precacheShader(String assetKey) {
    if (_ShaderBuilderState._shaderCache.containsKey(assetKey)) {
      return Future<void>.value();
    }
    return ui.FragmentProgram.fromAsset(assetKey).then(
        (ui.FragmentProgram program) {
      _ShaderBuilderState._shaderCache[assetKey] = program;
    }, onError: (Object error, StackTrace stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    });
  }
}

class _ShaderBuilderState extends State<ShaderBuilder> {
  ui.FragmentProgram? program;
  ui.FragmentShader? shader;

  static final Map<String, ui.FragmentProgram> _shaderCache =
      <String, ui.FragmentProgram>{};

  @override
  void initState() {
    super.initState();
    _loadShader(widget.assetKey);
  }

  @override
  void didUpdateWidget(covariant ShaderBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetKey != widget.assetKey) {
      _loadShader(widget.assetKey);
    }
  }

  void _loadShader(String assetKey) {
    if (_shaderCache.containsKey(assetKey)) {
      program = _shaderCache[assetKey];
      shader = program!.fragmentShader();
      return;
    }

    ui.FragmentProgram.fromAsset(assetKey).then((ui.FragmentProgram program) {
      if (!mounted) {
        return;
      }
      setState(() {
        this.program = program;
        shader = program.fragmentShader();
        _shaderCache[assetKey] = program;
      });
    }, onError: (Object error, StackTrace stackTrace) {
      FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stackTrace));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (shader == null) {
      return widget.child ?? const SizedBox.shrink();
    }
    return widget.builder(context, shader!, widget.child);
  }
}
