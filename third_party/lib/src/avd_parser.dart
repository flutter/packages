// ignore_for_file: public_member_api_docs
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:xml/xml.dart';

import 'avd/xml_parsers.dart';
import 'vector_drawable.dart';

class DrawableAvdRoot extends DrawableRoot {
  const DrawableAvdRoot(
      String id,
      DrawableViewport viewBox,
      List<Drawable> children,
      DrawableDefinitionServer definitions,
      DrawableStyle style)
      : super(id, viewBox, children, definitions, style);
}

/// An SVG Shape element that will be drawn to the canvas.
class DrawableAvdPath extends DrawableShape {
  const DrawableAvdPath(String? id, Path path, DrawableStyle style)
      : super(id, path, style);

  /// Creates a [DrawableAvdPath] from an XML <path> element
  factory DrawableAvdPath.fromXml(XmlElement el) {
    final String d =
        getAttribute(el.attributes, 'pathData', def: '', namespace: androidNS)!;
    final Path path = parseSvgPathData(d);
    assert(path != null); // ignore: unnecessary_null_comparison

    path.fillType = parsePathFillType(el.attributes);
    final DrawablePaint? stroke = parseStroke(el.attributes, path.getBounds());
    final DrawablePaint? fill = parseFill(el.attributes, path.getBounds());

    return DrawableAvdPath(
      getAttribute(el.attributes, 'id', def: ''),
      path,
      DrawableStyle(stroke: stroke, fill: fill),
    );
  }
}

/// Creates a [Drawable] from an SVG <g> or shape element.  Also handles parsing <defs> and gradients.
///
/// If an unsupported element is encountered, it will be created as a [DrawableNoop].
Drawable parseAvdElement(XmlElement el, Rect bounds) {
  if (el.name.local == 'path') {
    return DrawableAvdPath.fromXml(el);
  } else if (el.name.local == 'group') {
    return parseAvdGroup(el, bounds);
  }
  // TODO(dnfield): clipPath
  print('Unhandled element ${el.name.local}');
  return const DrawableGroup('', null, null);
}

/// Parses an AVD <group> element.
Drawable parseAvdGroup(XmlElement el, Rect bounds) {
  final List<Drawable> children = <Drawable>[];
  for (XmlNode child in el.children) {
    if (child is XmlElement) {
      final Drawable el = parseAvdElement(child, bounds);
      children.add(el);
    }
  }

  final Matrix4 transform = parseTransform(el.attributes);

  final DrawablePaint? fill = parseFill(el.attributes, bounds);
  final DrawablePaint? stroke = parseStroke(el.attributes, bounds);

  return DrawableGroup(
    getAttribute(el.attributes, 'id', def: ''),
    children,
    DrawableStyle(
      stroke: stroke,
      fill: fill,
      groupOpacity: 1.0,
    ),
    transform: transform.storage,
  );
}
