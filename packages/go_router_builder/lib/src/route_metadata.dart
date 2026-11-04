// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

const _metadataChecker = TypeChecker.fromUrl('package:go_router/src/route_data.dart#RouteMetadata');
const _goRouteChecker = TypeChecker.fromUrl('package:go_router/src/route_data.dart#GoRouteData');
const _relativeRouteChecker = TypeChecker.fromUrl(
  'package:go_router/src/route_data.dart#RelativeGoRouteData',
);

/// Reads a route's metadata annotation and returns its constant expression.
///
/// Returns null when the class has no metadata annotation. Validation happens
/// while constructing the route configuration, before generating its members.
String? routeMetadataCode(InterfaceElement routeClass) {
  final List<DartObject> annotations = _metadataChecker.annotationsOfExact(routeClass).toList();
  if (annotations.isEmpty) {
    return null;
  }
  if (annotations.length != 1) {
    throw InvalidGenerationSourceError(
      'Only one @RouteMetadata annotation is allowed per route class.',
      element: routeClass,
    );
  }
  if (!routeClass.allSupertypes.any(
    (InterfaceType type) =>
        _goRouteChecker.isExactlyType(type) || _relativeRouteChecker.isExactlyType(type),
  )) {
    throw InvalidGenerationSourceError(
      '@RouteMetadata is only supported on GoRouteData and RelativeGoRouteData classes.',
      element: routeClass,
    );
  }
  final DartObject? values = annotations.single.getField('values');
  final Map<DartObject?, DartObject?>? map = values?.toMapValue();
  if (values == null || map == null || map.keys.any((key) => key?.toStringValue() == null)) {
    throw InvalidGenerationSourceError(
      'Could not evaluate @RouteMetadata values. Provide a constant map with String keys.',
      element: routeClass,
    );
  }
  return 'const ${_MetadataEncoder(routeClass).literal(values, 'metadata')}';
}

// Evaluated constants can originate in other libraries. Emit their values
// rather than source expressions, which may refer to inaccessible identifiers.
class _MetadataEncoder {
  _MetadataEncoder(this.routeClass);

  final InterfaceElement routeClass;

  String literal(DartObject? value, String path) {
    if (value == null) {
      _unsupported(path, 'an unevaluated constant');
    }
    if (value.isNull) {
      return 'null';
    }
    final String? string = value.toStringValue();
    if (string != null) {
      return escapeDartString(string);
    }
    final bool? boolean = value.toBoolValue();
    if (boolean != null) {
      return '$boolean';
    }
    final int? integer = value.toIntValue();
    if (integer != null) {
      return '$integer';
    }
    final double? number = value.toDoubleValue();
    if (number != null) {
      if (number.isNaN) {
        return 'double.nan';
      }
      if (number.isInfinite) {
        return number.isNegative ? 'double.negativeInfinity' : 'double.infinity';
      }
      return '$number';
    }
    final List<DartObject>? list = value.toListValue();
    final Iterable<DartObject>? elements = list ?? value.toSetValue();
    if (elements != null) {
      final contents = <String>[];
      var index = 0;
      for (final DartObject element in elements) {
        contents.add(literal(element, '$path[${index++}]'));
      }
      final String arguments = _typeArguments(value, path);
      return list != null
          ? '$arguments[${contents.join(', ')}]'
          : '$arguments{${contents.join(', ')}}';
    }
    final Map<DartObject?, DartObject?>? map = value.toMapValue();
    if (map != null) {
      final entries = <String>[];
      var index = 0;
      for (final MapEntry<DartObject?, DartObject?> entry in map.entries) {
        final String key = literal(entry.key, '$path.keys[$index]');
        entries.add('$key: ${literal(entry.value, '$path[$key]')}');
        index++;
      }
      return '${_typeArguments(value, path)}{${entries.join(', ')}}';
    }
    _unsupported(path, 'a value of type ${value.type}');
  }

  String _typeArguments(DartObject value, String path) {
    if (value.type case InterfaceType(:final List<DartType> typeArguments)) {
      if (typeArguments.isEmpty) {
        return '';
      }
      return '<${typeArguments.map((DartType type) => _typeCode(type, path)).join(', ')}>';
    }
    _unsupported(path, 'an unresolved collection type');
  }

  String _typeCode(DartType type, String path) {
    if (type is DynamicType) {
      return 'dynamic';
    }
    if (type is NeverType) {
      return 'Never${type.nullabilitySuffix == NullabilitySuffix.question ? '?' : ''}';
    }
    if (type is VoidType) {
      return 'void';
    }
    if (type is InterfaceType && type.element.library.uri.toString() == 'dart:core') {
      final arguments = type.typeArguments.isEmpty
          ? ''
          : '<${type.typeArguments.map((DartType type) => _typeCode(type, path)).join(', ')}>';
      final nullable = type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';
      return '${type.element.displayName}$arguments$nullable';
    }
    _unsupported(path, 'a collection type argument $type');
  }

  Never _unsupported(String path, String description) {
    throw InvalidGenerationSourceError(
      'Unsupported @RouteMetadata at $path: $description. '
      'Use null, bool, String, int, double, or lists, sets, and maps of supported values '
      'with dart:core type arguments.',
      element: routeClass,
    );
  }
}
