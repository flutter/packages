import 'dart:collection';

import 'package:vector_graphics_compiler/src/vector_instructions.dart';
import 'package:xml/xml_events.dart';

import '../geometry/basic_types.dart';
import '../geometry/matrix.dart';
import '../geometry/path.dart';
import 'node.dart';
import '../paint.dart';

import 'colors.dart';
import 'numbers.dart';
import 'parsers.dart';
import 'theme.dart';
import 'xml.dart';

final Set<String> _unhandledElements = <String>{'title', 'desc'};

typedef _ParseFunc = Future<void>? Function(
    SvgParser parserState, bool warningsAsErrors);
typedef _PathFunc = Path? Function(SvgParser parserState);

const Map<String, _ParseFunc> _svgElementParsers = <String, _ParseFunc>{
  'svg': _Elements.svg,
  'g': _Elements.g,
  'a': _Elements.g, // treat as group
  'use': _Elements.use,
  'symbol': _Elements.symbol,
  'mask': _Elements.symbol, // treat as symbol
  'radialGradient': _Elements.radialGradient,
  'linearGradient': _Elements.linearGradient,
  'clipPath': _Elements.clipPath,
  'image': _Elements.image,
  'text': _Elements.text,
};

const Map<String, _PathFunc> _svgPathFuncs = <String, _PathFunc>{
  'circle': _Paths.circle,
  'path': _Paths.path,
  'rect': _Paths.rect,
  'polygon': _Paths.polygon,
  'polyline': _Paths.polyline,
  'ellipse': _Paths.ellipse,
  'line': _Paths.line,
};

// ignore: avoid_classes_with_only_static_members
class _Elements {
  static Future<void>? svg(SvgParser parserState, bool warningsAsErrors) {
    final Viewport viewBox = parserState.parseViewBox();

    final String? id = parserState.attribute('id', def: '');

    final Color? color =
        parserState.parseColor(parserState.attribute('color')) ??
            // Fallback to the currentColor from theme if no color is defined
            // on the root SVG element.
            parserState.theme.currentColor;

    // TODO(dnfield): Support nested SVG elements. https://github.com/dnfield/flutter_svg/issues/132
    if (parserState._root != null) {
      const String errorMessage = 'Unsupported nested <svg> element.';
      if (warningsAsErrors) {
        throw UnsupportedError(errorMessage);
      }
      // FlutterError.reportError(FlutterErrorDetails(
      //   exception: UnsupportedError(errorMessage),
      //   informationCollector: () => <DiagnosticsNode>[
      //     ErrorDescription(
      //         'The root <svg> element contained an unsupported nested SVG element.'),
      //     if (parserState._key != null) ErrorDescription(''),
      //     if (parserState._key != null)
      //       DiagnosticsProperty<String>('Picture key', parserState._key),
      //   ],
      //   library: 'SVG',
      //   context: ErrorDescription('in _Element.svg'),
      // ));

      parserState._parentDrawables.addLast(
        _SvgGroupTuple(
          'svg',
          ViewportNode(
            id: id,
            width: viewBox.width,
            height: viewBox.height,
            children: <Node>[],
            paint: parserState.parseStyle(
              Rect.fromLTWH(0, 0, viewBox.width, viewBox.height),
              null,
              currentColor: color,
            ),
          ),
        ),
      );
      return null;
    }
    parserState._root = ViewportNode(
      id: id,
      width: viewBox.width,
      height: viewBox.height,
      children: <Node>[],
      // parserState._definitions,
      paint: parserState.parseStyle(
        Rect.fromLTWH(0, 0, viewBox.width, viewBox.height),
        null,
        currentColor: color,
      ),
    );
    parserState.addGroup(parserState._currentStartElement!, parserState._root!);
    return null;
  }

  static Future<void>? g(SvgParser parserState, bool warningsAsErrors) {
    if (parserState._currentStartElement?.isSelfClosing == true) {
      return null;
    }
    final ParentNode parent = parserState.currentGroup!;
    final Color? color =
        parserState.parseColor(parserState.attribute('color')) ?? parent.color;

    final ParentNode group = ParentNode(
      id: parserState.attribute('id', def: ''),
      children: <Node>[],
      paint: parserState.parseStyle(parserState.rootBounds, parent.paint,
          currentColor: color),
      transform:
          parseTransform(parserState.attribute('transform'), parent.transform),
      color: color,
    );
    parent.children.add(group);
    parserState.addGroup(parserState._currentStartElement!, group);
    return null;
  }

  static Future<void>? symbol(SvgParser parserState, bool warningsAsErrors) {
    final ParentNode parent = parserState.currentGroup!;
    final Color? color =
        parserState.parseColor(parserState.attribute('color')) ?? parent.color;

    final ParentNode group = ParentNode(
      id: parserState.attribute('id', def: ''),
      children: <Node>[],
      paint: parserState.parseStyle(
        parserState.rootBounds,
        parent.paint,
        currentColor: color,
      ),
      transform:
          parseTransform(parserState.attribute('transform'), parent.transform),
      color: color,
    );
    parserState.addGroup(parserState._currentStartElement!, group);
    return null;
  }

  static Future<void>? use(SvgParser parserState, bool warningsAsErrors) {
    final ParentNode? parent = parserState.currentGroup;
    final String xlinkHref = getHrefAttribute(parserState.attributes)!;
    if (xlinkHref.isEmpty) {
      return null;
    }

    final Paint paint = parserState.parseStyle(
      parserState.rootBounds,
      parent!.paint,
      currentColor: parent.color,
    );

    final AffineMatrix transform =
        (parseTransform(parserState.attribute('transform'), parent.transform) ??
                AffineMatrix.identity)
            .translated(
      parserState.parseDoubleWithUnits(
        parserState.attribute('x', def: '0'),
      )!,
      parserState.parseDoubleWithUnits(
        parserState.attribute('y', def: '0'),
      )!,
    );

    final Node ref = parserState._definitions.getDrawable('url($xlinkHref)')!;
    final ParentNode group = ParentNode(
      id: parserState.attribute('id', def: ''),
      children: <Node>[ref.adoptPaint(paint)],
      paint: paint,
      transform: transform,
    );

    parserState.checkForIri(group);
    parent.children.add(group);
    group.addPaths(parserState.instructions, transform);
    return null;
  }

  static Future<void>? parseStops(
    SvgParser parserState,
    List<Color> colors,
    List<double> offsets,
  ) {
    final ParentNode parent = parserState.currentGroup!;

    for (XmlEvent event in parserState._readSubtree()) {
      if (event is XmlEndElementEvent) {
        continue;
      }
      if (event is XmlStartElementEvent) {
        final String rawOpacity = getAttribute(
          parserState.attributes,
          'stop-opacity',
          def: '1',
        )!;
        final Color stopColor = parserState.parseColor(
                getAttribute(parserState.attributes, 'stop-color')) ??
            parent.color ??
            Color.opaqueBlack;
        colors.add(stopColor.withOpacity(parseDouble(rawOpacity)!));

        final String rawOffset = getAttribute(
          parserState.attributes,
          'offset',
          def: '0%',
        )!;
        offsets.add(parseDecimalOrPercentage(rawOffset));
      }
    }
    return null;
  }

  static Future<void>? radialGradient(
    SvgParser parserState,
    bool warningsAsErrors,
  ) {
    final String? gradientUnits = getAttribute(
      parserState.attributes,
      'gradientUnits',
      def: null,
    );
    bool isObjectBoundingBox = gradientUnits != 'userSpaceOnUse';

    final String? rawCx = parserState.attribute('cx', def: '50%');
    final String? rawCy = parserState.attribute('cy', def: '50%');
    final String? rawR = parserState.attribute('r', def: '50%');
    final String? rawFx = parserState.attribute('fx', def: rawCx);
    final String? rawFy = parserState.attribute('fy', def: rawCy);
    final TileMode spreadMethod = parserState.parseTileMode();
    final String id = parserState.buildUrlIri();
    final AffineMatrix? originalTransform = parseTransform(
      parserState.attribute('gradientTransform'),
      parserState.currentGroup?.transform,
    );

    final List<double> offsets = <double>[];
    final List<Color> colors = <Color>[];

    if (parserState._currentStartElement!.isSelfClosing) {
      final String? href = getHrefAttribute(parserState.attributes);
      final RadialGradient? ref =
          parserState._definitions.getGradient<RadialGradient>('url($href)');
      if (ref == null) {
        reportMissingDef(parserState._key, href, 'radialGradient');
      } else {
        if (gradientUnits == null) {
          isObjectBoundingBox =
              ref.unitMode == GradientUnitMode.objectBoundingBox;
        }
        colors.addAll(ref.colors);
        offsets.addAll(ref.offsets!);
      }
    } else {
      parseStops(parserState, colors, offsets);
    }

    late double cx, cy, r, fx, fy;
    if (isObjectBoundingBox) {
      cx = parseDecimalOrPercentage(rawCx!);
      cy = parseDecimalOrPercentage(rawCy!);
      r = parseDecimalOrPercentage(rawR!);
      fx = parseDecimalOrPercentage(rawFx!);
      fy = parseDecimalOrPercentage(rawFy!);
    } else {
      cx = isPercentage(rawCx!)
          ? parsePercentage(rawCx) * parserState.rootBounds.width +
              parserState.rootBounds.left
          : parserState.parseDoubleWithUnits(rawCx)!;
      cy = isPercentage(rawCy!)
          ? parsePercentage(rawCy) * parserState.rootBounds.height +
              parserState.rootBounds.top
          : parserState.parseDoubleWithUnits(rawCy)!;
      r = isPercentage(rawR!)
          ? parsePercentage(rawR) *
              ((parserState.rootBounds.height + parserState.rootBounds.width) /
                  2)
          : parserState.parseDoubleWithUnits(rawR)!;
      fx = isPercentage(rawFx!)
          ? parsePercentage(rawFx) * parserState.rootBounds.width +
              parserState.rootBounds.left
          : parserState.parseDoubleWithUnits(rawFx)!;
      fy = isPercentage(rawFy!)
          ? parsePercentage(rawFy) * parserState.rootBounds.height +
              parserState.rootBounds.top
          : parserState.parseDoubleWithUnits(rawFy)!;
    }

    parserState._definitions.addGradient(
      id,
      RadialGradient(
        center: Point(cx, cy),
        radius: r,
        focalPoint: (fx != cx || fy != cy) ? Point(fx, fy) : Point(cx, cy),
        colors: colors,
        offsets: offsets,
        unitMode: isObjectBoundingBox
            ? GradientUnitMode.objectBoundingBox
            : GradientUnitMode.userSpaceOnUse,
        tileMode: spreadMethod,
        transform: originalTransform,
      ),
    );
    return null;
  }

  static Future<void>? linearGradient(
    SvgParser parserState,
    bool warningsAsErrors,
  ) {
    final String? gradientUnits = parserState.attribute('gradientUnits');
    bool isObjectBoundingBox = gradientUnits != 'userSpaceOnUse';

    final String x1 = parserState.attribute('x1', def: '0%')!;
    final String x2 = parserState.attribute('x2', def: '100%')!;
    final String y1 = parserState.attribute('y1', def: '0%')!;
    final String y2 = parserState.attribute('y2', def: '0%')!;
    final String id = parserState.buildUrlIri();
    final AffineMatrix? originalTransform = parseTransform(
      parserState.attribute('gradientTransform'),
      parserState.currentGroup?.transform,
    );
    final TileMode spreadMethod = parserState.parseTileMode();

    final List<Color> colors = <Color>[];
    final List<double> offsets = <double>[];
    if (parserState._currentStartElement!.isSelfClosing) {
      final String? href = getHrefAttribute(parserState.attributes);
      final LinearGradient? ref =
          parserState._definitions.getGradient<LinearGradient>('url($href)');
      if (ref == null) {
        reportMissingDef(parserState._key, href, 'linearGradient');
      } else {
        if (gradientUnits == null) {
          isObjectBoundingBox =
              ref.unitMode == GradientUnitMode.objectBoundingBox;
        }
        colors.addAll(ref.colors);
        offsets.addAll(ref.offsets!);
      }
    } else {
      parseStops(parserState, colors, offsets);
    }

    Point fromPoint, toPoint;
    if (isObjectBoundingBox) {
      fromPoint = Point(
        parseDecimalOrPercentage(x1),
        parseDecimalOrPercentage(y1),
      );
      toPoint = Point(
        parseDecimalOrPercentage(x2),
        parseDecimalOrPercentage(y2),
      );
    } else {
      fromPoint = Point(
        isPercentage(x1)
            ? parsePercentage(x1) * parserState.rootBounds.width +
                parserState.rootBounds.left
            : parserState.parseDoubleWithUnits(x1)!,
        isPercentage(y1)
            ? parsePercentage(y1) * parserState.rootBounds.height +
                parserState.rootBounds.top
            : parserState.parseDoubleWithUnits(y1)!,
      );

      toPoint = Point(
        isPercentage(x2)
            ? parsePercentage(x2) * parserState.rootBounds.width +
                parserState.rootBounds.left
            : parserState.parseDoubleWithUnits(x2)!,
        isPercentage(y2)
            ? parsePercentage(y2) * parserState.rootBounds.height +
                parserState.rootBounds.top
            : parserState.parseDoubleWithUnits(y2)!,
      );
    }

    parserState._definitions.addGradient(
      id,
      LinearGradient(
        from: fromPoint,
        to: toPoint,
        colors: colors,
        offsets: offsets,
        tileMode: spreadMethod,
        unitMode: isObjectBoundingBox
            ? GradientUnitMode.objectBoundingBox
            : GradientUnitMode.userSpaceOnUse,
        transform: originalTransform,
      ),
    );

    return null;
  }

  static Future<void>? clipPath(SvgParser parserState, bool warningsAsErrors) {
    final String id = parserState.buildUrlIri();

    final List<Path> paths = <Path>[];
    PathBuilder? currentPath;
    for (XmlEvent event in parserState._readSubtree()) {
      if (event is XmlEndElementEvent) {
        continue;
      }
      if (event is XmlStartElementEvent) {
        final _PathFunc? pathFn = _svgPathFuncs[event.name];

        if (pathFn != null) {
          final PathBuilder nextPath = PathBuilder.fromPath(
            parserState.applyTransformIfNeeded(
              pathFn(parserState)!,
              parserState.currentGroup?.transform,
            ),
          );
          nextPath.fillType = parserState.parseFillRule('clip-rule')!;
          if (currentPath != null &&
              nextPath.fillType != currentPath.fillType) {
            currentPath = nextPath;
            paths.add(currentPath.toPath());
          } else if (currentPath == null) {
            currentPath = nextPath;
            paths.add(currentPath.toPath());
          } else {
            currentPath.addPath(nextPath.toPath());
          }
        } else if (event.name == 'use') {
          final String? xlinkHref = getHrefAttribute(parserState.attributes);
          final Node? definitionDrawable =
              parserState._definitions.getDrawable('url($xlinkHref)');

          void extractPathsFromDrawable(Node? target) {
            if (target is PathNode) {
              paths.add(target.path);
            } else if (target is ParentNode) {
              target.children.forEach(extractPathsFromDrawable);
            }
          }

          extractPathsFromDrawable(definitionDrawable);
        } else {
          final String errorMessage =
              'Unsupported clipPath child ${event.name}';
          if (warningsAsErrors) {
            throw UnsupportedError(errorMessage);
          }
          // FlutterError.reportError(FlutterErrorDetails(
          //   exception: UnsupportedError(errorMessage),
          //   informationCollector: () => <DiagnosticsNode>[
          //     ErrorDescription(
          //         'The <clipPath> element contained an unsupported child ${event.name}'),
          //     if (parserState._key != null) ErrorDescription(''),
          //     if (parserState._key != null)
          //       DiagnosticsProperty<String>('Picture key', parserState._key),
          //   ],
          //   library: 'SVG',
          //   context: ErrorDescription('in _Element.clipPath'),
          // ));
        }
      }
    }
    parserState._definitions.addClipPath(id, paths);
    return null;
  }

  static Future<void> image(
      SvgParser parserState, bool warningsAsErrors) async {
    throw UnsupportedError('TODO');
    // final String? href = getHrefAttribute(parserState.attributes);
    // if (href == null) {
    //   return;
    // }
    // final Point offset = Point(
    //   parserState.parseDoubleWithUnits(
    //     parserState.attribute('x', def: '0'),
    //   )!,
    //   parserState.parseDoubleWithUnits(
    //     parserState.attribute('y', def: '0'),
    //   )!,
    // );
    // final Size size = Size(
    //   parserState.parseDoubleWithUnits(
    //     parserState.attribute('width', def: '0'),
    //   )!,
    //   parserState.parseDoubleWithUnits(
    //     parserState.attribute('height', def: '0'),
    //   )!,
    // );
    // // final Image image = await resolveImage(href);
    // final ParentNode parent = parserState._parentDrawables.last.drawable!;
    // final DrawableStyle? parentStyle = parent.paint;
    // final DrawableRasterImage drawable = DrawableRasterImage(
    //   parserState.attribute('id', def: ''),
    //   image,
    //   offset,
    //   parserState.parseStyle(parserState.rootBounds, parentStyle,
    //       currentColor: parent.color),
    //   size: size,
    //   transform: parseTransform(parserState.attribute('transform'))?.storage,
    // );
    // parserState.checkForIri(drawable);

    // parserState.currentGroup!.children!.add(drawable);
  }

  static Future<void> text(
    SvgParser parserState,
    bool warningsAsErrors,
  ) async {
    throw UnsupportedError('TODO');
    // assert(parserState != null); // ignore: unnecessary_null_comparison
    // assert(parserState.currentGroup != null);
    // if (parserState._currentStartElement!.isSelfClosing) {
    //   return;
    // }

    // // <text>, <tspan> -> Collect styles
    // // <tref> TBD - looks like Inkscape supports it, but no browser does.
    // // XmlNodeType.TEXT/CDATA -> DrawableText
    // // Track the style(s) and offset(s) for <text> and <tspan> elements
    // final Queue<_TextInfo> textInfos = ListQueue<_TextInfo>();
    // double lastTextWidth = 0;

    // void _processText(String value) {
    //   if (value.isEmpty) {
    //     return;
    //   }
    //   assert(textInfos.isNotEmpty);
    //   final _TextInfo lastTextInfo = textInfos.last;
    //   // final Paragraph fill = createParagraph(
    //   //   value,
    //   //   lastTextInfo.style,
    //   //   lastTextInfo.style.fill,
    //   // );
    //   // final Paragraph stroke = createParagraph(
    //   //   value,
    //   //   lastTextInfo.style,
    //   //   DrawablePaint.isEmpty(lastTextInfo.style.stroke)
    //   //       ? transparentStroke
    //   //       : lastTextInfo.style.stroke,
    //   // );
    //   // parserState.currentGroup!.children!.add(
    //   //   DrawableText(
    //   //     parserState.attribute('id', def: ''),
    //   //     fill,
    //   //     stroke,
    //   //     lastTextInfo.offset,
    //   //     lastTextInfo.style.textStyle!.anchor ??
    //   //         DrawableTextAnchorPosition.start,
    //   //     transform: lastTextInfo.transform?.storage,
    //   //   ),
    //   // );
    //   // lastTextWidth = fill.maxIntrinsicWidth;
    // }

    // void _processStartElement(XmlStartElementEvent event) {
    //   _TextInfo? lastTextInfo;
    //   if (textInfos.isNotEmpty) {
    //     lastTextInfo = textInfos.last;
    //   }
    //   final Point currentPoint = _parseCurrentPoint(
    //     parserState,
    //     lastTextInfo?.offset.translate(lastTextWidth, 0),
    //   );
    //   AffineMatrix? transform =
    //       parseTransform(parserState.attribute('transform'));
    //   if (lastTextInfo?.transform != null) {
    //     if (transform == null) {
    //       transform = lastTextInfo!.transform;
    //     } else {
    //       transform = lastTextInfo!.transform!.multiplied(transform);
    //     }
    //   }

    //   final DrawableStyle? parentStyle =
    //       lastTextInfo?.style ?? parserState.currentGroup!.style;

    //   textInfos.add(_TextInfo(
    //     parserState.parseStyle(
    //       parserState.rootBounds,
    //       parentStyle,
    //     ),
    //     currentPoint,
    //     transform,
    //   ));
    //   if (event.isSelfClosing) {
    //     textInfos.removeLast();
    //   }
    // }

    // _processStartElement(parserState._currentStartElement!);

    // for (XmlEvent event in parserState._readSubtree()) {
    //   if (event is XmlCDATAEvent) {
    //     _processText(event.text.trim());
    //   } else if (event is XmlTextEvent) {
    //     final String? space =
    //         getAttribute(parserState.attributes, 'space');
    //     if (space != 'preserve') {
    //       _processText(event.text.trim());
    //     } else {
    //       _processText(event.text.replaceAll(_trimPattern, ''));
    //     }
    //   }
    //   if (event is XmlStartElementEvent) {
    //     _processStartElement(event);
    //   } else if (event is XmlEndElementEvent) {
    //     textInfos.removeLast();
    //   }
    // }
  }
}

// ignore: avoid_classes_with_only_static_members
class _Paths {
  static Path circle(SvgParser parserState) {
    final double cx = parserState.parseDoubleWithUnits(
      parserState.attribute('cx', def: '0'),
    )!;
    final double cy = parserState.parseDoubleWithUnits(
      parserState.attribute('cy', def: '0'),
    )!;
    final double r = parserState.parseDoubleWithUnits(
      parserState.attribute('r', def: '0'),
    )!;
    final Rect oval = Rect.fromCircle(cx, cy, r);
    return (PathBuilder()..addOval(oval)).toPath();
  }

  static Path path(SvgParser parserState) {
    final String d = parserState.attribute('d', def: '')!;
    return parseSvgPathData(d);
  }

  static Path rect(SvgParser parserState) {
    final double x = parserState.parseDoubleWithUnits(
      parserState.attribute('x', def: '0'),
    )!;
    final double y = parserState.parseDoubleWithUnits(
      parserState.attribute('y', def: '0'),
    )!;
    final double w = parserState.parseDoubleWithUnits(
      parserState.attribute('width', def: '0'),
    )!;
    final double h = parserState.parseDoubleWithUnits(
      parserState.attribute('height', def: '0'),
    )!;
    String? rxRaw = parserState.attribute('rx');
    String? ryRaw = parserState.attribute('ry');
    rxRaw ??= ryRaw;
    ryRaw ??= rxRaw;

    if (rxRaw != null && rxRaw != '') {
      final double rx = parserState.parseDoubleWithUnits(rxRaw)!;
      final double ry = parserState.parseDoubleWithUnits(ryRaw)!;

      return (PathBuilder()
            ..addRRect(Rect.fromLTRB(x, y, w - x, h - y), rx, ry))
          .toPath();
    }

    return (PathBuilder()..addRect(Rect.fromLTWH(x, y, w, h))).toPath();
  }

  static Path? polygon(SvgParser parserState) {
    return parsePathFromPoints(parserState, true);
  }

  static Path? polyline(SvgParser parserState) {
    return parsePathFromPoints(parserState, false);
  }

  static Path? parsePathFromPoints(SvgParser parserState, bool close) {
    final String points = parserState.attribute('points', def: '')!;
    if (points == '') {
      return null;
    }
    final String path = 'M$points${close ? 'z' : ''}';

    return parseSvgPathData(path);
  }

  static Path ellipse(SvgParser parserState) {
    final double cx = parserState.parseDoubleWithUnits(
      parserState.attribute('cx', def: '0'),
    )!;
    final double cy = parserState.parseDoubleWithUnits(
      parserState.attribute('cy', def: '0'),
    )!;
    final double rx = parserState.parseDoubleWithUnits(
      parserState.attribute('rx', def: '0'),
    )!;
    final double ry = parserState.parseDoubleWithUnits(
      parserState.attribute('ry', def: '0'),
    )!;

    final Rect r = Rect.fromLTWH(cx - rx, cy - ry, rx * 2, ry * 2);
    return (PathBuilder()..addOval(r)).toPath();
  }

  static Path line(SvgParser parserState) {
    final double x1 = parserState.parseDoubleWithUnits(
      parserState.attribute('x1', def: '0'),
    )!;
    final double x2 = parserState.parseDoubleWithUnits(
      parserState.attribute('x2', def: '0'),
    )!;
    final double y1 = parserState.parseDoubleWithUnits(
      parserState.attribute('y1', def: '0'),
    )!;
    final double y2 = parserState.parseDoubleWithUnits(
      parserState.attribute('y2', def: '0'),
    )!;

    return (PathBuilder()
          ..moveTo(x1, y1)
          ..lineTo(x2, y2))
        .toPath();
  }
}

class _SvgGroupTuple {
  _SvgGroupTuple(this.name, this.drawable);

  final String name;
  final ParentNode? drawable;
}

/// Reads an SVG XML string and via the [parse] method creates a set of
/// [VectorInstructions].
class SvgParser {
  /// Creates a new [SvgParser].
  SvgParser(
    String xml,
    this.theme,
    this._key,
    this._warningsAsErrors,
  ) : _eventIterator = parseEvents(xml).iterator;

  final VectorInstructions instructions = VectorInstructions();

  /// The theme used when parsing SVG elements.
  final SvgTheme theme;

  final Iterator<XmlEvent> _eventIterator;
  final String? _key;
  final bool _warningsAsErrors;
  final DrawableDefinitionServer _definitions = DrawableDefinitionServer();
  final Queue<_SvgGroupTuple> _parentDrawables = ListQueue<_SvgGroupTuple>(10);
  ViewportNode? _root;
  late Map<String, String> _currentAttributes;
  XmlStartElementEvent? _currentStartElement;

  /// The current depth of the reader in the XML hierarchy.
  int depth = 0;

  void _discardSubtree() {
    final int subtreeStartDepth = depth;
    while (_eventIterator.moveNext()) {
      final XmlEvent event = _eventIterator.current;
      if (event is XmlStartElementEvent && !event.isSelfClosing) {
        depth += 1;
      } else if (event is XmlEndElementEvent) {
        depth -= 1;
        assert(depth >= 0);
      }
      _currentAttributes = <String, String>{};
      _currentStartElement = null;
      if (depth < subtreeStartDepth) {
        return;
      }
    }
  }

  Iterable<XmlEvent> _readSubtree() sync* {
    final int subtreeStartDepth = depth;
    while (_eventIterator.moveNext()) {
      final XmlEvent event = _eventIterator.current;
      bool isSelfClosing = false;
      if (event is XmlStartElementEvent) {
        final Map<String, String> attributeMap =
            event.attributes.toAttributeMap();
        if (getAttribute(attributeMap, 'display') == 'none' ||
            getAttribute(attributeMap, 'visibility') == 'hidden') {
          print('SVG Warning: Discarding:\n\n  $event\n\n'
              'and any children it has since it is not visible.\n'
              'If that element is meant to be visible, the `display` or '
              '`visibility` attributes should be removed.\n'
              'If that element is not meant to be visible, it would be better '
              'to remove it from the SVG file.');
          if (!event.isSelfClosing) {
            depth += 1;
            _discardSubtree();
          }
          continue;
        }
        _currentAttributes = attributeMap;
        _currentStartElement = event;
        depth += 1;
        isSelfClosing = event.isSelfClosing;
      }
      yield event;

      if (isSelfClosing || event is XmlEndElementEvent) {
        depth -= 1;
        assert(depth >= 0);
        _currentAttributes = <String, String>{};
        _currentStartElement = null;
      }
      if (depth < subtreeStartDepth) {
        return;
      }
    }
  }

  /// Drive the XML reader to EOF and produce [VectorInstructions].
  Future<VectorInstructions> parse() async {
    for (XmlEvent event in _readSubtree()) {
      if (event is XmlStartElementEvent) {
        if (startElement(event)) {
          continue;
        }
        final _ParseFunc? parseFunc = _svgElementParsers[event.name];
        await parseFunc?.call(this, _warningsAsErrors);
        if (parseFunc == null) {
          if (!event.isSelfClosing) {
            _discardSubtree();
          }
          assert(() {
            unhandledElement(event);
            return true;
          }());
        }
      } else if (event is XmlEndElementEvent) {
        endElement(event);
      }
    }
    if (_root == null) {
      throw StateError('Invalid SVG data');
    }
    instructions.width = _root!.width;
    instructions.height = _root!.height;
    return instructions;
  }

  /// The XML Attributes of the current node in the tree.
  Map<String, String> get attributes => _currentAttributes;

  /// Gets the attribute for the current position of the parser.
  String? attribute(String name, {String? def}) =>
      getAttribute(attributes, name, def: def);

  /// The current group, if any, in the [Drawable] heirarchy.
  ParentNode? get currentGroup {
    assert(_parentDrawables != null); // ignore: unnecessary_null_comparison
    assert(_parentDrawables.isNotEmpty);
    return _parentDrawables.last.drawable;
  }

  /// The root bounds of the drawable.
  Rect get rootBounds {
    assert(_root != null, 'Cannot get rootBounds with null root');
    return _root!.viewport;
  }

  /// Whether this [DrawableStyleable] belongs in the [DrawableDefinitions] or not.
  bool checkForIri(Node? drawable) {
    final String iri = buildUrlIri();
    if (iri != emptyUrlIri) {
      _definitions.addDrawable(iri, drawable!);
      return true;
    }
    return false;
  }

  /// Appends a group to the collection.
  void addGroup(XmlStartElementEvent event, ParentNode drawable) {
    _parentDrawables.addLast(_SvgGroupTuple(event.name, drawable));
    checkForIri(drawable);
  }

  /// Updates the [VectorInstructions] with the current path and paint.
  bool addShape(XmlStartElementEvent event) {
    final _PathFunc? pathFunc = _svgPathFuncs[event.name];
    if (pathFunc == null) {
      return false;
    }

    final ParentNode parent = _parentDrawables.last.drawable!;
    final Paint? parentStyle = parent.paint;
    Path path = pathFunc(this)!;

    final AffineMatrix? transform = parseTransform(
      getAttribute(attributes, 'transform'),
      parent.transform,
    );
    if (transform != null) {
      path = path.transformed(transform);
    }
    final Paint paint = parseStyle(
      // path.getBounds(),
      Rect.zero,
      parentStyle,
      defaultFillColor: Color.opaqueBlack,
      currentColor: parent.color,
      leaf: true,
    );
    final PathNode drawable = PathNode(
      path,
      id: getAttribute(attributes, 'id'),
      paint: paint,
      parent: currentGroup,
    );
    checkForIri(drawable);
    instructions.addDrawPath(path, paint, drawable.id);
    return true;
  }

  /// Potentially handles a starting element.
  bool startElement(XmlStartElementEvent event) {
    if (event.name == 'defs') {
      if (!event.isSelfClosing) {
        addGroup(
          event,
          ParentNode(
            id: '__defs__${event.hashCode}',
            children: <Node>[],
            color: currentGroup?.color,
            transform: currentGroup?.transform,
          ),
        );
        return true;
      }
    }
    return addShape(event);
  }

  /// Handles the end of an XML element.
  void endElement(XmlEndElementEvent event) {
    if (event.name == _parentDrawables.last.name) {
      _parentDrawables.removeLast();
    }
  }

  /// Prints an error for unhandled elements.
  ///
  /// Will only print an error once for unhandled/unexpected elements, except for
  /// `<style/>`, `<title/>`, and `<desc/>` elements.
  void unhandledElement(XmlStartElementEvent event) {
    final String errorMessage =
        'unhandled element ${event.name}; Picture key: $_key';
    if (_warningsAsErrors) {
      // Throw error instead of log warning.
      throw UnimplementedError(errorMessage);
    }
    if (event.name == 'style') {
      // FlutterError.reportError(FlutterErrorDetails(
      //   exception: UnimplementedError(
      //       'The <style> element is not implemented in this library.'),
      //   informationCollector: () => <DiagnosticsNode>[
      //     ErrorDescription(
      //         'Style elements are not supported by this library and the requested SVG may not '
      //         'render as intended.'),
      //     ErrorHint(
      //         'If possible, ensure the SVG uses inline styles and/or attributes (which are '
      //         'supported), or use a preprocessing utility such as svgcleaner to inline the '
      //         'styles for you.'),
      //     ErrorDescription(''),
      //     DiagnosticsProperty<String>('Picture key', _key),
      //   ],
      //   library: 'SVG',
      //   context: ErrorDescription('in parseSvgElement'),
      // ));
    } else if (_unhandledElements.add(event.name)) {
      print(errorMessage);
    }
  }

  /// Parses a `rawDouble` `String` to a `double`
  /// taking into account absolute and relative units
  /// (`px`, `em` or `ex`).
  ///
  /// Passing an `em` value will calculate the result
  /// relative to the provided [fontSize]:
  /// 1 em = 1 * `fontSize`.
  ///
  /// Passing an `ex` value will calculate the result
  /// relative to the provided [xHeight]:
  /// 1 ex = 1 * `xHeight`.
  ///
  /// The `rawDouble` might include a unit which is
  /// stripped off when parsed to a `double`.
  ///
  /// Passing `null` will return `null`.
  double? parseDoubleWithUnits(
    String? rawDouble, {
    bool tryParse = false,
  }) {
    double unit = 1.0;

    // 1 rem unit is equal to the root font size.
    // 1 em unit is equal to the current font size.
    // 1 ex unit is equal to the current x-height.
    if (rawDouble?.contains('rem') ?? false) {
      unit = theme.fontSize;
    } else if (rawDouble?.contains('em') ?? false) {
      unit = theme.fontSize;
    } else if (rawDouble?.contains('ex') ?? false) {
      unit = theme.xHeight;
    }

    final double? value = parseDouble(
      rawDouble,
      tryParse: tryParse,
    );

    return value != null ? value * unit : null;
  }

  static final Map<String, double> _kTextSizeMap = <String, double>{
    'xx-small': 10,
    'x-small': 12,
    'small': 14,
    'medium': 18,
    'large': 22,
    'x-large': 26,
    'xx-large': 32,
  };

  /// Parses a `font-size` attribute.
  double? parseFontSize(
    String? raw, {
    double? parentValue,
  }) {
    if (raw == null || raw == '') {
      return null;
    }

    double? ret = parseDoubleWithUnits(
      raw,
      tryParse: true,
    );
    if (ret != null) {
      return ret;
    }

    raw = raw.toLowerCase().trim();
    ret = _kTextSizeMap[raw];
    if (ret != null) {
      return ret;
    }

    if (raw == 'larger') {
      if (parentValue == null) {
        return _kTextSizeMap['large'];
      }
      return parentValue * 1.2;
    }

    if (raw == 'smaller') {
      if (parentValue == null) {
        return _kTextSizeMap['small'];
      }
      return parentValue / 1.2;
    }

    throw StateError('Could not parse font-size: $raw');
  }

  double _parseRawWidthHeight(String raw) {
    if (raw == '100%' || raw == '') {
      return double.infinity;
    }
    assert(() {
      final RegExp notDigits = RegExp(r'[^\d\.]');
      if (!raw.endsWith('px') &&
          !raw.endsWith('em') &&
          !raw.endsWith('ex') &&
          raw.contains(notDigits)) {
        print(
            'Warning: Flutter SVG only supports the following formats for `width` and `height` on the SVG root:\n'
            '  width="100%"\n'
            '  width="100em"\n'
            '  width="100ex"\n'
            '  width="100px"\n'
            '  width="100" (where the number will be treated as pixels).\n'
            'The supplied value ($raw) will be discarded and treated as if it had not been specified.');
      }
      return true;
    }());
    return parseDoubleWithUnits(raw, tryParse: true) ?? double.infinity;
  }

  /// Parses an SVG @viewBox attribute (e.g. 0 0 100 100) to a [Viewport].
  Viewport parseViewBox() {
    final String viewBox = getAttribute(attributes, 'viewBox')!;
    final String rawWidth = getAttribute(attributes, 'width')!;
    final String rawHeight = getAttribute(attributes, 'height')!;

    if (viewBox == '' && rawWidth == '' && rawHeight == '') {
      throw StateError('SVG did not specify dimensions\n\n'
          'The SVG library looks for a `viewBox` or `width` and `height` attribute '
          'to determine the viewport boundary of the SVG.  Note that these attributes, '
          'as with all SVG attributes, are case sensitive.\n'
          'During processing, the following attributes were found:\n'
          '  $attributes');
    }

    if (viewBox == '') {
      final double width = _parseRawWidthHeight(rawWidth);
      final double height = _parseRawWidthHeight(rawHeight);
      return Viewport(
        width,
        height,
        null,
      );
    }

    final List<String> parts = viewBox.split(RegExp(r'[ ,]+'));
    if (parts.length < 4) {
      throw StateError('viewBox element must be 4 elements long');
    }
    final double width = parseDouble(parts[2])!;
    final double height = parseDouble(parts[3])!;
    final double translateX = -parseDouble(parts[0])!;
    final double translateY = -parseDouble(parts[1])!;

    return Viewport(
      width,
      height,
      AffineMatrix.identity.translated(translateX, translateY),
    );
  }

  /// Builds an IRI in the form of `'url(#id)'`.
  String buildUrlIri() => 'url(#${getAttribute(attributes, 'id')})';

  /// An empty IRI.
  static const String emptyUrlIri = DrawableDefinitionServer.emptyUrlIri;

  /// Parses a `spreadMethod` attribute into a [TileMode].
  TileMode parseTileMode() {
    final String? spreadMethod = attribute('spreadMethod', def: 'pad');
    switch (spreadMethod) {
      case 'pad':
        return TileMode.clamp;
      case 'repeat':
        return TileMode.repeated;
      case 'reflect':
        return TileMode.mirror;
      default:
        return TileMode.clamp;
    }
  }

  /// Parses an @opacity value into a [double], clamped between 0..1.
  double? parseOpacity() {
    final String? rawOpacity = getAttribute(attributes, 'opacity', def: null);
    if (rawOpacity != null) {
      return parseDouble(rawOpacity)!.clamp(0.0, 1.0).toDouble();
    }
    return null;
  }

  Paint _getDefinitionPaint(
    String? key,
    PaintingStyle paintingStyle,
    String iri,
    DrawableDefinitionServer definitions,
    Rect bounds, {
    double? opacity,
  }) {
    final Shader? shader = definitions.getShader(iri);
    if (shader == null) {
      // reportMissingDef(key, iri, '_getDefinitionPaint');
    }

    switch (paintingStyle) {
      case PaintingStyle.fill:
        return Paint(
          fill: Fill(
              shader: shader,
              color: opacity != null
                  ? Color.fromRGBO(255, 255, 255, opacity)
                  : null),
        );
      case PaintingStyle.stroke:
        return Paint(
          stroke: Stroke(
              shader: shader,
              color: opacity != null
                  ? Color.fromRGBO(255, 255, 255, opacity)
                  : null),
        );
    }
  }

  StrokeCap? _parseCap(
    String? raw,
    Stroke? parentStroke,
    Stroke? definitionPaint,
  ) {
    switch (raw) {
      case 'butt':
        return StrokeCap.butt;
      case 'round':
        return StrokeCap.round;
      case 'square':
        return StrokeCap.square;
      default:
        return parentStroke?.cap ?? definitionPaint?.cap;
    }
  }

  StrokeJoin? _parseJoin(
    String? raw,
    Stroke? parentStroke,
    Stroke? definitionPaint,
  ) {
    switch (raw) {
      case 'miter':
        return StrokeJoin.miter;
      case 'bevel':
        return StrokeJoin.bevel;
      case 'round':
        return StrokeJoin.round;
      default:
        return parentStroke?.join ?? definitionPaint?.join;
    }
  }

  /// Parses a @stroke attribute into a [Paint].
  Stroke? parseStroke(
    Rect bounds,
    Stroke? parentStroke,
    Color? currentColor,
    bool leaf,
  ) {
    final String? rawStroke = getAttribute(attributes, 'stroke', def: null);
    final String? rawStrokeOpacity = getAttribute(
      attributes,
      'stroke-opacity',
      def: '1.0',
    );
    final String? rawOpacity = getAttribute(attributes, 'opacity');
    double opacity = parseDouble(rawStrokeOpacity)!.clamp(0.0, 1.0).toDouble();
    if (rawOpacity != '') {
      opacity *= parseDouble(rawOpacity)!.clamp(0.0, 1.0);
    }

    final String? rawStrokeCap =
        getAttribute(attributes, 'stroke-linecap', def: null);
    final String? rawLineJoin =
        getAttribute(attributes, 'stroke-linejoin', def: null);
    final String? rawMiterLimit =
        getAttribute(attributes, 'stroke-miterlimit', def: null);
    final String? rawStrokeWidth =
        getAttribute(attributes, 'stroke-width', def: null);

    final String? anyStrokeAttribute = rawStroke ??
        rawStrokeCap ??
        rawLineJoin ??
        rawMiterLimit ??
        rawStrokeWidth;
    if (anyStrokeAttribute == null &&
        (parentStroke == null || parentStroke.isEmpty)) {
      return null;
    } else if (rawStroke == 'none') {
      return leaf ? null : Stroke.empty;
    }

    Paint? definitionPaint;
    Color? strokeColor;
    if (rawStroke?.startsWith('url') == true) {
      definitionPaint = _getDefinitionPaint(
        _key,
        PaintingStyle.stroke,
        rawStroke!,
        _definitions,
        bounds,
        opacity: opacity,
      );
      strokeColor = definitionPaint.stroke!.color;
    } else {
      strokeColor = parseColor(rawStroke);
    }

    return Stroke(
      color: (strokeColor ??
              currentColor ??
              parentStroke?.color ??
              definitionPaint?.stroke?.color)
          ?.withOpacity(opacity),
      cap: _parseCap(rawStrokeCap, parentStroke, definitionPaint?.stroke),
      join: _parseJoin(rawLineJoin, parentStroke, definitionPaint?.stroke),
      miterLimit: parseDouble(rawMiterLimit) ??
          parentStroke?.miterLimit ??
          definitionPaint?.stroke?.miterLimit,
      width: parseDoubleWithUnits(rawStrokeWidth) ??
          parentStroke?.width ??
          definitionPaint?.stroke?.width,
    );
  }

  /// Parses a `fill` attribute.
  Fill? parseFill(
    Rect bounds,
    Fill? parentFill,
    Color? defaultFillColor,
    Color? currentColor,
    bool leaf,
  ) {
    final String rawFill = attribute('fill', def: '')!;
    final String? rawFillOpacity = attribute('fill-opacity', def: '1.0');
    final String? rawOpacity = attribute('opacity', def: '');
    double opacity = parseDouble(rawFillOpacity)!.clamp(0.0, 1.0).toDouble();
    if (rawOpacity != '') {
      opacity *= parseDouble(rawOpacity)!.clamp(0.0, 1.0);
    }

    if (rawFill.startsWith('url')) {
      final Fill? definitionFill = _getDefinitionPaint(
        _key,
        PaintingStyle.fill,
        rawFill,
        _definitions,
        bounds,
        opacity: opacity,
      ).fill;
      if (definitionFill == Fill.empty && leaf) {
        return null;
      }
      return definitionFill;
    }

    final Color? fillColor = _determineFillColor(
      parentFill?.color,
      rawFill,
      opacity,
      rawOpacity != '' || rawFillOpacity != '',
      defaultFillColor ?? Color.opaqueBlack,
      currentColor,
    );

    if (rawFill == '' && (fillColor == null || parentFill == Fill.empty)) {
      return null;
    }
    if (rawFill == 'none') {
      return leaf ? null : Fill.empty;
    }

    return Fill(
      color: fillColor,
    );
  }

  Color? _determineFillColor(
    Color? parentFillColor,
    String rawFill,
    double opacity,
    bool explicitOpacity,
    Color? defaultFillColor,
    Color? currentColor,
  ) {
    final Color? color = parseColor(rawFill) ??
        currentColor ??
        parentFillColor ??
        defaultFillColor;

    if (explicitOpacity && color != null) {
      return color.withOpacity(opacity);
    }

    return color;
  }

  /// Parses a `fill-rule` attribute into a [PathFillType].
  PathFillType? parseFillRule([
    String attr = 'fill-rule',
  ]) {
    final String? rawFillRule = getAttribute(attributes, attr, def: null);
    return parseRawFillRule(rawFillRule);
  }

  /// Applies a transform to a path if the [attributes] contain a `transform`.
  Path applyTransformIfNeeded(Path path, AffineMatrix? parentTransform) {
    final AffineMatrix? transform = parseTransform(
      getAttribute(attributes, 'transform', def: null),
      parentTransform,
    );

    if (transform != null) {
      return path.transformed(transform);
    } else {
      return path;
    }
  }

  /// Parses a `clipPath` element into a list of [Path]s.
  List<Path>? parseClipPath() {
    final String? rawClipAttribute = getAttribute(attributes, 'clip-path');
    if (rawClipAttribute != '') {
      return _definitions.getClipPath(rawClipAttribute!);
    }

    return null;
  }

  static const Map<String, BlendMode> _blendModes = <String, BlendMode>{
    'multiply': BlendMode.multiply,
    'screen': BlendMode.screen,
    'overlay': BlendMode.overlay,
    'darken': BlendMode.darken,
    'lighten': BlendMode.lighten,
    'color-dodge': BlendMode.colorDodge,
    'color-burn': BlendMode.colorBurn,
    'hard-light': BlendMode.hardLight,
    'soft-light': BlendMode.softLight,
    'difference': BlendMode.difference,
    'exclusion': BlendMode.exclusion,
    'hue': BlendMode.hue,
    'saturation': BlendMode.saturation,
    'color': BlendMode.color,
    'luminosity': BlendMode.luminosity,
  };

  /// Lookup the mask if the attribute is present.
  Node? parseMask() {
    final String? rawMaskAttribute = getAttribute(attributes, 'mask');
    if (rawMaskAttribute != '') {
      return _definitions.getDrawable(rawMaskAttribute!);
    }

    return null;
  }

  /// Parses style attributes or @style attribute.
  ///
  /// Remember that @style attribute takes precedence.
  Paint parseStyle(
    Rect bounds,
    Paint? parentStyle, {
    Color? defaultFillColor,
    Color? currentColor,
    bool leaf = false,
  }) {
    final Stroke? stroke = parseStroke(
      bounds,
      parentStyle?.stroke,
      currentColor,
      leaf,
    );
    final Fill? fill = parseFill(
      bounds,
      parentStyle?.fill,
      defaultFillColor,
      currentColor,
      leaf,
    );
    assert(!leaf || fill != Fill.empty);
    assert(!leaf || stroke != Stroke.empty);
    return Paint(
      blendMode: _blendModes[getAttribute(attributes, 'mix-blend-mode')!],
      stroke: stroke,
      fill: fill,
      pathFillType: parseFillRule(),
    ).applyParent(parentStyle, leaf: leaf);
  }

  /// Converts a SVG Color String (either a # prefixed color string or a named color) to a [Color].
  Color? parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return null;
    }

    if (colorString == 'none') {
      return null;
    }

    if (colorString.toLowerCase() == 'currentcolor') {
      return null;
    }

    // handle hex colors e.g. #fff or #ffffff.  This supports #RRGGBBAA
    if (colorString[0] == '#') {
      if (colorString.length == 4) {
        final String r = colorString[1];
        final String g = colorString[2];
        final String b = colorString[3];
        colorString = '#$r$r$g$g$b$b';
      }
      int color = int.parse(colorString.substring(1), radix: 16);

      if (colorString.length == 7) {
        return Color(color |= 0xFF000000);
      }

      if (colorString.length == 9) {
        return Color(color);
      }
    }

    // handle rgba() colors e.g. rgba(255, 255, 255, 1.0)
    if (colorString.toLowerCase().startsWith('rgba')) {
      final List<String> rawColorElements = colorString
          .substring(colorString.indexOf('(') + 1, colorString.indexOf(')'))
          .split(',')
          .map((String rawColor) => rawColor.trim())
          .toList();

      final double opacity = parseDouble(rawColorElements.removeLast())!;

      final List<int> rgb = rawColorElements
          .map((String rawColor) => int.parse(rawColor))
          .toList();

      return Color.fromRGBO(rgb[0], rgb[1], rgb[2], opacity);
    }

    // Conversion code from: https://github.com/MichaelFenwick/Color, thanks :)
    if (colorString.toLowerCase().startsWith('hsl')) {
      final List<int> values = colorString
          .substring(colorString.indexOf('(') + 1, colorString.indexOf(')'))
          .split(',')
          .map((String rawColor) {
        rawColor = rawColor.trim();

        if (rawColor.endsWith('%')) {
          rawColor = rawColor.substring(0, rawColor.length - 1);
        }

        if (rawColor.contains('.')) {
          return (parseDouble(rawColor)! * 2.55).round();
        }

        return int.parse(rawColor);
      }).toList();
      final double hue = values[0] / 360 % 1;
      final double saturation = values[1] / 100;
      final double luminance = values[2] / 100;
      final int alpha = values.length > 3 ? values[3] : 255;
      List<double> rgb = <double>[0, 0, 0];

      if (hue < 1 / 6) {
        rgb[0] = 1;
        rgb[1] = hue * 6;
      } else if (hue < 2 / 6) {
        rgb[0] = 2 - hue * 6;
        rgb[1] = 1;
      } else if (hue < 3 / 6) {
        rgb[1] = 1;
        rgb[2] = hue * 6 - 2;
      } else if (hue < 4 / 6) {
        rgb[1] = 4 - hue * 6;
        rgb[2] = 1;
      } else if (hue < 5 / 6) {
        rgb[0] = hue * 6 - 4;
        rgb[2] = 1;
      } else {
        rgb[0] = 1;
        rgb[2] = 6 - hue * 6;
      }

      rgb = rgb
          .map((double val) => val + (1 - saturation) * (0.5 - val))
          .toList();

      if (luminance < 0.5) {
        rgb = rgb.map((double val) => luminance * 2 * val).toList();
      } else {
        rgb = rgb
            .map((double val) => luminance * 2 * (1 - val) + 2 * val - 1)
            .toList();
      }

      rgb = rgb.map((double val) => val * 255).toList();

      return Color.fromARGB(
          alpha, rgb[0].round(), rgb[1].round(), rgb[2].round());
    }

    // handle rgb() colors e.g. rgb(255, 255, 255)
    if (colorString.toLowerCase().startsWith('rgb')) {
      final List<int> rgb = colorString
          .substring(colorString.indexOf('(') + 1, colorString.indexOf(')'))
          .split(',')
          .map((String rawColor) {
        rawColor = rawColor.trim();
        if (rawColor.endsWith('%')) {
          rawColor = rawColor.substring(0, rawColor.length - 1);
          return (parseDouble(rawColor)! * 2.55).round();
        }
        return int.parse(rawColor);
      }).toList();

      // rgba() isn't really in the spec, but Firefox supported it at one point so why not.
      final int a = rgb.length > 3 ? rgb[3] : 255;
      return Color.fromARGB(a, rgb[0], rgb[1], rgb[2]);
    }

    // handle named colors ('red', 'green', etc.).
    final Color? namedColor = namedColors[colorString];
    if (namedColor != null) {
      return namedColor;
    }

    throw StateError('Could not parse "$colorString" as a color.');
  }
}

// TODO(dnfield): remove this, support OoO defs.
void reportMissingDef(String? key, String? href, String methodName) {
  throw Exception(<String>[
    'Failed to find definition for $href',
    'This library only supports <defs> and xlink:href references that '
        'are defined ahead of their references.',
    'This error can be caused when the desired definition is defined after the element '
        'referring to it (e.g. at the end of the file), or defined in another file.',
    'This error is treated as non-fatal, but your SVG file will likely not render as intended',
  ].join('\n,'));
}

// TODO(dnfield): remove/fix this
class DrawableDefinitionServer {
  static const String emptyUrlIri = 'url(#)';
  final Map<String, Node> _drawables = <String, Node>{};
  final Map<String, Shader> _shaders = <String, Shader>{};

  Node? getDrawable(String ref) => _drawables[ref];
  Shader? getShader(String ref) => _shaders[ref];
  List<Path>? getClipPath(String ref) => null;
  T? getGradient<T extends Shader>(String ref) => null;
  void addGradient<T extends Shader>(String ref, T gradient) {
    _shaders[ref] = gradient;
  }

  void addClipPath(String ref, List<Path> paths) {}

  void addDrawable(String ref, Node drawable) {
    _drawables[ref] = drawable;
  }
}

class Viewport {
  const Viewport(this.width, this.height, this.transform);

  final double width;
  final double height;
  final AffineMatrix? transform;
}
