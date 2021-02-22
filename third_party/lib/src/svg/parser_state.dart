import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:xml/xml_events.dart' hide parseEvents;

import '../utilities/errors.dart';
import '../utilities/numbers.dart';
import '../utilities/xml.dart';
import '../vector_drawable.dart';
import 'colors.dart';
import 'parsers.dart';
import 'xml_parsers.dart';

final Set<String> _unhandledElements = <String>{'title', 'desc'};

typedef _ParseFunc = Future<void>? Function(
    SvgParserState parserState, bool warningsAsErrors);
typedef _PathFunc = Path? Function(List<XmlEventAttribute>? attributes);

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

Offset _parseCurrentOffset(SvgParserState parserState, Offset? lastOffset) {
  final String? x = parserState.attribute('x', def: null);
  final String? y = parserState.attribute('y', def: null);

  return Offset(
    x != null
        ? parseDouble(x)!
        : parseDouble(parserState.attribute('dx', def: '0'))! +
            (lastOffset?.dx ?? 0),
    y != null
        ? parseDouble(y)!
        : parseDouble(parserState.attribute('dy', def: '0'))! +
            (lastOffset?.dy ?? 0),
  );
}

class _TextInfo {
  const _TextInfo(
    this.style,
    this.offset,
    this.transform,
  );

  final DrawableStyle style;
  final Offset offset;
  final Matrix4? transform;

  @override
  String toString() => '$runtimeType{$offset, $style, $transform}';
}

class _Elements {
  static Future<void>? svg(SvgParserState parserState, bool warningsAsErrors) {
    final DrawableViewport? viewBox = parseViewBox(parserState.attributes);
    final String? id = parserState.attribute('id', def: '');

    // TODO(dnfield): Support nested SVG elements. https://github.com/dnfield/flutter_svg/issues/132
    if (parserState._root != null) {
      const String errorMessage = 'Unsupported nested <svg> element.';
      if (warningsAsErrors) {
        throw UnsupportedError(errorMessage);
      }
      FlutterError.reportError(FlutterErrorDetails(
        exception: UnsupportedError(errorMessage),
        informationCollector: () sync* {
          yield ErrorDescription(
              'The root <svg> element contained an unsupported nested SVG element.');
          if (parserState._key != null) {
            yield ErrorDescription('');
            yield DiagnosticsProperty<String>('Picture key', parserState._key);
          }
        },
        library: 'SVG',
        context: ErrorDescription('in _Element.svg'),
      ));
      parserState._parentDrawables.addLast(
        _SvgGroupTuple(
          'svg',
          DrawableGroup(
            id,
            <Drawable>[],
            parseStyle(
              parserState._key,
              parserState.attributes,
              parserState._definitions,
              viewBox!.viewBoxRect,
              null,
            ),
          ),
        ),
      );
      return null;
    }
    parserState._root = DrawableRoot(
      id,
      viewBox!,
      <Drawable>[],
      parserState._definitions,
      parseStyle(
        parserState._key,
        parserState.attributes,
        parserState._definitions,
        viewBox.viewBoxRect,
        null,
      ),
    );
    parserState.addGroup(parserState._currentStartElement!, parserState._root);
    return null;
  }

  static Future<void>? g(SvgParserState parserState, bool warningsAsErrors) {
    final DrawableParent parent = parserState.currentGroup!;
    final DrawableGroup group = DrawableGroup(
      parserState.attribute('id', def: ''),
      <Drawable>[],
      parseStyle(
        parserState._key,
        parserState.attributes,
        parserState._definitions,
        parserState.rootBounds,
        parent.style,
      ),
      transform: parseTransform(parserState.attribute('transform'))?.storage,
    );
    if (!parserState._inDefs) {
      parent.children!.add(group);
    }
    parserState.addGroup(parserState._currentStartElement!, group);
    return null;
  }

  static Future<void>? symbol(
      SvgParserState parserState, bool warningsAsErrors) {
    final DrawableParent parent = parserState.currentGroup!;
    final DrawableGroup group = DrawableGroup(
      parserState.attribute('id', def: ''),
      <Drawable>[],
      parseStyle(
        parserState._key,
        parserState.attributes,
        parserState._definitions,
        null,
        parent.style,
      ),
      transform: parseTransform(parserState.attribute('transform'))?.storage,
    );
    parserState.addGroup(parserState._currentStartElement!, group);
    return null;
  }

  static Future<void>? use(SvgParserState parserState, bool warningsAsErrors) {
    final DrawableParent? parent = parserState.currentGroup;
    final String xlinkHref = getHrefAttribute(parserState.attributes)!;
    if (xlinkHref.isEmpty) {
      return null;
    }

    final DrawableStyle style = parseStyle(
      parserState._key,
      parserState.attributes,
      parserState._definitions,
      parserState.rootBounds,
      parent!.style,
    );

    final Matrix4 transform =
        parseTransform(parserState.attribute('transform')) ??
            Matrix4.identity();
    transform.translate(
      parseDouble(parserState.attribute('x', def: '0')),
      parseDouble(parserState.attribute('y', def: '0'))!,
    );

    final DrawableStyleable ref =
        parserState._definitions.getDrawable('url($xlinkHref)')!;
    final DrawableGroup group = DrawableGroup(
      parserState.attribute('id', def: ''),
      <Drawable>[ref.mergeStyle(style)],
      style,
      transform: transform.storage,
    );

    final bool isIri = parserState.checkForIri(group);
    if (!parserState._inDefs || !isIri) {
      parent.children!.add(group);
    }
    return null;
  }

  static Future<void>? parseStops(
    SvgParserState parserState,
    List<Color> colors,
    List<double> offsets,
  ) {
    for (XmlEvent event in parserState._readSubtree()) {
      if (event is XmlEndElementEvent) {
        continue;
      }
      if (event is XmlStartElementEvent) {
        final String? rawOpacity = getAttribute(
          parserState.attributes,
          'stop-opacity',
          def: '1',
        );
        final Color stopColor =
            parseColor(getAttribute(parserState.attributes, 'stop-color')) ??
                colorBlack;
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
    SvgParserState parserState,
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
    final TileMode spreadMethod = parseTileMode(parserState.attributes);
    final String id = buildUrlIri(parserState.attributes);
    final Matrix4? originalTransform = parseTransform(
      parserState.attribute('gradientTransform', def: null),
    );

    final List<double> offsets = <double>[];
    final List<Color> colors = <Color>[];

    if (parserState._currentStartElement!.isSelfClosing) {
      final String? href = getHrefAttribute(parserState.attributes);
      final DrawableGradient? ref =
          parserState._definitions.getGradient<DrawableGradient>('url($href)');
      if (ref == null) {
        reportMissingDef(parserState._key, href, 'radialGradient');
      } else {
        if (gradientUnits == null) {
          isObjectBoundingBox =
              ref.unitMode == GradientUnitMode.objectBoundingBox;
        }
        colors.addAll(ref.colors!);
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
          : parseDouble(rawCx)!;
      cy = isPercentage(rawCy!)
          ? parsePercentage(rawCy) * parserState.rootBounds.height +
              parserState.rootBounds.top
          : parseDouble(rawCy)!;
      r = isPercentage(rawR!)
          ? parsePercentage(rawR) *
              ((parserState.rootBounds.height + parserState.rootBounds.width) /
                  2)
          : parseDouble(rawR)!;
      fx = isPercentage(rawFx!)
          ? parsePercentage(rawFx) * parserState.rootBounds.width +
              parserState.rootBounds.left
          : parseDouble(rawFx)!;
      fy = isPercentage(rawFy!)
          ? parsePercentage(rawFy) * parserState.rootBounds.height +
              parserState.rootBounds.top
          : parseDouble(rawFy)!;
    }

    parserState._definitions.addGradient(
      id,
      DrawableRadialGradient(
        center: Offset(cx, cy),
        radius: r,
        focal: (fx != cx || fy != cy) ? Offset(fx, fy) : Offset(cx, cy),
        focalRadius: 0.0,
        colors: colors,
        offsets: offsets,
        unitMode: isObjectBoundingBox
            ? GradientUnitMode.objectBoundingBox
            : GradientUnitMode.userSpaceOnUse,
        spreadMethod: spreadMethod,
        transform: originalTransform?.storage,
      ),
    );
    return null;
  }

  static Future<void>? linearGradient(
      SvgParserState parserState, bool warningsAsErrors) {
    final String? gradientUnits = getAttribute(
      parserState.attributes,
      'gradientUnits',
      def: null,
    );
    bool isObjectBoundingBox = gradientUnits != 'userSpaceOnUse';

    final String? x1 = parserState.attribute('x1', def: '0%');
    final String? x2 = parserState.attribute('x2', def: '100%');
    final String? y1 = parserState.attribute('y1', def: '0%');
    final String? y2 = parserState.attribute('y2', def: '0%');
    final String id = buildUrlIri(parserState.attributes);
    final Matrix4? originalTransform = parseTransform(
      parserState.attribute('gradientTransform', def: null),
    );
    final TileMode spreadMethod = parseTileMode(parserState.attributes);

    final List<Color> colors = <Color>[];
    final List<double> offsets = <double>[];
    if (parserState._currentStartElement!.isSelfClosing) {
      final String? href = getHrefAttribute(parserState.attributes);
      final DrawableGradient? ref =
          parserState._definitions.getGradient<DrawableGradient>('url($href)');
      if (ref == null) {
        reportMissingDef(parserState._key, href, 'linearGradient');
      } else {
        if (gradientUnits == null) {
          isObjectBoundingBox =
              ref.unitMode == GradientUnitMode.objectBoundingBox;
        }
        colors.addAll(ref.colors!);
        offsets.addAll(ref.offsets!);
      }
    } else {
      parseStops(parserState, colors, offsets);
    }

    Offset fromOffset, toOffset;
    if (isObjectBoundingBox) {
      fromOffset = Offset(
        parseDecimalOrPercentage(x1!),
        parseDecimalOrPercentage(y1!),
      );
      toOffset = Offset(
        parseDecimalOrPercentage(x2!),
        parseDecimalOrPercentage(y2!),
      );
    } else {
      fromOffset = Offset(
        isPercentage(x1!)
            ? parsePercentage(x1) * parserState.rootBounds.width +
                parserState.rootBounds.left
            : parseDouble(x1)!,
        isPercentage(y1!)
            ? parsePercentage(y1) * parserState.rootBounds.height +
                parserState.rootBounds.top
            : parseDouble(y1)!,
      );

      toOffset = Offset(
        isPercentage(x2!)
            ? parsePercentage(x2) * parserState.rootBounds.width +
                parserState.rootBounds.left
            : parseDouble(x2)!,
        isPercentage(y2!)
            ? parsePercentage(y2) * parserState.rootBounds.height +
                parserState.rootBounds.top
            : parseDouble(y2)!,
      );
    }

    parserState._definitions.addGradient(
      id,
      DrawableLinearGradient(
        from: fromOffset,
        to: toOffset,
        colors: colors,
        offsets: offsets,
        spreadMethod: spreadMethod,
        unitMode: isObjectBoundingBox
            ? GradientUnitMode.objectBoundingBox
            : GradientUnitMode.userSpaceOnUse,
        transform: originalTransform?.storage,
      ),
    );

    return null;
  }

  static Future<void>? clipPath(
      SvgParserState parserState, bool warningsAsErrors) {
    final String id = buildUrlIri(parserState.attributes);

    final List<Path> paths = <Path>[];
    Path? currentPath;
    for (XmlEvent event in parserState._readSubtree()) {
      if (event is XmlEndElementEvent) {
        continue;
      }
      if (event is XmlStartElementEvent) {
        final _PathFunc? pathFn = _svgPathFuncs[event.name];

        if (pathFn != null) {
          final Path nextPath = applyTransformIfNeeded(
            pathFn(parserState.attributes),
            parserState.attributes,
          )!;
          nextPath.fillType =
              parseFillRule(parserState.attributes, 'clip-rule')!;
          if (currentPath != null &&
              nextPath.fillType != currentPath.fillType) {
            currentPath = nextPath;
            paths.add(currentPath);
          } else if (currentPath == null) {
            currentPath = nextPath;
            paths.add(currentPath);
          } else {
            currentPath.addPath(nextPath, Offset.zero);
          }
        } else if (event.name == 'use') {
          final String? xlinkHref = getHrefAttribute(parserState.attributes);
          final DrawableStyleable? definitionDrawable =
              parserState._definitions.getDrawable('url($xlinkHref)');

          void extractPathsFromDrawable(Drawable? target) {
            if (target is DrawableShape) {
              paths.add(target.path);
            } else if (target is DrawableGroup) {
              target.children!.forEach(extractPathsFromDrawable);
            }
          }

          extractPathsFromDrawable(definitionDrawable);
        } else {
          final String errorMessage =
              'Unsupported clipPath child ${event.name}';
          if (warningsAsErrors) {
            throw UnsupportedError(errorMessage);
          }
          FlutterError.reportError(FlutterErrorDetails(
            exception: UnsupportedError(errorMessage),
            informationCollector: () sync* {
              yield ErrorDescription(
                  'The <clipPath> element contained an unsupported child ${event.name}');
              if (parserState._key != null) {
                yield ErrorDescription('');
                yield DiagnosticsProperty<String>(
                    'Picture key', parserState._key);
              }
            },
            library: 'SVG',
            context: ErrorDescription('in _Element.clipPath'),
          ));
        }
      }
    }
    parserState._definitions.addClipPath(id, paths);
    return null;
  }

  static Future<void> image(
      SvgParserState parserState, bool warningsAsErrors) async {
    final String? href = getHrefAttribute(parserState.attributes);
    if (href == null) {
      return;
    }
    final Offset offset = Offset(
      parseDouble(parserState.attribute('x', def: '0'))!,
      parseDouble(parserState.attribute('y', def: '0'))!,
    );
    final Size size = Size(
      parseDouble(parserState.attribute('width', def: '0'))!,
      parseDouble(parserState.attribute('height', def: '0'))!,
    );
    final Image image = await resolveImage(href);
    final DrawableParent parent = parserState._parentDrawables.last.drawable!;
    final DrawableStyle? parentStyle = parent.style;
    final DrawableRasterImage drawable = DrawableRasterImage(
      parserState.attribute('id', def: ''),
      image,
      offset,
      parseStyle(
        parserState._key,
        parserState.attributes,
        parserState._definitions,
        parserState.rootBounds,
        parentStyle,
      ),
      size: size,
      transform: parseTransform(parserState.attribute('transform'))?.storage,
    );
    final bool isIri = parserState.checkForIri(drawable);
    if (!parserState._inDefs || !isIri) {
      parserState.currentGroup!.children!.add(drawable);
    }
  }

  static Future<void> text(
      SvgParserState parserState, bool warningsAsErrors) async {
    assert(parserState != null); // ignore: unnecessary_null_comparison
    assert(parserState.currentGroup != null);
    if (parserState._currentStartElement!.isSelfClosing) {
      return;
    }

    // <text>, <tspan> -> Collect styles
    // <tref> TBD - looks like Inkscape supports it, but no browser does.
    // XmlNodeType.TEXT/CDATA -> DrawableText
    // Track the style(s) and offset(s) for <text> and <tspan> elements
    final Queue<_TextInfo> textInfos = ListQueue<_TextInfo>();
    double lastTextWidth = 0;

    void _processText(String value) {
      if (value.isEmpty) {
        return;
      }
      assert(textInfos.isNotEmpty);
      final _TextInfo lastTextInfo = textInfos.last;
      final Paragraph fill = createParagraph(
        value,
        lastTextInfo.style,
        lastTextInfo.style.fill,
      );
      final Paragraph stroke = createParagraph(
        value,
        lastTextInfo.style,
        DrawablePaint.isEmpty(lastTextInfo.style.stroke)
            ? transparentStroke
            : lastTextInfo.style.stroke,
      );
      parserState.currentGroup!.children!.add(
        DrawableText(
          parserState.attribute('id', def: ''),
          fill,
          stroke,
          lastTextInfo.offset,
          lastTextInfo.style.textStyle!.anchor ??
              DrawableTextAnchorPosition.start,
          transform: lastTextInfo.transform?.storage,
        ),
      );
      lastTextWidth = fill.maxIntrinsicWidth;
    }

    void _processStartElement(XmlStartElementEvent event) {
      _TextInfo? lastTextInfo;
      if (textInfos.isNotEmpty) {
        lastTextInfo = textInfos.last;
      }
      final Offset currentOffset = _parseCurrentOffset(
        parserState,
        lastTextInfo?.offset.translate(lastTextWidth, 0),
      );
      Matrix4? transform = parseTransform(parserState.attribute('transform'));
      if (lastTextInfo?.transform != null) {
        if (transform == null) {
          transform = lastTextInfo!.transform;
        } else {
          transform = lastTextInfo!.transform!.multiplied(transform);
        }
      }

      textInfos.add(_TextInfo(
        parseStyle(
          parserState._key,
          parserState.attributes,
          parserState._definitions,
          parserState.rootBounds,
          lastTextInfo?.style ?? parserState.currentGroup!.style,
        ),
        currentOffset,
        transform,
      ));
      if (event.isSelfClosing) {
        textInfos.removeLast();
      }
    }

    _processStartElement(parserState._currentStartElement!);

    for (XmlEvent event in parserState._readSubtree()) {
      if (event is XmlCDATAEvent) {
        _processText(event.text.trim());
      } else if (event is XmlTextEvent) {
        _processText(event.text.trim());
      }
      if (event is XmlStartElementEvent) {
        _processStartElement(event);
      } else if (event is XmlEndElementEvent) {
        textInfos.removeLast();
      }
    }
  }
}

class _Paths {
  static Path circle(List<XmlEventAttribute>? attributes) {
    final double cx = parseDouble(getAttribute(attributes, 'cx', def: '0'))!;
    final double cy = parseDouble(getAttribute(attributes, 'cy', def: '0'))!;
    final double r = parseDouble(getAttribute(attributes, 'r', def: '0'))!;
    final Rect oval = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    return Path()..addOval(oval);
  }

  static Path path(List<XmlEventAttribute>? attributes) {
    final String d = getAttribute(attributes, 'd')!;
    return parseSvgPathData(d);
  }

  static Path rect(List<XmlEventAttribute>? attributes) {
    final double x = parseDouble(getAttribute(attributes, 'x', def: '0'))!;
    final double y = parseDouble(getAttribute(attributes, 'y', def: '0'))!;
    final double w = parseDouble(getAttribute(attributes, 'width', def: '0'))!;
    final double h = parseDouble(getAttribute(attributes, 'height', def: '0'))!;
    final Rect rect = Rect.fromLTWH(x, y, w, h);
    String? rxRaw = getAttribute(attributes, 'rx', def: null);
    String? ryRaw = getAttribute(attributes, 'ry', def: null);
    rxRaw ??= ryRaw;
    ryRaw ??= rxRaw;

    if (rxRaw != null && rxRaw != '') {
      final double rx = parseDouble(rxRaw)!;
      final double ry = parseDouble(ryRaw)!;

      return Path()..addRRect(RRect.fromRectXY(rect, rx, ry));
    }

    return Path()..addRect(rect);
  }

  static Path? polygon(List<XmlEventAttribute>? attributes) {
    return parsePathFromPoints(attributes, true);
  }

  static Path? polyline(List<XmlEventAttribute>? attributes) {
    return parsePathFromPoints(attributes, false);
  }

  static Path? parsePathFromPoints(
      List<XmlEventAttribute>? attributes, bool close) {
    final String? points = getAttribute(attributes, 'points');
    if (points == '') {
      return null;
    }
    final String path = 'M$points${close ? 'z' : ''}';

    return parseSvgPathData(path);
  }

  static Path ellipse(List<XmlEventAttribute>? attributes) {
    final double cx = parseDouble(getAttribute(attributes, 'cx', def: '0'))!;
    final double cy = parseDouble(getAttribute(attributes, 'cy', def: '0'))!;
    final double rx = parseDouble(getAttribute(attributes, 'rx', def: '0'))!;
    final double ry = parseDouble(getAttribute(attributes, 'ry', def: '0'))!;

    final Rect r = Rect.fromLTWH(cx - rx, cy - ry, rx * 2, ry * 2);
    return Path()..addOval(r);
  }

  static Path line(List<XmlEventAttribute>? attributes) {
    final double x1 = parseDouble(getAttribute(attributes, 'x1', def: '0'))!;
    final double x2 = parseDouble(getAttribute(attributes, 'x2', def: '0'))!;
    final double y1 = parseDouble(getAttribute(attributes, 'y1', def: '0'))!;
    final double y2 = parseDouble(getAttribute(attributes, 'y2', def: '0'))!;

    return Path()
      ..moveTo(x1, y1)
      ..lineTo(x2, y2);
  }
}

class _SvgGroupTuple {
  _SvgGroupTuple(this.name, this.drawable);

  final String name;
  final DrawableParent? drawable;
}

/// The implementation of [SvgParser].
///
/// Maintains state while pushing an [XmlPushReader] through the SVG tree.
class SvgParserState {
  /// Creates a new [SvgParserState].
  SvgParserState(Iterable<XmlEvent> events, this._key, this._warningsAsErrors)
      // ignore: unnecessary_null_comparison
      : assert(events != null),
        _eventIterator = events.iterator;

  final Iterator<XmlEvent> _eventIterator;
  final String? _key;
  final bool _warningsAsErrors;
  final DrawableDefinitionServer _definitions = DrawableDefinitionServer();
  final Queue<_SvgGroupTuple> _parentDrawables = ListQueue<_SvgGroupTuple>(10);
  DrawableRoot? _root;
  bool _inDefs = false;
  List<XmlEventAttribute>? _currentAttributes;
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
      _currentAttributes = <XmlEventAttribute>[];
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
        if (getAttribute(event.attributes, 'display') == 'none' ||
            getAttribute(event.attributes, 'visibility') == 'hidden') {
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
        _currentAttributes = event.attributes;
        _currentStartElement = event;
        depth += 1;
        isSelfClosing = event.isSelfClosing;
      }
      yield event;

      if (isSelfClosing || event is XmlEndElementEvent) {
        depth -= 1;
        assert(depth >= 0);
        _currentAttributes = <XmlEventAttribute>[];
        _currentStartElement = null;
      }
      if (depth < subtreeStartDepth) {
        return;
      }
    }
  }

  /// Drive the [XmlTextReader] to EOF and produce a [DrawableRoot].
  Future<DrawableRoot> parse() async {
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
    return _root!;
  }

  /// The XML Attributes of the current node in the tree.
  List<XmlEventAttribute>? get attributes => _currentAttributes;

  /// Gets the attribute for the current position of the parser.
  String? attribute(String name, {String? def, String? namespace}) =>
      getAttribute(attributes, name, def: def, namespace: namespace);

  /// The current group, if any, in the [Drawable] heirarchy.
  DrawableParent? get currentGroup {
    assert(_parentDrawables != null); // ignore: unnecessary_null_comparison
    assert(_parentDrawables.isNotEmpty);
    return _parentDrawables.last.drawable;
  }

  /// The root bounds of the drawable.
  Rect get rootBounds {
    assert(_root != null, 'Cannot get rootBounds with null root');
    assert(_root!.viewport != null); // ignore: unnecessary_null_comparison
    return _root!.viewport.viewBoxRect;
  }

  /// Whether this [DrawableStyleable] belongs in the [DrawableDefinitions] or not.
  bool checkForIri(DrawableStyleable? drawable) {
    final String iri = buildUrlIri(attributes);
    if (iri != emptyUrlIri) {
      _definitions.addDrawable(iri, drawable!);
      return true;
    }
    return false;
  }

  /// Appends a group to the collection.
  void addGroup(XmlStartElementEvent event, DrawableParent? drawable) {
    _parentDrawables.addLast(_SvgGroupTuple(event.name, drawable));
    checkForIri(drawable);
  }

  /// Appends a [DrawableShape] to the [currentGroup].
  bool addShape(XmlStartElementEvent event) {
    final _PathFunc? pathFunc = _svgPathFuncs[event.name];
    if (pathFunc == null) {
      return false;
    }

    final DrawableParent parent = _parentDrawables.last.drawable!;
    final DrawableStyle? parentStyle = parent.style;
    final Path path = pathFunc(attributes)!;
    final DrawableStyleable drawable = DrawableShape(
      getAttribute(attributes, 'id', def: ''),
      path,
      parseStyle(
        _key,
        attributes,
        _definitions,
        path.getBounds(),
        parentStyle,
        defaultFillColor: colorBlack,
      ),
      transform: parseTransform(getAttribute(attributes, 'transform'))?.storage,
    );
    final bool isIri = checkForIri(drawable);
    if (!_inDefs || !isIri) {
      parent.children!.add(drawable);
    }
    return true;
  }

  /// Potentially handles a starting element.
  bool startElement(XmlStartElementEvent event) {
    if (event.name == 'defs') {
      // we won't get a call to `endElement()` if we're in a '<defs/>'
      _inDefs = !event.isSelfClosing;
      return true;
    }
    return addShape(event);
  }

  /// Handles the end of an XML element.
  void endElement(XmlEndElementEvent event) {
    if (event.name == _parentDrawables.last.name) {
      _parentDrawables.removeLast();
    }
    if (event.name == 'defs') {
      _inDefs = false;
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
      FlutterError.reportError(FlutterErrorDetails(
        exception: UnimplementedError(
            'The <style> element is not implemented in this library.'),
        informationCollector: () sync* {
          yield ErrorDescription(
              'Style elements are not supported by this library and the requested SVG may not '
              'render as intended.');
          yield ErrorHint(
              'If possible, ensure the SVG uses inline styles and/or attributes (which are '
              'supported), or use a preprocessing utility such as svgcleaner to inline the '
              'styles for you.');
          yield ErrorDescription('');
          yield DiagnosticsProperty<String>('Picture key', _key);
        },
        library: 'SVG',
        context: ErrorDescription('in parseSvgElement'),
      ));
    } else if (_unhandledElements.add(event.name)) {
      print(errorMessage);
    }
  }
}
