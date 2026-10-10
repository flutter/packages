// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// A serializable SVG filter element or primitive.
///
/// Attributes retain SVG units until the renderer knows the object's bounds.
@immutable
class VectorFilter {
  /// Creates an immutable filter description.
  VectorFilter(this.name, Map<String, String> attributes, [List<VectorFilter> children = const []])
    : attributes = Map<String, String>.unmodifiable(attributes),
      children = List<VectorFilter>.unmodifiable(children);

  /// Reads the version-independent description inside a filter command.
  factory VectorFilter.fromJson(Map<String, Object?> json) {
    final Object? name = json['name'];
    final Object? attributes = json['attributes'];
    final Object? children = json['children'];
    if (name is! String || attributes is! Map || children is! List) {
      throw const FormatException('Invalid vector filter description');
    }
    return VectorFilter(name, Map<String, String>.from(attributes), <VectorFilter>[
      for (final Object? child in children)
        VectorFilter.fromJson(Map<String, Object?>.from(child! as Map)),
    ]);
  }

  /// The SVG element name.
  final String name;

  /// Presentation attributes, including resolved inline styles.
  final Map<String, String> attributes;

  /// Child primitives or parameter elements, in document order.
  final List<VectorFilter> children;

  /// Primitives contributing to the last result, in their original order.
  ///
  /// Missing, unknown and forward inputs resolve to the immediately preceding
  /// primitive. Named inputs resolve before publishing the current result, and
  /// the six built-in sources take precedence over result names. Parameter
  /// children (merge nodes, channel functions and lights) remain unchanged.
  List<VectorFilter> get activePrimitives => _activePrimitives;
  late final List<VectorFilter> _activePrimitives = _findActivePrimitives();

  List<VectorFilter> _findActivePrimitives() {
    if (name != 'filter' || children.isEmpty) {
      return children;
    }
    const sources = <String>{
      'SourceGraphic',
      'SourceAlpha',
      'BackgroundImage',
      'BackgroundAlpha',
      'FillPaint',
      'StrokePaint',
    };
    final results = <String, int>{};
    final dependencies = <List<int>>[];
    for (var i = 0; i < children.length; i++) {
      final VectorFilter primitive = children[i];
      final inputs = <int>[];
      void input(String? name) {
        if (sources.contains(name)) {
          return;
        }
        final int dependency = results[name] ?? i - 1;
        if (dependency >= 0) {
          inputs.add(dependency);
        }
      }

      switch (primitive.name) {
        case 'feFlood':
        case 'feImage':
        case 'feTurbulence':
          break;
        case 'feMerge':
          for (final VectorFilter node in primitive.children) {
            input(node.attributes['in']);
          }
        case 'feBlend':
        case 'feComposite':
        case 'feDisplacementMap':
          input(primitive.attributes['in']);
          input(primitive.attributes['in2']);
        default:
          input(primitive.attributes['in']);
      }
      dependencies.add(inputs);
      final String? result = primitive.attributes['result'];
      if (result != null && result.isNotEmpty) {
        results[result] = i;
      }
    }
    // Every edge points backwards: reverse traversal needs no recursion even
    // for a long chain, and visiting each edge once is sufficient.
    final active = List<bool>.filled(children.length, false)..last = true;
    for (int i = children.length - 1; i >= 0; i--) {
      if (active[i]) {
        for (final int dependency in dependencies[i]) {
          active[dependency] = true;
        }
      }
    }
    return List<VectorFilter>.unmodifiable(<VectorFilter>[
      for (var i = 0; i < children.length; i++)
        if (active[i]) children[i],
    ]);
  }

  @override
  int get hashCode => Object.hash(
    name,
    Object.hashAllUnordered(
      attributes.entries.map((MapEntry<String, String> e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAll(children),
  );

  @override
  bool operator ==(Object other) {
    if (other is! VectorFilter ||
        name != other.name ||
        attributes.length != other.attributes.length ||
        children.length != other.children.length) {
      return false;
    }
    for (final MapEntry<String, String> entry in attributes.entries) {
      if (other.attributes[entry.key] != entry.value) {
        return false;
      }
    }
    for (var i = 0; i < children.length; i++) {
      if (children[i] != other.children[i]) {
        return false;
      }
    }
    return true;
  }

  /// Produces a JSON-compatible representation.
  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'attributes': attributes,
    'children': <Object?>[for (final VectorFilter child in children) child.toJson()],
  };
}
