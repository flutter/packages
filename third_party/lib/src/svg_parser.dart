import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'package:vector_math/vector_math_64.dart';

import 'svg/colors.dart';
import 'svg/parsers.dart';
import 'svg/xml_parsers.dart';
import 'utilities/xml.dart';
import 'vector_drawable.dart';

/// An SVG Shape element that will be drawn to the canvas.
class DrawableSvgShape extends DrawableShape {
  const DrawableSvgShape(Path path, DrawableStyle style) : super(path, style);

  /// Applies the transformation in the @transform attribute to the path.
  factory DrawableSvgShape.parse(
      SvgPathFactory pathFactory,
      DrawableDefinitionServer definitions,
      XmlElement el,
      DrawableStyle parentStyle) {
    assert(pathFactory != null);

    final Color defaultFill = parentStyle?.fill != null ? null : colorBlack;
    final Path path = pathFactory(el);
    return new DrawableSvgShape(
      applyTransformIfNeeded(path, el),
      parseStyle(el, definitions, path.getBounds(), parentStyle,
          defaultFillIfNotSpecified: defaultFill),
    );
  }
}

/// Creates a [Drawable] from an SVG <g> or shape element.  Also handles parsing <defs> and gradients.
///
/// If an unsupported element is encountered, it will be created as a [DrawableNoop].
Drawable parseSvgElement(XmlElement el, DrawableDefinitionServer definitions,
    Rect bounds, DrawableStyle parentStyle, String key) {
  final Function unhandled = (XmlElement e) => _unhandledElement(e, key);

  final SvgPathFactory shapeFn = svgPathParsers[el.name.local];
  if (shapeFn != null) {
    return new DrawableSvgShape.parse(shapeFn, definitions, el, parentStyle);
  } else if (el.name.local == 'defs') {
    parseDefs(el, definitions).forEach(unhandled);
    return new DrawableNoop(el.name.local);
  } else if (el.name.local.endsWith('Gradient')) {
    definitions.addPaintServer(
        'url(#${getAttribute(el, 'id')})', parseGradient(el));
    return new DrawableNoop(el.name.local);
  } else if (el.name.local == 'g' || el.name.local == 'a') {
    return parseSvgGroup(el, definitions, bounds, parentStyle, key);
  } else if (el.name.local == 'text') {
    return parseSvgText(el, definitions, bounds, parentStyle);
  } else if (el.name.local == 'svg') {
    throw new UnsupportedError(
        'Nested SVGs not supported in this implementation.');
  }

  unhandled(el);
  return new DrawableNoop(el.name.local);
}

void _unhandledElement(XmlElement el, String key) {
  if (el.name.local == 'style') {
    FlutterError.reportError(new FlutterErrorDetails(
      exception: new UnimplementedError(
          'The <style> element is not implemented in this library.'),
      informationCollector: (StringBuffer buff) {
        buff.writeln(
            'Style elements are not supported by this library and the requested SVG may not '
            'render as intended.\n'
            'If possible, ensure the SVG uses inline styles and/or attributes (which are '
            'supported), or use a preprocessing utility such as svgcleaner to inline the '
            'styles for you.');
        buff.writeln();
        buff.writeln('Picture key: $key');
      },
      library: 'SVG',
      context: 'in parseSvgElement',
    ));
  } else if (el.name.local != 'desc') {
    // no plans to handle these
    print('unhandled element ${el.name.local}; Picture key: $key');
  }
}

Drawable parseSvgText(XmlElement el, DrawableDefinitionServer definitions,
    Rect bounds, DrawableStyle parentStyle) {
  final Offset offset = new Offset(
      double.parse(getAttribute(el, 'x', def: '0')),
      double.parse(getAttribute(el, 'y', def: '0')));

  final Paint fill = parseFill(el, bounds, definitions, colorBlack);
  final Paint stroke = parseStroke(el, bounds, definitions);

  return new DrawableText(
    el.text,
    offset,
    DrawableStyle.mergeAndBlend(
      parentStyle,
      groupOpacity: parseOpacity(el),
      fill: fill,
      stroke: stroke,
      textStyle: new DrawableTextStyle(
        fontFamily: getAttribute(el, 'font-family'),
        fontSize: double.parse(getAttribute(el, 'font-size', def: '85')),
        height: -1.0,
      ),
    ),
  );
}

/// Parses an SVG <g> element.
Drawable parseSvgGroup(XmlElement el, DrawableDefinitionServer definitions,
    Rect bounds, DrawableStyle parentStyle, String key) {
  final List<Drawable> children = <Drawable>[];
  final DrawableStyle style =
      parseStyle(el, definitions, bounds, parentStyle, needsTransform: true);
  for (XmlNode child in el.children) {
    if (child is XmlElement) {
      final Drawable el =
          parseSvgElement(child, definitions, bounds, style, key);
      if (el != null) {
        children.add(el);
      }
    }
  }

  return new DrawableGroup(
      children,
      //TODO: when Dart2 is around use this instead of above
      // el.children
      //     .whereType<XmlElement>()
      //     .map((child) => new SvgBaseElement.fromXml(child)),
      style);
}

/// Parses style attributes or @style attribute.
///
/// Remember that @style attribute takes precedence.
DrawableStyle parseStyle(XmlElement el, DrawableDefinitionServer definitions,
    Rect bounds, DrawableStyle parentStyle,
    {bool needsTransform = false, Color defaultFillIfNotSpecified}) {
  final Matrix4 transform =
      needsTransform ? parseTransform(getAttribute(el, 'transform')) : null;

  return DrawableStyle.mergeAndBlend(
    parentStyle,
    transform: transform?.storage,
    stroke: parseStroke(el, bounds, definitions),
    dashArray: parseDashArray(el),
    dashOffset: parseDashOffset(el),
    fill: parseFill(el, bounds, definitions, defaultFillIfNotSpecified),
    pathFillType: parseFillRule(el),
    groupOpacity: parseOpacity(el),
    clipPath: parseClipPath(el, definitions),
  );
}
