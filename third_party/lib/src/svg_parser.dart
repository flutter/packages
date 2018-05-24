import 'dart:ui';

import 'package:xml/xml.dart';
import 'package:vector_math/vector_math_64.dart';

import 'svg/colors.dart';
import 'svg/parsers.dart';
import 'svg/xml_parsers.dart';
import 'utilities/xml.dart';
import 'vector_painter.dart';

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
    Rect bounds, DrawableStyle parentStyle) {
  final SvgPathFactory shapeFn = svgPathParsers[el.name.local];
  if (shapeFn != null) {
    return new DrawableSvgShape.parse(shapeFn, definitions, el, parentStyle);
  } else if (el.name.local == 'defs') {
    parseDefs(el, definitions);
    return new DrawableNoop(el.name.local);
  } else if (el.name.local.endsWith('Gradient')) {
    definitions.addPaintServer(
        'url(#${getAttribute(el, 'id')})', parseGradient(el));
    return new DrawableNoop(el.name.local);
  } else if (el.name.local == 'g' || el.name.local == 'a') {
    return parseSvgGroup(el, definitions, bounds, parentStyle);
  } else if (el.name.local == 'text') {
    return parseSvgText(el, definitions, bounds, parentStyle);
  } else if (el.name.local == 'svg') {
    throw new UnsupportedError(
        'Nested SVGs not supported in this implementation.');
  }
  print('Unhandled element ${el.name.local}');
  return new DrawableNoop(el.name.local);
}

Drawable parseSvgText(XmlElement el, DrawableDefinitionServer definitions,
    Rect bounds, DrawableStyle parentStyle) {
  final Offset offset = new Offset(
      double.parse(getAttribute(el, 'x', def: '0')),
      double.parse(getAttribute(el, 'y', def: '0')));

  return new DrawableText(
    el.text,
    offset,
    DrawableStyle.mergeAndBlend(
      parentStyle,
      groupOpacity: parseOpacity(el),
      textStyle: new TextStyle(
        fontFamily: getAttribute(el, 'font-family'),
        fontSize: double.parse(getAttribute(el, 'font-size', def: '55')),
        color: parseColor(
          getAttribute(
            el,
            'fill',
            def: getAttribute(el, 'stroke', def: 'black'),
          ),
        ),
        height: -1.0,
      ),
    ),
  );
}

/// Parses an SVG <g> element.
Drawable parseSvgGroup(XmlElement el, DrawableDefinitionServer definitions,
    Rect bounds, DrawableStyle parentStyle) {
  final List<Drawable> children = <Drawable>[];
  final DrawableStyle style =
      parseStyle(el, definitions, bounds, parentStyle, needsTransform: true);
  for (XmlNode child in el.children) {
    if (child is XmlElement) {
      final Drawable el = parseSvgElement(child, definitions, bounds, style);
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
