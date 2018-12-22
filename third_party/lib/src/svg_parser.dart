import 'dart:async';
import 'dart:convert' hide Codec;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'package:vector_math/vector_math_64.dart';

import 'svg/parsers.dart';
import 'svg/xml_parsers.dart';
import 'utilities/http.dart';
import 'utilities/xml.dart';
import 'vector_drawable.dart';

/// An SVG Shape element that will be drawn to the canvas.
class DrawableSvgShape extends DrawableShape {
  const DrawableSvgShape(Path path, DrawableStyle style, this.transform)
      : super(path, style);

  /// Applies the transformation in the @transform attribute to the path.
  factory DrawableSvgShape.parse(
      SvgPathFactory pathFactory,
      DrawableDefinitionServer definitions,
      XmlElement el,
      DrawableStyle parentStyle) {
    assert(pathFactory != null);

    final Path path = pathFactory(el);
    return DrawableSvgShape(
      path,
      parseStyle(
        el,
        definitions,
        path.getBounds(),
        parentStyle,
      ),
      parseTransform(getAttribute(el, 'transform', def: null)),
    );
  }

  /// The transformation matrix, if any, to apply to the [Canvas] before
  /// [draw]ing this shape.
  final Matrix4 transform;

  @override
  void draw(Canvas canvas, ColorFilter colorFilter) {
    if (transform != null) {
      canvas.save();
      canvas.transform(transform.storage);
      super.draw(canvas, colorFilter);
      canvas.restore();
    } else {
      super.draw(canvas, colorFilter);
    }
  }
}

/// Creates a [Drawable] from an SVG <g> or shape element.  Also handles parsing <defs> and gradients.
///
/// If an unsupported element is encountered, it will be created as a [DrawableNoop].
Future<Drawable> parseSvgElement(
  XmlElement el,
  DrawableDefinitionServer definitions,
  Rect rootBounds,
  DrawableStyle parentStyle,
  String key, {
  bool isDef = false,
}) async {
  assert(isDef != null);
  final Function unhandled = (XmlElement e) => _unhandledElement(e, key);
  final Function createDefinition = (String iri, XmlElement defEl) async {
    assert(iri != emptyUrlIri);
    definitions.addDrawable(
      iri,
      await parseSvgElement(
        defEl,
        definitions,
        rootBounds,
        parentStyle,
        key,
        isDef: true,
      ),
    );
  };

  final SvgPathFactory shapeFn = svgPathParsers[el.name.local];
  if (shapeFn != null) {
    final DrawableShape shape =
        DrawableSvgShape.parse(shapeFn, definitions, el, parentStyle);
    final String iri = buildUrlIri(el);
    if (iri != emptyUrlIri) {
      definitions.addDrawable(iri, shape);
    }
    return shape;
  } else if (el.name.local == 'defs') {
    final Iterable<XmlElement> unhandledDefs = parseDefs(
      el,
      definitions,
      rootBounds,
    );
    for (XmlElement unhandledDef in unhandledDefs) {
      if (unhandledDef.name.local == 'style') {
        unhandled(unhandledDef);
        continue;
      }
      String iri = buildUrlIri(unhandledDef);
      if (iri == emptyUrlIri) {
        for (XmlElement child
            in unhandledDef.children.whereType<XmlElement>()) {
          iri = buildUrlIri(child);
          if (iri != emptyUrlIri) {
            await createDefinition(iri, child);
          }
        }
      } else {
        await createDefinition(iri, unhandledDef);
      }
    }
    return DrawableNoop(el.name.local);
  } else if (el.name.local.endsWith('Gradient')) {
    definitions.addPaintServer(
      'url(#${getAttribute(el, 'id')})',
      parseGradient(el, rootBounds),
    );
    return DrawableNoop(el.name.local);
  } else if (el.name.local == 'g' ||
      el.name.local == 'a' ||
      el.name.local == 'symbol') {
    final DrawableGroup group = await parseSvgGroup(
      el,
      definitions,
      rootBounds,
      parentStyle,
      key,
    );
    final String iri = buildUrlIri(el);
    if (iri != emptyUrlIri) {
      definitions.addDrawable(iri, group);
    }
    return el.name.local == 'symbol' && !isDef
        ? const DrawableNoop('symbol')
        : group;
  } else if (el.name.local == 'text') {
    return parseSvgText(el, definitions, rootBounds, parentStyle);
  } else if (el.name.local == 'svg') {
    throw UnsupportedError('Nested SVGs not supported in this implementation.');
  } else if (el.name.local == 'image') {
    final String href = getHrefAttribute(el);
    final Offset offset = Offset(
      double.parse(getAttribute(el, 'x', def: '0')),
      double.parse(getAttribute(el, 'y', def: '0')),
    );
    final Size size = Size(
      double.parse(getAttribute(el, 'width', def: '0')),
      double.parse(getAttribute(el, 'height', def: '0')),
    );
    final Image image = await _resolveImage(href);
    return DrawableRasterImage(image, offset, size: size);
  } else if (el.name.local == 'use') {
    final String xlinkHref = getHrefAttribute(el);
    final DrawableStyle style = parseStyle(
      el,
      definitions,
      rootBounds,
      null,
    );
    final Matrix4 transform = Matrix4.identity()
      ..translate(
        double.parse(getAttribute(el, 'x', def: '0')),
        double.parse(getAttribute(el, 'y', def: '0')),
      );
    final DrawableStyleable ref = definitions.getDrawable('url($xlinkHref)');
    return DrawableGroup(
      <Drawable>[ref.mergeStyle(style)],
      DrawableStyle(transform: transform.storage),
    );
  }

  unhandled(el);
  return DrawableNoop(el.name.local);
}

Set<String> _unhandledElements = Set<String>();

void _unhandledElement(XmlElement el, String key) {
  if (el.name.local == 'style') {
    FlutterError.reportError(FlutterErrorDetails(
      exception: UnimplementedError(
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
    return;
  }
  assert(() {
    if (_unhandledElements.add(el.name.local)) {
      print('unhandled element ${el.name.local}; Picture key: $key');
    }
    return true;
  }());
}

const DrawablePaint _transparentStroke =
    DrawablePaint(PaintingStyle.stroke, color: Color(0x0));
void _appendParagraphs(ParagraphBuilder fill, ParagraphBuilder stroke,
    String text, DrawableStyle style) {
  fill
    ..pushStyle(
        style.textStyle.toFlutterTextStyle(foregroundOverride: style.fill))
    ..addText(text);

  stroke
    ..pushStyle(style.textStyle.toFlutterTextStyle(
        foregroundOverride:
          DrawablePaint.isEmpty(style.stroke) ? _transparentStroke : style.stroke))
    ..addText(text);
}

final ParagraphConstraints _infiniteParagraphConstraints =
    ParagraphConstraints(width: double.infinity);

Paragraph _finishParagraph(ParagraphBuilder paragraphBuilder) {
  final Paragraph paragraph = paragraphBuilder.build();
  paragraph.layout(_infiniteParagraphConstraints);
  return paragraph;
}

Drawable _paragraphParser(
    ParagraphBuilder fill,
    ParagraphBuilder stroke,
    Offset parentOffset,
    DrawableTextAnchorPosition textAnchor,
    DrawableDefinitionServer definitions,
    Rect bounds,
    XmlNode parent,
    DrawableStyle style) {
  final List<Drawable> children = <Drawable>[];
  Offset currentOffset = Offset(parentOffset.dx, parentOffset.dy);
  for (XmlNode child in parent.children) {
    switch (child.nodeType) {
      case XmlNodeType.CDATA:
          _appendParagraphs(fill, stroke, child.text, style);
        break;
      case XmlNodeType.TEXT:
        if (child.text.trim().isNotEmpty) {
          _appendParagraphs(fill, stroke, child.text.trim(), style);
        }
        break;
      case XmlNodeType.ELEMENT:
        final DrawableStyle childStyle =
            parseStyle(child, definitions, bounds, style);
        final ParagraphBuilder fill = ParagraphBuilder(ParagraphStyle());
        final ParagraphBuilder stroke = ParagraphBuilder(ParagraphStyle());
        final String x = getAttribute(child, 'x', def: null);
        final String y = getAttribute(child, 'y', def: null);
        final Offset staticOffset = Offset(x!=null ? double.parse(x) : null,
            y!=null ? double.parse(y) : null);
        final Offset relativeOffset = Offset(double.parse(getAttribute(child, 'dx', def: '0')),
            double.parse(getAttribute(child, 'dy', def: '0')));
        final Offset offset = Offset(staticOffset.dx ?? (currentOffset.dx + relativeOffset.dx),
            staticOffset.dy ?? (currentOffset.dy + relativeOffset.dy));
        final Drawable drawable = _paragraphParser(fill, stroke, offset, textAnchor, definitions,
            bounds, child, childStyle);
        fill.pop();
        stroke.pop();
        children.add(drawable);
        if (drawable is DrawableText){
          drawable.fill.layout(ParagraphConstraints(width: double.infinity));
          currentOffset = Offset(currentOffset.dx + drawable.fill.maxIntrinsicWidth, currentOffset.dy);
        }
        break;
      default:
        break;
    }
  }
  children.add(DrawableText(
    _finishParagraph(fill),
    _finishParagraph(stroke),
    parentOffset,
    textAnchor,
  ));
  if (children.length==1){
    return children.elementAt(0);
  }
  return DrawableGroup(children, style);
}

Drawable parseSvgText(XmlElement el, DrawableDefinitionServer definitions,
    Rect bounds, DrawableStyle parentStyle) {
  final Offset offset = Offset(double.parse(getAttribute(el, 'x', def: '0')),
      double.parse(getAttribute(el, 'y', def: '0')));

  final DrawableStyle style = parseStyle(el, definitions, bounds, parentStyle);

  final ParagraphBuilder fill = ParagraphBuilder(ParagraphStyle());
  final ParagraphBuilder stroke = ParagraphBuilder(ParagraphStyle());

  final DrawableTextAnchorPosition textAnchor =
      parseTextAnchor(getAttribute(el, 'text-anchor', def: 'start'));

  return _paragraphParser(fill, stroke, offset, textAnchor, definitions, bounds, el, style);


}

/// Parses an SVG <g> element.
Future<Drawable> parseSvgGroup(
    XmlElement el,
    DrawableDefinitionServer definitions,
    Rect bounds,
    DrawableStyle parentStyle,
    String key) async {
  final List<Drawable> children = <Drawable>[];
  final DrawableStyle style =
      parseStyle(el, definitions, bounds, parentStyle, needsTransform: true);
  for (XmlNode child in el.children.whereType<XmlElement>()) {
    children.add(await parseSvgElement(
      child,
      definitions,
      bounds,
      style,
      key,
    ));
  }

  return DrawableGroup(children, style);
}

/// Parses style attributes or @style attribute.
///
/// Remember that @style attribute takes precedence.
DrawableStyle parseStyle(
  XmlElement el,
  DrawableDefinitionServer definitions,
  Rect bounds,
  DrawableStyle parentStyle, {
  bool needsTransform = false,
}) {
  final Matrix4 transform =
      needsTransform ? parseTransform(getAttribute(el, 'transform')) : null;

  return DrawableStyle.mergeAndBlend(
    parentStyle,
    transform: transform?.storage,
    stroke: parseStroke(el, bounds, definitions, parentStyle?.stroke),
    dashArray: parseDashArray(el),
    dashOffset: parseDashOffset(el),
    fill: parseFill(el, bounds, definitions, parentStyle?.fill),
    pathFillType: parseFillRule(
      el,
      'fill-rule',
      parentStyle != null ? null : 'nonzero',
    ),
    groupOpacity: parseOpacity(el),
    clipPath: parseClipPath(el, definitions),
    textStyle: DrawableTextStyle(
      fontFamily: getAttribute(el, 'font-family', def: null),
      fontWeight: getFontWeightByName(getAttribute(el, 'font-weight', def: null)),
      fontSize: parseFontSize(getAttribute(el, 'font-size'),
          parentValue: parentStyle?.textStyle?.fontSize),
    ),
  );
}

FontWeight getFontWeightByName(String fontWeight){
  if (fontWeight==null) {
    return null;
  }
  switch(fontWeight){
    case '100':
      return FontWeight.w100;
    case '200':
      return FontWeight.w200;
    case '300':
      return FontWeight.w300;
    case 'normal':
    case '400':
      return FontWeight.w400;
    case '500':
      return FontWeight.w500;
    case '600':
      return FontWeight.w600;
    case 'bold':
    case '700':
      return FontWeight.bold;
    case '800':
      return FontWeight.w700;
    case '900':
      return FontWeight.w800;
  }
  throw UnsupportedError('font-weight $fontWeight is not supported');
}

Future<Image> _resolveImage(String href) async {
  if (href == null || href == '') {
    return null;
  }

  final Function decodeImage = (Uint8List bytes) async {
    final Codec codec = await instantiateImageCodec(bytes);
    final FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  };

  if (href.startsWith('http')) {
    final Uint8List bytes = await httpGet(href);
    return decodeImage(bytes);
  }

  if (href.startsWith('data:')) {
    final int commaLocation = href.indexOf(',') + 1;
    final Uint8List bytes = base64.decode(href.substring(commaLocation));
    return decodeImage(bytes);
  }

  throw UnsupportedError('Could not resolve image href: $href');
}
