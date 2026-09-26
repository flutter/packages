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
