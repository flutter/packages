// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:vector_graphics_codec/vector_graphics_codec.dart';
import 'package:xml/xml.dart';

import 'numbers.dart';
import 'theme.dart';

/// Reads filter definitions separately so forward references work.
Map<String, VectorFilter> readFilterDefinitions(
  String source, {
  SvgTheme theme = const SvgTheme(),
}) {
  if (!source.contains('filter')) {
    return <String, VectorFilter>{};
  }
  Map<String, String> attributesOf(XmlElement element) {
    final attributes = <String, String>{
      for (final XmlAttribute attribute in element.attributes)
        attribute.name.local: attribute.value,
    };
    for (final String declaration in (attributes['style'] ?? '').split(';')) {
      final int separator = declaration.indexOf(':');
      if (separator > 0) {
        attributes[declaration.substring(0, separator).trim()] = declaration
            .substring(separator + 1)
            .trim();
      }
    }
    return attributes;
  }

  VectorFilter read(XmlElement element) {
    final Map<String, String> attributes = attributesOf(element);
    double fontSize = theme.fontSize;
    double rootFontSize = theme.fontSize;
    final double xHeightRatio = theme.fontSize == 0 ? .5 : theme.xHeight / theme.fontSize;
    for (final ancestor in <XmlElement>[
      ...element.ancestors.whereType<XmlElement>().toList().reversed,
      element,
    ]) {
      final String? size = attributesOf(ancestor)['font-size'];
      if (size != null && size != 'inherit' && size != 'unset') {
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
    return VectorFilter(element.name.local, attributes, <VectorFilter>[
      for (final XmlElement child in element.childElements)
        if (!<String>{'title', 'desc', 'metadata'}.contains(child.name.local)) read(child),
    ]);
  }

  return <String, VectorFilter>{
    for (final XmlElement element in XmlDocument.parse(source).descendants.whereType<XmlElement>())
      if (element.name.local == 'filter' && element.getAttribute('id') != null)
        'url(#${element.getAttribute('id')})': read(element),
  };
}
