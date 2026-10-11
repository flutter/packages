// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:xml/xml.dart';

import 'constants.dart';
import 'numbers.dart';
import 'style.dart';
import 'theme.dart';

/// Resolves a filter color using the compiler's theme and color mapper.
typedef FilterColorResolver =
    int Function({
      required String value,
      required String? currentColor,
      required String? id,
      required String element,
      required String attribute,
    });

/// Checks whether a filter presentation property contains a supported color.
typedef FilterColorValidator = bool Function(String value);

/// Reads filter definitions separately so forward references work.
Map<String, VectorFilter> readFilterDefinitions(
  String source, {
  FilterColorResolver? resolveColor,
  FilterColorValidator? validColor,
  SvgTheme theme = const SvgTheme(),
}) {
  if (!source.contains('filter')) {
    return <String, VectorFilter>{};
  }
  bool validProperty(String name, String value) {
    if (<String>{
      'inherit',
      'initial',
      'unset',
      'revert',
      'revert-layer',
    }.contains(cssWideKeyword(value))) {
      return true;
    }
    if (<String>{'color', 'flood-color'}.contains(name)) {
      return validColor == null || validColor(value);
    }
    if (name == 'color-interpolation-filters') {
      return <String>{'auto', 'srgb', 'linearrgb'}.contains(value.toLowerCase());
    }
    if (name == 'flood-opacity') {
      final String number = value.endsWith('%') ? value.substring(0, value.length - 1) : value;
      return double.tryParse(number)?.isFinite ?? false;
    }
    return true;
  }

  final cachedAttributes = Map<XmlElement, Map<String, String>>.identity();
  Map<String, String> attributesOf(XmlElement element) => cachedAttributes.putIfAbsent(element, () {
    final attributes = <String, String>{
      for (final attribute in element.attributes) attribute.name.local: attribute.value.trim(),
    };
    // SVG 2 href wins over xlink:href regardless of XML attribute order.
    final XmlAttribute? href = element.attributes
        .where((XmlAttribute a) => a.name.local == 'href' && a.name.prefix == null)
        .firstOrNull;
    if (href != null) {
      attributes['href'] = href.value.trim();
    }
    return resolveInlineStyles(attributes, validProperty: validProperty);
  });

  String property(XmlElement element, String name, String initial, {bool inherited = false}) {
    var computed = initial;
    for (final ancestor in <XmlElement>[
      ...element.ancestors.whereType<XmlElement>().toList().reversed,
      element,
    ]) {
      String? value = attributesOf(ancestor)[name];
      if (value != null) {
        value = cssWideKeyword(value);
        if (value == 'revert' || value == 'revert-layer') {
          value = 'unset';
        }
      }
      if (value != null && !validProperty(name, value)) {
        value = null;
      }
      if (value == 'inherit' || (name == 'color' && value?.toLowerCase() == 'currentcolor')) {
        continue;
      }
      if (value == 'initial' || ((!inherited) && (value == null || value == 'unset'))) {
        computed = initial;
      } else if (value != null && value != 'unset') {
        computed = value;
      }
    }
    return computed;
  }

  const ignoredChildren = <String>{
    'title',
    'desc',
    'metadata',
    'animate',
    'animateTransform',
    'animateMotion',
    'set',
    'script',
  };
  Iterable<XmlElement> childrenOf(XmlElement element) =>
      element.childElements.where((child) => !ignoredChildren.contains(child.name.local));

  // Determine liveness from names and inputs before resolving lengths, colors
  // or image resources. A disconnected primitive cannot affect the output.
  VectorFilter graphOf(XmlElement element) => VectorFilter(
    element.name.local,
    attributesOf(element),
    <VectorFilter>[for (final child in childrenOf(element)) graphOf(child)],
  );

  VectorFilter read(XmlElement element) {
    final attributes = Map<String, String>.of(attributesOf(element));
    double fontSize = theme.fontSize;
    double rootFontSize = theme.fontSize;
    final double xHeightRatio = theme.fontSize == 0 ? .5 : theme.xHeight / theme.fontSize;
    for (final ancestor in <XmlElement>[
      ...element.ancestors.whereType<XmlElement>().toList().reversed,
      element,
    ]) {
      final String? rawSize = attributesOf(ancestor)['font-size'];
      final String? size = rawSize == null ? null : cssWideKeyword(rawSize);
      if (size != null && !<String>{'inherit', 'unset', 'revert', 'revert-layer'}.contains(size)) {
        fontSize = size == 'initial'
            ? theme.fontSize
            : svgFontSizes[size.trim().toLowerCase()] ??
                  parseSvgLength(
                    size,
                    fontSize: fontSize,
                    xHeight: xHeightRatio * fontSize,
                    rootFontSize: rootFontSize,
                    percentageRef: fontSize,
                  );
      }
      if (ancestor.parent is XmlDocument) {
        rootFontSize = fontSize;
      }
    }
    // Percentages and unitless object-bounding-box values need runtime bounds.
    // Absolute and font-relative lengths can be normalized in the definition's
    // style context, which need not match the element using the filter.
    final bool hasRegion =
        element.name.local == 'filter' ||
        (element.parent is XmlElement && (element.parent! as XmlElement).name.local == 'filter');
    for (final name in hasRegion ? <String>['x', 'y', 'width', 'height'] : <String>[]) {
      final String? value = attributes[name];
      if (value != null && !value.trim().endsWith('%') && double.tryParse(value.trim()) == null) {
        attributes[name] = parseSvgLength(
          value,
          fontSize: fontSize,
          xHeight: xHeightRatio * fontSize,
          rootFontSize: rootFontSize,
        ).toString();
      }
    }
    String? colorSpace;
    for (final ancestor in <XmlElement>[
      ...element.ancestors.whereType<XmlElement>().toList().reversed,
      element,
    ]) {
      final String? rawValue = attributesOf(ancestor)['color-interpolation-filters'];
      String? value = rawValue == null ? null : cssWideKeyword(rawValue);
      if (value == 'revert' || value == 'revert-layer') {
        value = 'unset';
      }
      if (value == 'initial') {
        colorSpace = 'linearRGB';
      } else if (value != null &&
          value != 'inherit' &&
          value != 'unset' &&
          validProperty('color-interpolation-filters', value)) {
        colorSpace = switch (value.toLowerCase()) {
          'srgb' => 'sRGB',
          'linearrgb' => 'linearRGB',
          _ => 'auto',
        };
      }
    }
    if (colorSpace != null) {
      attributes['color-interpolation-filters'] = colorSpace;
    } else {
      attributes.remove('color-interpolation-filters');
    }
    if (element.name.local == 'feFlood' && resolveColor != null) {
      attributes['flood-color-argb'] = resolveColor(
        value: property(element, 'flood-color', 'black'),
        currentColor: property(element, 'color', 'currentColor', inherited: true),
        id: attributes['id'],
        element: element.name.local,
        attribute: 'flood-color',
      ).toString();
      attributes['flood-opacity'] = property(element, 'flood-opacity', '1');
    }
    final List<XmlElement> children = childrenOf(element).toList();
    Set<VectorFilter>? active;
    List<VectorFilter>? graphChildren;
    if (element.name.local == 'filter') {
      final VectorFilter graph = graphOf(element);
      graphChildren = graph.children;
      active = Set<VectorFilter>.identity()..addAll(graph.activePrimitives);
    }
    return VectorFilter(element.name.local, attributes, <VectorFilter>[
      for (var i = 0; i < children.length; i++)
        if (active == null || active.contains(graphChildren![i])) read(children[i]),
    ]);
  }

  final definitions = <String, XmlElement>{
    for (final XmlElement element in XmlDocument.parse(source).descendants.whereType<XmlElement>())
      if (element.name.local == 'filter' && element.getAttribute('id') != null)
        'url(#${element.getAttribute('id')})': element,
  };
  return _FilterDefinitions(definitions, read, attributesOf);
}

// Index eagerly, but only parse and resolve definitions reached by rendering.
// Iterating keys or testing isNotEmpty must not evaluate unused resources.
class _FilterDefinitions extends UnmodifiableMapBase<String, VectorFilter> {
  _FilterDefinitions(this.definitions, this.read, this.attributesOf);

  final Map<String, XmlElement> definitions;
  final VectorFilter Function(XmlElement) read;
  final Map<String, String> Function(XmlElement) attributesOf;
  final resolved = <String, VectorFilter>{};

  @override
  Iterable<String> get keys => definitions.keys;

  @override
  VectorFilter? operator [](Object? id) {
    if (id is! String || !definitions.containsKey(id)) {
      return null;
    }
    // Resolve forward references iteratively and reuse already-resolved templates.
    final chain = <String>{};
    String? current = id;
    while (current != null && definitions.containsKey(current) && !resolved.containsKey(current)) {
      if (!chain.add(current)) {
        throw const FormatException('Circular SVG filter reference');
      }
      if (chain.length > kMaxReferenceExpansions) {
        throw StateError(kMaxReferenceExpansionsErrorMessage);
      }
      final String? href = attributesOf(definitions[current]!)['href'];
      final String? local = href == null ? null : localFilterTarget(href);
      current = local == null ? null : 'url($local)';
    }
    VectorFilter? base = resolved[current];
    for (final String key in chain.toList().reversed) {
      final VectorFilter own = read(definitions[key]!);
      base = VectorFilter(own.name, <String, String>{
        if (base != null) ...base.attributes,
        ...own.attributes,
      }, own.children.isEmpty ? base?.children ?? own.children : own.children);
      resolved[key] = base;
    }
    return resolved[id];
  }
}
