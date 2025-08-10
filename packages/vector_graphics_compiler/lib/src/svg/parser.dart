// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:xml/xml_events.dart';

import '../geometry/basic_types.dart';
import '../geometry/matrix.dart';
import '../geometry/path.dart';
import '../image/image_info.dart';
import '../paint.dart';
import '../vector_instructions.dart';
import 'clipping_optimizer.dart';
import 'color_mapper.dart';
import 'colors.dart';
import 'masking_optimizer.dart';
import 'node.dart';
import 'numbers.dart' as numbers show parseDoubleWithUnits;
import 'numbers.dart' hide parseDoubleWithUnits;
import 'overdraw_optimizer.dart';
import 'parsers.dart';
import 'path_ops.dart' as path_ops;
import 'resolver.dart';
import 'tessellator.dart';
import 'theme.dart';
import 'visitor.dart';

final Set<String> _unhandledElements = <String>{'title', 'desc'};

typedef _ParseFunc = void Function(
    SvgParser parserState, bool warningsAsErrors);
typedef _PathFunc = Path? Function(SvgParser parserState);

final RegExp _whitespacePattern = RegExp(r'\s');

const Map<String, _ParseFunc> _svgElementParsers = <String, _ParseFunc>{
  'svg': _Elements.svg,
  'g': _Elements.g,
  'a': _Elements.g, // treat as group
  'use': _Elements.use,
  'symbol': _Elements.symbol,
  'mask': _Elements.symbol, // treat as symbol
  'pattern': _Elements.pattern,
  'radialGradient': _Elements.radialGradient,
  'linearGradient': _Elements.linearGradient,
  'clipPath': _Elements.clipPath,
  'image': _Elements.image,
  'text': _Elements.textOrTspan,
  'tspan': _Elements.textOrTspan,
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
  static void svg(SvgParser parserState, bool warningsAsErrors) {
    final _Viewport viewBox = parserState._parseViewBox();

    // TODO(dnfield): Support nested SVG elements. https://github.com/dnfield/flutter_svg/issues/132
    if (parserState._root != null) {
      const String errorMessage = 'Unsupported nested <svg> element.';
      if (warningsAsErrors) {
        throw UnsupportedError(errorMessage);
      }
      parserState._parentDrawables.addLast(
        _SvgGroupTuple(
          'svg',
          ViewportNode(
            parserState._currentAttributes,
            width: viewBox.width,
            height: viewBox.height,
            transform: viewBox.transform,
          ),
        ),
      );
      return;
    }
    parserState._root = ViewportNode(
      parserState._currentAttributes,
      width: viewBox.width,
      height: viewBox.height,
      transform: viewBox.transform,
    );
    parserState.addGroup(parserState._currentStartElement!, parserState._root!);
    return;
  }

  static void g(SvgParser parserState, bool warningsAsErrors) {
    if (parserState._currentStartElement?.isSelfClosing ?? false) {
      return;
    }
    final ParentNode parent = parserState.currentGroup!;

    final ParentNode group = ParentNode(parserState._currentAttributes);

    parent.addChild(
      group,
      clipId: parserState._currentAttributes.clipPathId,
      clipResolver: parserState._definitions.getClipPath,
      maskId: parserState.attribute('mask'),
      maskResolver: parserState._definitions.getDrawable,
      patternId: parserState._definitions.getPattern(parserState),
      patternResolver: parserState._definitions.getDrawable,
    );
    parserState.addGroup(parserState._currentStartElement!, group);
    return;
  }

  static void textOrTspan(SvgParser parserState, bool warningsAsErrors) {
    if (parserState._currentStartElement?.isSelfClosing ?? false) {
      return;
    }
    final ParentNode parent = parserState.currentGroup!;
    final XmlStartElementEvent element = parserState._currentStartElement!;

    final TextPositionNode group = TextPositionNode(
      parserState._currentAttributes,
      reset: element.localName == 'text',
    );

    parent.addChild(
      group,
      clipId: parserState._currentAttributes.clipPathId,
      clipResolver: parserState._definitions.getClipPath,
      maskId: parserState.attribute('mask'),
      maskResolver: parserState._definitions.getDrawable,
      patternId: parserState._definitions.getPattern(parserState),
      patternResolver: parserState._definitions.getDrawable,
    );
    parserState.addGroup(element, group);
    return;
  }

  static void symbol(SvgParser parserState, bool warningsAsErrors) {
    final ParentNode group = ParentNode(parserState._currentAttributes);
    parserState.addGroup(parserState._currentStartElement!, group);
    return;
  }

  static void pattern(SvgParser parserState, bool warningsAsErrors) {
    final SvgAttributes attributes = parserState._currentAttributes;
    final String rawWidth = parserState.attribute('width') ?? '';
    final String rawHeight = parserState.attribute('height') ?? '';

    double? patternWidth =
        parsePatternUnitToDouble(rawWidth, 'width', viewBox: parserState._root);
    double? patternHeight = parsePatternUnitToDouble(rawHeight, 'height',
        viewBox: parserState._root);

    if (patternWidth == null || patternHeight == null) {
      final _Viewport viewBox = parserState._parseViewBox();
      patternWidth = viewBox.width;
      patternHeight = viewBox.height;
    }

    final String? rawX = attributes.raw['x'];
    final String? rawY = attributes.raw['y'];
    final String id = parserState.buildUrlIri();
    parserState.patternIds.add(id);
    final SvgAttributes newAttributes = SvgAttributes._(
        raw: attributes.raw,
        id: attributes.id,
        href: attributes.href,
        transform: attributes.transform,
        color: attributes.color,
        stroke: attributes.stroke,
        fill: attributes.fill,
        fillRule: attributes.fillRule,
        clipRule: attributes.clipRule,
        clipPathId: attributes.clipPathId,
        blendMode: attributes.blendMode,
        fontFamily: attributes.fontFamily,
        fontWeight: attributes.fontWeight,
        fontSize: attributes.fontSize,
        x: DoubleOrPercentage.fromString(rawX),
        y: DoubleOrPercentage.fromString(rawY),
        width: patternWidth,
        height: patternHeight);

    final ParentNode group = ParentNode(newAttributes);
    parserState.addGroup(parserState._currentStartElement!, group);
    return;
  }

  static void use(SvgParser parserState, bool warningsAsErrors) {
    final ParentNode? parent = parserState.currentGroup;
    final String? xlinkHref = parserState._currentAttributes.href;
    if (xlinkHref == null || xlinkHref.isEmpty) {
      return;
    }

    final AffineMatrix transform =
        (parseTransform(parserState.attribute('transform')) ??
                AffineMatrix.identity)
            .translated(
      parserState.parseDoubleWithUnits(
        parserState.attribute('x', def: '0'),
      )!,
      parserState.parseDoubleWithUnits(
        parserState.attribute('y', def: '0'),
      )!,
    );

    final ParentNode group = ParentNode(
      // parserState._currentAttributes,
      SvgAttributes.empty,
      precalculatedTransform: transform,
    );

    group.addChild(
      DeferredNode(
        parserState._currentAttributes,
        refId: 'url($xlinkHref)',
        resolver: parserState._definitions.getDrawable,
      ),
      clipResolver: parserState._definitions.getClipPath,
      maskResolver: parserState._definitions.getDrawable,
      patternResolver: parserState._definitions.getDrawable,
    );
    if ('#${parserState._currentAttributes.id}' != xlinkHref) {
      parserState.checkForIri(group);
    }
    parent!.addChild(
      group,
      clipId: parserState._currentAttributes.clipPathId,
      clipResolver: parserState._definitions.getClipPath,
      maskId: parserState.attribute('mask'),
      maskResolver: parserState._definitions.getDrawable,
      patternId: parserState._definitions.getPattern(parserState),
      patternResolver: parserState._definitions.getDrawable,
    );
    return;
  }

  static void parseStops(
    SvgParser parserState,
    List<Color> colors,
    List<double> offsets,
  ) {
    for (final XmlEvent event in parserState._readSubtree()) {
      if (event is XmlEndElementEvent) {
        continue;
      }
      if (event is XmlStartElementEvent) {
        final String rawOpacity = parserState.attribute(
          'stop-opacity',
          def: '1',
        )!;
        final Color stopColor = parserState.parseColor(
                parserState.attribute('stop-color'),
                attributeName: 'stop-color',
                id: parserState._currentAttributes.id) ??
            Color.opaqueBlack;
        colors.add(stopColor.withOpacity(parseDouble(rawOpacity)!));

        final String rawOffset = parserState.attribute(
          'offset',
          def: '0%',
        )!;
        offsets.add(parseDecimalOrPercentage(rawOffset));
      }
    }
    return;
  }

  static void radialGradient(
    SvgParser parserState,
    bool warningsAsErrors,
  ) {
    final GradientUnitMode? unitMode = parserState.parseGradientUnitMode();
    final String? rawCx = parserState.attribute('cx', def: '50%');
    final String? rawCy = parserState.attribute('cy', def: '50%');
    final String? rawR = parserState.attribute('r', def: '50%');
    final String? rawFx = parserState.attribute('fx', def: rawCx);
    final String? rawFy = parserState.attribute('fy', def: rawCy);
    final TileMode? spreadMethod = parserState.parseTileMode();
    final String id = parserState.buildUrlIri();
    final AffineMatrix? originalTransform = parseTransform(
      parserState.attribute('gradientTransform'),
    );

    List<double>? offsets;
    List<Color>? colors;

    final bool defer = parserState._currentStartElement!.isSelfClosing;
    if (!defer) {
      offsets = <double>[];
      colors = <Color>[];
      parseStops(parserState, colors, offsets);
    }

    final double cx = parseDecimalOrPercentage(rawCx!);
    final double cy = parseDecimalOrPercentage(rawCy!);
    final double r = parseDecimalOrPercentage(rawR!);
    final double fx = parseDecimalOrPercentage(rawFx!);
    final double fy = parseDecimalOrPercentage(rawFy!);

    parserState._definitions.addGradient(
      RadialGradient(
        id: id,
        center: Point(cx, cy),
        radius: r,
        focalPoint: (fx != cx || fy != cy) ? Point(fx, fy) : null,
        colors: colors,
        offsets: offsets,
        unitMode: unitMode,
        tileMode: spreadMethod,
        transform: originalTransform,
      ),
      parserState._currentAttributes.href,
    );
    return;
  }

  static void linearGradient(
    SvgParser parserState,
    bool warningsAsErrors,
  ) {
    final GradientUnitMode? unitMode = parserState.parseGradientUnitMode();
    final String x1 = parserState.attribute('x1', def: '0%')!;
    final String x2 = parserState.attribute('x2', def: '100%')!;
    final String y1 = parserState.attribute('y1', def: '0%')!;
    final String y2 = parserState.attribute('y2', def: '0%')!;
    final String id = parserState.buildUrlIri();
    final AffineMatrix? originalTransform = parseTransform(
      parserState.attribute('gradientTransform'),
    );
    final TileMode? spreadMethod = parserState.parseTileMode();

    List<double>? offsets;
    List<Color>? colors;

    final bool defer = parserState._currentStartElement!.isSelfClosing;
    if (!defer) {
      offsets = <double>[];
      colors = <Color>[];
      parseStops(parserState, colors, offsets);
    }

    final Point fromPoint = Point(
      parseDecimalOrPercentage(x1),
      parseDecimalOrPercentage(y1),
    );
    final Point toPoint = Point(
      parseDecimalOrPercentage(x2),
      parseDecimalOrPercentage(y2),
    );

    parserState._definitions.addGradient(
      LinearGradient(
        id: id,
        from: fromPoint,
        to: toPoint,
        colors: colors,
        offsets: offsets,
        tileMode: spreadMethod,
        unitMode: unitMode,
        transform: originalTransform,
      ),
      parserState._currentAttributes.href,
    );

    return;
  }

  static void clipPath(SvgParser parserState, bool warningsAsErrors) {
    final String id = parserState.buildUrlIri();
    final List<Node> pathNodes = <Node>[];
    for (final XmlEvent event in parserState._readSubtree()) {
      if (event is XmlEndElementEvent) {
        continue;
      }
      if (event is XmlStartElementEvent) {
        final _PathFunc? pathFn = _svgPathFuncs[event.name];

        if (pathFn != null) {
          final Path sourcePath = parserState.applyTransformIfNeeded(
            pathFn(parserState)!,
            parserState.currentGroup?.transform,
          );
          pathNodes.add(
            PathNode(
              Path(
                commands: sourcePath.commands.toList(),
                fillType: parserState._currentAttributes.clipRule ??
                    PathFillType.nonZero,
              ),
              parserState._currentAttributes,
            ),
          );
        } else if (event.name == 'use') {
          final String? xlinkHref = parserState._currentAttributes.href;
          pathNodes.add(
            DeferredNode(
              parserState._currentAttributes,
              refId: 'url($xlinkHref)',
              resolver: parserState._definitions.getDrawable,
            ),
          );
        } else {
          final String errorMessage =
              'Unsupported clipPath child ${event.name}';
          if (warningsAsErrors) {
            throw UnsupportedError(errorMessage);
          }
        }
      }
    }
    parserState._definitions.addClipPath(
      id,
      pathNodes,
    );
    return;
  }

  static void image(
    SvgParser parserState,
    bool warningsAsErrors,
  ) {
    final String? xlinkHref = parserState._currentAttributes.href;
    if (xlinkHref == null) {
      return;
    }

    if (xlinkHref.startsWith('data:')) {
      const Map<String, ImageFormat> supportedMimeTypes = <String, ImageFormat>{
        'png': ImageFormat.png,
        'jpeg': ImageFormat.jpeg,
        'jpg': ImageFormat.jpeg,
        'webp': ImageFormat.webp,
        'gif': ImageFormat.gif,
        'bmp': ImageFormat.bmp,
      };
      final int semiColonLocation = xlinkHref.indexOf(';') + 1;
      final int commaLocation = xlinkHref.indexOf(',', semiColonLocation) + 1;
      final String mimeType = xlinkHref
          .substring(xlinkHref.indexOf('/') + 1, semiColonLocation - 1)
          .replaceAll(_whitespacePattern, '')
          .toLowerCase();

      final ImageFormat? format = supportedMimeTypes[mimeType];
      if (format == null) {
        if (warningsAsErrors) {
          throw UnimplementedError(
              'Image data format not supported: $mimeType');
        } else {
          print('Warning: Unsupported image format $mimeType');
        }
        return;
      }

      final Uint8List data = base64.decode(xlinkHref
          .substring(commaLocation)
          .replaceAll(_whitespacePattern, ''));
      final ImageNode image =
          ImageNode(data, format, parserState._currentAttributes);
      parserState.currentGroup!.addChild(
        image,
        clipResolver: parserState._definitions.getClipPath,
        maskResolver: parserState._definitions.getDrawable,
        patternResolver: parserState._definitions.getDrawable,
      );
      parserState.checkForIri(image);
      return;
    }
    if (warningsAsErrors) {
      throw UnimplementedError('Image data format not supported: $xlinkHref');
    }
    return;
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
    return PathBuilder(parserState._currentAttributes.fillRule)
        .addOval(oval)
        .toPath();
  }

  static Path path(SvgParser parserState) {
    final String d = parserState.attribute('d', def: '')!;
    return parseSvgPathData(d, parserState._currentAttributes.fillRule);
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
      return PathBuilder(parserState._currentAttributes.fillRule)
          .addRRect(Rect.fromLTWH(x, y, w, h), rx, ry)
          .toPath();
    }

    return PathBuilder(parserState._currentAttributes.fillRule)
        .addRect(Rect.fromLTWH(x, y, w, h))
        .toPath();
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

    return parseSvgPathData(path, parserState._currentAttributes.fillRule);
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
    return PathBuilder(parserState._currentAttributes.fillRule)
        .addOval(r)
        .toPath();
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

    return PathBuilder(parserState._currentAttributes.fillRule)
        .moveTo(x1, y1)
        .lineTo(x2, y2)
        .toPath();
  }
}

class _SvgGroupTuple {
  _SvgGroupTuple(this.name, this.drawable);

  final String name;
  final ParentNode drawable;
}

/// Parse an SVG to the initial Node tree.
@visibleForTesting
Node parseToNodeTree(String source) {
  return SvgParser(source, const SvgTheme(), null, true, null)
      ._parseToNodeTree();
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
    this._colorMapper,
  ) : _eventIterator = parseEvents(xml).iterator;

  /// The theme used when parsing SVG elements.
  final SvgTheme theme;

  final ColorMapper? _colorMapper;

  final Iterator<XmlEvent> _eventIterator;
  final String? _key;
  final bool _warningsAsErrors;
  final _Resolver _definitions = _Resolver();
  final Queue<_SvgGroupTuple> _parentDrawables = ListQueue<_SvgGroupTuple>(10);

  /// Toggles whether [MaskingOptimizer] is enabled or disabled.
  bool enableMaskingOptimizer = true;

  /// Toggles whether [ClippingOptimizer] is enabled or disabled.
  bool enableClippingOptimizer = true;

  /// Toggles whether [OverdrawOptimizer] is enabled or disabled.
  bool enableOverdrawOptimizer = true;

  /// List of known patternIds.
  Set<String> patternIds = <String>{};

  ViewportNode? _root;
  SvgAttributes _currentAttributes = SvgAttributes.empty;
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
      _currentAttributes = SvgAttributes.empty;
      _currentStartElement = null;
      if (depth < subtreeStartDepth) {
        return;
      }
    }
  }

  XmlEndElementEvent? _lastEndElementEvent;

  Iterable<XmlEvent> _readSubtree() sync* {
    final int subtreeStartDepth = depth;
    while (_eventIterator.moveNext()) {
      final XmlEvent event = _eventIterator.current;
      bool isSelfClosing = false;
      if (event is XmlStartElementEvent) {
        final Map<String, String> attributeMap =
            _createAttributeMap(event.attributes);
        if (!_isVisible(attributeMap)) {
          if (!event.isSelfClosing) {
            depth += 1;
            _discardSubtree();
          }
          continue;
        }
        _currentStartElement = event;
        _currentAttributes = _createSvgAttributes(
          attributeMap,
          currentColor: depth == 0 ? theme.currentColor : null,
        );
        depth += 1;
        isSelfClosing = event.isSelfClosing;
      }
      yield event;

      if (isSelfClosing || event is XmlEndElementEvent) {
        depth -= 1;
        assert(depth >= 0);
        _currentAttributes = SvgAttributes.empty;
        _currentStartElement = null;
      }
      if (depth < subtreeStartDepth) {
        return;
      }
    }
  }

  static final RegExp _contiguousSpaceMatcher = RegExp(r' +');
  bool _lastTextEndedWithSpace = false;
  void _appendText(String text) {
    assert(_inTextOrTSpan);

    assert(_whitespacePattern.pattern == r'\s');
    final bool textHasNonWhitespace = text.trim() != '';

    // Not from the spec, but seems like how Chrome behaves.
    // - If `x` is specified, don't prepend whitespace.
    // - If the last element was a tspan and we're dealing with some
    //   non-whitespace data, prepend a space.
    // - If the last text wasn't whitespace and ended with whitespace, prepend
    //   a space.
    final bool prependSpace = _currentAttributes.x == null &&
            (_lastEndElementEvent?.localName == 'tspan' &&
                textHasNonWhitespace) ||
        _lastTextEndedWithSpace;

    _lastTextEndedWithSpace = textHasNonWhitespace &&
        text.startsWith(_whitespacePattern, text.length - 1);

    // From the spec:
    //   First, it will remove all newline characters.
    //   Then it will convert all tab characters into space characters.
    //   Then, it will strip off all leading and trailing space characters.
    //   Then, all contiguous space characters will be consolidated.
    text = text
        .replaceAll('\n', '')
        .replaceAll('\t', ' ')
        .trim()
        .replaceAll(_contiguousSpaceMatcher, ' ');

    if (text.isEmpty) {
      return;
    }

    currentGroup?.addChild(
      TextNode(
        prependSpace ? ' $text' : text,
        _currentAttributes,
      ),
      // Do not supply pattern/clip/mask IDs, those are handled by the group
      // text or tspan this text is part of.
      clipResolver: _definitions.getClipPath,
      maskResolver: _definitions.getDrawable,
      patternResolver: _definitions.getDrawable,
    );
  }

  bool get _inTextOrTSpan =>
      _parentDrawables.isNotEmpty &&
      (_parentDrawables.last.name == 'text' ||
          _parentDrawables.last.name == 'tspan');

  void _parseTree() {
    for (final XmlEvent event in _readSubtree()) {
      if (event is XmlStartElementEvent) {
        if (startElement(event)) {
          continue;
        }
        final _ParseFunc? parseFunc = _svgElementParsers[event.name];
        if (parseFunc == null) {
          if (!event.isSelfClosing) {
            _discardSubtree();
          }
          assert(() {
            unhandledElement(event);
            return true;
          }());
        } else {
          parseFunc(this, _warningsAsErrors);
        }
      } else if (event is XmlEndElementEvent) {
        endElement(event);
      } else if (_inTextOrTSpan) {
        if (event is XmlCDATAEvent) {
          _appendText(event.value);
        } else if (event is XmlTextEvent) {
          _appendText(event.value);
        }
      }
    }
    if (_root == null) {
      throw StateError('Invalid SVG data');
    }
    _definitions._seal();
  }

  /// Drive the XML reader to EOF and produce [VectorInstructions].
  VectorInstructions parse() {
    _parseTree();

    /// Resolve the tree
    final ResolvingVisitor resolvingVisitor = ResolvingVisitor();
    final Tessellator tessellator = Tessellator();
    final MaskingOptimizer maskingOptimizer = MaskingOptimizer();
    final ClippingOptimizer clippingOptimizer = ClippingOptimizer();
    final OverdrawOptimizer overdrawOptimizer = OverdrawOptimizer();

    Node newRoot = _root!.accept(resolvingVisitor, AffineMatrix.identity);

    // The order of these matters. The overdraw optimizer can do its best if
    // masks and unnecessary clips have been eliminated.
    if (enableMaskingOptimizer) {
      if (path_ops.isPathOpsInitialized) {
        newRoot = maskingOptimizer.apply(newRoot);
      } else {
        throw Exception('PathOps library was not initialized.');
      }
    }

    if (enableClippingOptimizer) {
      if (path_ops.isPathOpsInitialized) {
        newRoot = clippingOptimizer.apply(newRoot);
      } else {
        throw Exception('PathOps library was not initialized.');
      }
    }

    if (enableOverdrawOptimizer) {
      if (path_ops.isPathOpsInitialized) {
        newRoot = overdrawOptimizer.apply(newRoot);
      } else {
        throw Exception('PathOps library was not initialized.');
      }
    }

    if (isTesselatorInitialized) {
      newRoot = newRoot.accept(tessellator, null);
    }

    /// Convert to vector instructions
    final CommandBuilderVisitor commandVisitor = CommandBuilderVisitor();
    newRoot.accept(commandVisitor, null);

    return commandVisitor.toInstructions();
  }

  Node _parseToNodeTree() {
    _parseTree();
    return _root!;
  }

  /// Gets the attribute for the current position of the parser.
  String? attribute(String name, {String? def}) =>
      _currentAttributes.raw[name] ?? def;

  /// The current group, if any, in the [Drawable] heirarchy.
  ParentNode? get currentGroup {
    assert(_parentDrawables.isNotEmpty);
    return _parentDrawables.last.drawable;
  }

  /// The root bounds of the drawable.
  Rect get rootBounds {
    assert(_root != null, 'Cannot get rootBounds with null root');
    return _root!.viewport;
  }

  /// Whether this [DrawableStyleable] belongs in the [DrawableDefinitions] or not.
  bool checkForIri(AttributedNode drawable) {
    assert('#${_currentAttributes.id}' != _currentAttributes.href);
    final String iri = buildUrlIri();
    if (iri != emptyUrlIri) {
      _definitions.addDrawable(iri, drawable);
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
    final ParentNode parent = _parentDrawables.last.drawable;
    final Path? path = pathFunc(this);
    if (path == null) {
      return false;
    }
    final PathNode drawable = PathNode(path, _currentAttributes);
    checkForIri(drawable);

    parent.addChild(
      drawable,
      clipId: _currentAttributes.clipPathId,
      clipResolver: _definitions.getClipPath,
      maskId: attribute('mask'),
      maskResolver: _definitions.getDrawable,
      patternId: _definitions.getPattern(this),
      patternResolver: _definitions.getDrawable,
    );
    return true;
  }

  /// Potentially handles a starting element, if it was a singular shape or a
  /// `<defs>` element.
  bool startElement(XmlStartElementEvent event) {
    if (event.name == 'defs') {
      if (!event.isSelfClosing) {
        addGroup(
          event,
          ParentNode(_currentAttributes),
        );
        return true;
      }
    }
    return addShape(event);
  }

  /// Handles the end of an XML element.
  void endElement(XmlEndElementEvent event) {
    while (event.name == _parentDrawables.last.name &&
        _parentDrawables.last.drawable is ClipNode) {
      _parentDrawables.removeLast();
    }
    if (event.name == _parentDrawables.last.name) {
      _parentDrawables.removeLast();
    }
    _lastEndElementEvent = event;
    if (event.name == 'text') {
      // reset state.
      _lastTextEndedWithSpace = false;
    }
  }

  /// Prints an error for unhandled elements.
  ///
  /// Will only print an error once for unhandled/unexpected elements, except for
  /// `<style/>`, `<title/>`, and `<desc/>` elements.
  void unhandledElement(XmlStartElementEvent event) {
    final String errorMessage =
        'unhandled element <${event.name}/>; Picture key: $_key';
    if (_warningsAsErrors) {
      // Throw error instead of log warning.
      throw UnimplementedError(errorMessage);
    }
    if (_unhandledElements.add(event.name)) {
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
    return numbers.parseDoubleWithUnits(
      rawDouble,
      tryParse: tryParse,
      theme: theme,
    );
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
  double? parseFontSize(String? raw) {
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

    // TODO(dnfield): support 'larger' and 'smaller'.
    // Rough idea for how to do this: this method returns a struct that contains
    // either a double? fontSize or a double? multiplier.
    // Larger multiplier: 1.2
    // Smaller multiplier: .8
    // When resolving the font size later, multiple the incoming size by the
    // multiplier if specified.
    // There was once an implementation of this which was definitely not
    // correct but probably not used much either.

    throw StateError('Could not parse font-size: $raw');
  }

  /// Parses a `text-decoration` attribute value into a [TextDecoration].
  TextDecoration? parseTextDecoration(String? textDecoration) {
    if (textDecoration == null) {
      return null;
    }
    switch (textDecoration) {
      case 'none':
        return TextDecoration.none;
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'line-through':
        return TextDecoration.lineThrough;
    }
    throw UnsupportedError(
        'Attribute value for text-decoration="$textDecoration"'
        ' is not supported');
  }

  /// Parses a `text-decoration-style` attribute value into a [TextDecorationStyle].
  TextDecorationStyle? parseTextDecorationStyle(String? textDecorationStyle) {
    if (textDecorationStyle == null) {
      return null;
    }
    switch (textDecorationStyle) {
      case 'solid':
        return TextDecorationStyle.solid;
      case 'dashed':
        return TextDecorationStyle.dashed;
      case 'dotted':
        return TextDecorationStyle.dotted;
      case 'double':
        return TextDecorationStyle.double;
      case 'wavy':
        return TextDecorationStyle.wavy;
    }
    throw UnsupportedError(
        'Attribute value for text-decoration-style="$textDecorationStyle"'
        ' is not supported');
  }

  /// Parses a `text-anchor` attribute.
  double? parseTextAnchor(String? raw) {
    switch (raw) {
      case 'end':
        return 1;
      case 'middle':
        return .5;
      case 'start':
        return 0;
      case 'inherit':
      default:
        return null;
    }
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
  _Viewport _parseViewBox() {
    final String viewBox = attribute('viewBox') ?? '';
    final String rawWidth = attribute('width') ?? '';
    final String rawHeight = attribute('height') ?? '';

    if (viewBox == '' && rawWidth == '' && rawHeight == '') {
      throw StateError('SVG did not specify dimensions\n\n'
          'The SVG library looks for a `viewBox` or `width` and `height` attribute '
          'to determine the viewport boundary of the SVG.  Note that these attributes, '
          'as with all SVG attributes, are case sensitive.\n'
          'During processing, the following attributes were found:\n'
          '  ${_currentAttributes.raw}');
    }

    if (viewBox == '') {
      final double width = _parseRawWidthHeight(rawWidth);
      final double height = _parseRawWidthHeight(rawHeight);
      return _Viewport(
        width,
        height,
        AffineMatrix.identity,
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

    return _Viewport(
      width,
      height,
      AffineMatrix.identity.translated(translateX, translateY),
    );
  }

  /// Builds an IRI in the form of `'url(#id)'`.
  String buildUrlIri() => 'url(#${_currentAttributes.id})';

  /// An empty IRI.
  static const String emptyUrlIri = _Resolver.emptyUrlIri;

  /// Parses a `spreadMethod` attribute into a [TileMode].
  TileMode? parseTileMode() {
    final String? spreadMethod = attribute('spreadMethod');
    switch (spreadMethod) {
      case 'pad':
        return TileMode.clamp;
      case 'repeat':
        return TileMode.repeated;
      case 'reflect':
        return TileMode.mirror;
    }
    return null;
  }

  /// Parses the `@gradientUnits` attribute.
  GradientUnitMode? parseGradientUnitMode() {
    final String? gradientUnits = attribute('gradientUnits');
    switch (gradientUnits) {
      case 'userSpaceOnUse':
        return GradientUnitMode.userSpaceOnUse;
      case 'objectBoundingBox':
        return GradientUnitMode.objectBoundingBox;
    }
    return null;
  }

  StrokeCap? _parseCap(
    String? raw,
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
        return definitionPaint?.cap;
    }
  }

  StrokeJoin? _parseJoin(
    String? raw,
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
        return definitionPaint?.join;
    }
  }

  List<double>? _parseDashArray(String? rawDashArray) {
    if (rawDashArray == null || rawDashArray == '') {
      return null;
    } else if (rawDashArray == 'none') {
      return const <double>[];
    }

    final List<String> parts = rawDashArray.split(RegExp(r'[ ,]+'));
    final List<double> doubles = <double>[];
    bool atLeastOneNonZeroDash = false;
    for (final String part in parts) {
      final double dashOffset = parseDoubleWithUnits(part)!;
      if (dashOffset != 0) {
        atLeastOneNonZeroDash = true;
      }
      doubles.add(dashOffset);
    }
    if (doubles.isEmpty || !atLeastOneNonZeroDash) {
      return null;
    }
    return doubles;
  }

  double? _parseDashOffset(String? rawDashOffset) {
    return parseDoubleWithUnits(rawDashOffset);
  }

  /// Applies a transform to a path if the [attributes] contain a `transform`.
  Path applyTransformIfNeeded(Path path, AffineMatrix? parentTransform) {
    final AffineMatrix? transform = parseTransform(attribute('transform'));

    if (transform != null) {
      return path.transformed(transform);
    } else {
      return path;
    }
  }

  /// Parses a `clipPath` element into a list of [Path]s.
  List<Path> parseClipPath() {
    final String? id = _currentAttributes.clipPathId;
    if (id != null) {
      return _definitions.getClipPath(id);
    }

    return <Path>[];
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
    final String? rawMaskAttribute = attribute('mask');
    if (rawMaskAttribute != null) {
      return _definitions.getDrawable(rawMaskAttribute);
    }

    return null;
  }

  /// Lookup the pattern if the attribute is present.
  Node? parsePattern() {
    final String? rawPattern = attribute('fill');
    if (rawPattern != null) {
      return _definitions.getDrawable(rawPattern);
    }
    return null;
  }

  /// Parse the raw font weight string.
  FontWeight? parseFontWeight(String? fontWeight) {
    if (fontWeight == null) {
      return null;
    }

    switch (fontWeight) {
      case 'normal':
        return normalFontWeight;
      case 'bold':
        return boldFontWeight;
      case '100':
        return FontWeight.w100;
      case '200':
        return FontWeight.w200;
      case '300':
        return FontWeight.w300;
      case '400':
        return FontWeight.w400;
      case '500':
        return FontWeight.w500;
      case '600':
        return FontWeight.w600;
      case '700':
        return FontWeight.w700;
      case '800':
        return FontWeight.w800;
      case '900':
        return FontWeight.w900;
    }

    throw StateError('Invalid "font-weight": $fontWeight');
  }

  /// Converts a SVG Color String (either a # prefixed color string or a named color) to a [Color].
  Color? parseColor(
    String? colorString, {
    Color? currentColor,
    required String attributeName,
    required String? id,
  }) {
    final Color? parsed = _parseColor(colorString, currentColor: currentColor);
    if (parsed == null || _colorMapper == null) {
      return parsed;
    }
    // Do not use _currentAttributes, since they may not be up to date when this
    // is called.
    return _colorMapper.substitute(
      id,
      _currentStartElement!.localName,
      attributeName,
      parsed,
    );
  }

  Color? _parseColor(String? colorString, {Color? currentColor}) {
    if (colorString == null || colorString.isEmpty) {
      return null;
    }

    if (colorString == 'none') {
      return null;
    }

    if (colorString.toLowerCase() == 'currentcolor') {
      return currentColor ?? theme.currentColor;
    }

    // handle hex colors e.g. #fff or #ffffff.  This supports #RRGGBBAA
    if (colorString[0] == '#') {
      if (colorString.length == 4) {
        final String r = colorString[1];
        final String g = colorString[2];
        final String b = colorString[3];
        colorString = '#$r$r$g$g$b$b';
      }

      if (colorString.length == 7 || colorString.length == 9) {
        final int color = int.parse(colorString.substring(1, 7), radix: 16);
        final int alpha = colorString.length == 9
            ? int.parse(colorString.substring(7, 9), radix: 16)
            : 255;
        return Color(color | alpha << 24);
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

    // This is an error, but browsers are permissive here, so we can be too.
    // See for example https://github.com/dnfield/flutter_svg/issues/764 - a
    // user may be working with a network based SVG that uses the string "null"
    // which is not part of the specification.
    return null;
  }

  Map<String, String> _createAttributeMap(List<XmlEventAttribute> attributes) {
    final Map<String, String> attributeMap = <String, String>{};

    for (final XmlEventAttribute attribute in attributes) {
      final String value = attribute.value.trim();
      if (attribute.localName == 'style') {
        for (final String style in value.split(';')) {
          if (style.isEmpty) {
            continue;
          }
          final List<String> styleParts = style.split(':');
          final String attributeValue = styleParts[1].trim();
          if (attributeValue == 'inherit') {
            continue;
          }
          attributeMap[styleParts[0].trim()] = attributeValue;
        }
      } else if (value != 'inherit') {
        attributeMap[attribute.localName] = value;
      }
    }
    return attributeMap;
  }

  SvgStrokeAttributes? _parseStrokeAttributes(
    Map<String, String> attributeMap,
    double? uniformOpacity,
    Color? currentColor,
    String? id,
  ) {
    final String? rawStroke = attributeMap['stroke'];

    final String? rawStrokeOpacity = attributeMap['stroke-opacity'];
    double? opacity;
    if (rawStrokeOpacity != null) {
      opacity = parseDouble(rawStrokeOpacity)!.clamp(0.0, 1.0);
    }
    if (uniformOpacity != null) {
      if (opacity == null) {
        opacity = uniformOpacity;
      } else {
        opacity *= uniformOpacity;
      }
    }

    final String? rawStrokeCap = attributeMap['stroke-linecap'];
    final String? rawLineJoin = attributeMap['stroke-linejoin'];
    final String? rawMiterLimit = attributeMap['stroke-miterlimit'];
    final String? rawStrokeWidth = attributeMap['stroke-width'];
    final String? rawStrokeDashArray = attributeMap['stroke-dasharray'];
    final String? rawStrokeDashOffset = attributeMap['stroke-dashoffset'];

    final String? anyStrokeAttribute = rawStroke ??
        rawStrokeCap ??
        rawLineJoin ??
        rawMiterLimit ??
        rawStrokeWidth ??
        rawStrokeDashArray ??
        rawStrokeDashOffset;

    if (anyStrokeAttribute == null) {
      return null;
    }

    Color? strokeColor;
    String? shaderId;
    bool? hasPattern;
    if (rawStroke?.startsWith('url') ?? false) {
      shaderId = rawStroke;
      strokeColor = const Color(0xFFFFFFFF);
      if (patternIds.contains(rawStroke)) {
        hasPattern = true;
      }
    } else {
      strokeColor = parseColor(rawStroke, attributeName: 'stroke', id: id);
    }

    final Color? color = strokeColor;

    return SvgStrokeAttributes._(
      _definitions,
      shaderId: shaderId,
      color: rawStroke == 'none'
          ? const ColorOrNone.none()
          : ColorOrNone.color(color),
      cap: _parseCap(rawStrokeCap, null),
      join: _parseJoin(rawLineJoin, null),
      miterLimit: parseDouble(rawMiterLimit),
      width: parseDoubleWithUnits(rawStrokeWidth, tryParse: true),
      dashArray: _parseDashArray(rawStrokeDashArray),
      dashOffset: _parseDashOffset(rawStrokeDashOffset),
      hasPattern: hasPattern,
      opacity: opacity,
    );
  }

  SvgFillAttributes? _parseFillAttributes(
    Map<String, String> attributeMap,
    double? uniformOpacity,
    Color? currentColor,
    String? id,
  ) {
    final String rawFill = attributeMap['fill'] ?? '';

    final String? rawFillOpacity = attributeMap['fill-opacity'];
    double? opacity;
    if (rawFillOpacity != null) {
      opacity = parseDouble(rawFillOpacity)!.clamp(0.0, 1.0);
    }
    if (uniformOpacity != null) {
      if (opacity == null) {
        opacity = uniformOpacity;
      } else {
        opacity *= uniformOpacity;
      }
    }
    bool? hasPattern;
    if (rawFill.startsWith('url')) {
      if (patternIds.contains(rawFill)) {
        hasPattern = true;
      }
      return SvgFillAttributes._(
        _definitions,
        color: const ColorOrNone.color(Color(0xFFFFFFFF)),
        shaderId: rawFill,
        hasPattern: hasPattern,
        opacity: opacity,
      );
    }

    Color? fillColor = parseColor(rawFill, attributeName: 'fill', id: id);

    if ((fillColor?.a ?? 255) != 255) {
      opacity = fillColor!.a / 255;
      fillColor = fillColor.withOpacity(1);
    }

    return SvgFillAttributes._(
      _definitions,
      color: rawFill == 'none'
          ? const ColorOrNone.none()
          : ColorOrNone.color(fillColor),
      opacity: opacity,
    );
  }

  bool _isVisible(Map<String, String> attributeMap) {
    return attributeMap['display'] != 'none' &&
        attributeMap['visibility'] != 'hidden';
  }

  SvgAttributes _createSvgAttributes(
    Map<String, String> attributeMap, {
    Color? currentColor,
  }) {
    final String? id = attributeMap['id'];
    final double? opacity =
        parseDouble(attributeMap['opacity'])?.clamp(0.0, 1.0);
    final Color? color =
        parseColor(attributeMap['color'], attributeName: 'color', id: id) ??
            currentColor;

    final String? rawX = attributeMap['x'];
    final String? rawY = attributeMap['y'];

    final String? rawDx = attributeMap['dx'];
    final String? rawDy = attributeMap['dy'];

    return SvgAttributes._(
        raw: attributeMap,
        id: id,
        x: DoubleOrPercentage.fromString(rawX),
        y: DoubleOrPercentage.fromString(rawY),
        dx: DoubleOrPercentage.fromString(rawDx),
        dy: DoubleOrPercentage.fromString(rawDy),
        href: attributeMap['href'],
        color: attributeMap['color']?.toLowerCase() == 'none'
            ? const ColorOrNone.none()
            : ColorOrNone.color(color),
        stroke: _parseStrokeAttributes(
          attributeMap,
          opacity,
          color,
          id,
        ),
        fill: _parseFillAttributes(
          attributeMap,
          opacity,
          color,
          id,
        ),
        fillRule: parseRawFillRule(attributeMap['fill-rule']),
        clipRule: parseRawFillRule(attributeMap['clip-rule']),
        clipPathId: attributeMap['clip-path'],
        blendMode: _blendModes[attributeMap['mix-blend-mode']],
        transform:
            parseTransform(attributeMap['transform']) ?? AffineMatrix.identity,
        fontFamily: attributeMap['font-family'],
        fontWeight: parseFontWeight(attributeMap['font-weight']),
        fontSize: parseFontSize(attributeMap['font-size']),
        textDecoration: parseTextDecoration(attributeMap['text-decoration']),
        textDecorationStyle:
            parseTextDecorationStyle(attributeMap['text-decoration-style']),
        textDecorationColor: parseColor(attributeMap['text-decoration-color'],
            attributeName: 'text-decoration-color', id: id),
        textAnchorMultiplier: parseTextAnchor(attributeMap['text-anchor']));
  }
}

/// A resolver is used by the parser and node tree to handle forward/backwards
/// references with identifiers.
class _Resolver {
  /// A default empty identifier.
  static const String emptyUrlIri = 'url(#)';
  final Map<String, AttributedNode> _drawables = <String, AttributedNode>{};
  final Map<String, Gradient> _shaders = <String, Gradient>{};
  final Map<String, List<Node>> _clips = <String, List<Node>>{};

  bool _sealed = false;

  void _seal() {
    assert(_deferredShaders.isEmpty);
    _sealed = true;
  }

  /// Retrieve the drawable defined by [ref].
  AttributedNode? getDrawable(String ref) {
    assert(_sealed);
    return _drawables[ref];
  }

  /// Retrieve the clip defined by [ref], or `null` if it is undefined.
  List<Path> getClipPath(String ref) {
    assert(_sealed);
    final List<Node>? nodes = _clips[ref];
    if (nodes == null) {
      return <Path>[];
    }

    final List<PathBuilder> pathBuilders = <PathBuilder>[];
    PathBuilder? currentPath;
    void extractPathsFromNode(Node? target) {
      if (target is PathNode) {
        final PathBuilder nextPath = PathBuilder.fromPath(target.path);
        nextPath.fillType = target.attributes.clipRule ?? PathFillType.nonZero;
        if (currentPath != null && nextPath.fillType != currentPath!.fillType) {
          currentPath = nextPath;
          pathBuilders.add(currentPath!);
        } else if (currentPath == null) {
          currentPath = nextPath;
          pathBuilders.add(currentPath!);
        } else {
          currentPath!.addPath(nextPath.toPath(reset: false));
        }
      } else if (target is DeferredNode) {
        extractPathsFromNode(target.resolver(target.refId));
      } else if (target is ParentNode) {
        target.visitChildren(extractPathsFromNode);
      }
    }

    nodes.forEach(extractPathsFromNode);

    return pathBuilders
        .map((PathBuilder builder) => builder.toPath())
        .toList(growable: false);
  }

  /// Get the pattern id if one exists.
  String? getPattern(SvgParser parserState) {
    if (parserState.attribute('fill') != null) {
      final String? fill = parserState.attribute('fill');
      if (fill!.startsWith('url') && parserState.patternIds.contains(fill)) {
        return fill;
      }
    }

    if (parserState.attribute('stroke') != null) {
      final String? stroke = parserState.attribute('stroke');
      if (stroke!.startsWith('url') &&
          parserState.patternIds.contains(stroke)) {
        return stroke;
      }
    }
    return null;
  }

  /// Retrieve the [Gradeint] defined by [ref].
  T? getGradient<T extends Gradient>(String ref) {
    assert(_sealed);
    return _shaders[ref] as T?;
  }

  final Map<String, List<Gradient>> _deferredShaders =
      <String, List<Gradient>>{};

  /// Add a deferred [gradient] to the resolver, identified by [href].
  void addDeferredGradient(String ref, Gradient gradient) {
    assert(!_sealed);
    _deferredShaders.putIfAbsent(ref, () => <Gradient>[]).add(gradient);
  }

  /// Add the [gradient] to the resolver, identified by [href].
  void addGradient(
    Gradient gradient,
    String? href,
  ) {
    assert(!_sealed);
    if (_shaders.containsKey(gradient.id)) {
      return;
    }
    _shaders[gradient.id] = gradient;
    if (href != null) {
      href = 'url($href)';
      final Gradient? gradientRef = _shaders[href];
      if (gradientRef != null) {
        // Gradient is defined after its reference.
        _shaders[gradient.id] = gradient.applyProperties(gradientRef);
      } else {
        // Gradient is defined before its reference, check later when that
        // reference has been parsed.
        addDeferredGradient(href, gradient);
      }
    } else {
      for (final Gradient deferred
          in _deferredShaders.remove(gradient.id) ?? <Gradient>[]) {
        _shaders[deferred.id] = deferred.applyProperties(gradient);
      }
    }
  }

  /// Add the clip defined by [pathNodes] to the resolver identifier by [ref].
  void addClipPath(String ref, List<Node> pathNodes) {
    assert(!_sealed);
    _clips.putIfAbsent(ref, () => pathNodes);
  }

  /// Add the [drawable] to the resolver identifier by [ref].
  void addDrawable(String ref, AttributedNode drawable) {
    assert(!_sealed);
    _drawables.putIfAbsent(ref, () => drawable);
  }
}

class _Viewport {
  const _Viewport(this.width, this.height, this.transform);

  final double width;
  final double height;
  final AffineMatrix transform;
}

/// A collection of attributes for an SVG element.
class SvgAttributes {
  /// Create a new [SvgAttributes] from the given properties.
  const SvgAttributes._({
    required this.raw,
    this.id,
    this.href,
    this.transform = AffineMatrix.identity,
    this.color = const ColorOrNone.color(),
    this.stroke,
    this.fill,
    this.fillRule,
    this.clipRule,
    this.clipPathId,
    this.blendMode,
    this.fontFamily,
    this.fontWeight,
    this.fontSize,
    this.textDecoration,
    this.textDecorationStyle,
    this.textDecorationColor,
    this.x,
    this.dx,
    this.textAnchorMultiplier,
    this.y,
    this.dy,
    this.width,
    this.height,
  });

  /// For use in tests to construct arbitrary attributes.
  @visibleForTesting
  const SvgAttributes.forTest({
    this.raw = const <String, String>{},
    this.id,
    this.href,
    this.transform = AffineMatrix.identity,
    this.color = const ColorOrNone.color(),
    this.stroke,
    this.fill,
    this.fillRule,
    this.clipRule,
    this.clipPathId,
    this.blendMode,
    this.fontFamily,
    this.fontWeight,
    this.fontSize,
    this.textDecoration,
    this.textDecorationStyle,
    this.textDecorationColor,
    this.x,
    this.dx,
    this.textAnchorMultiplier,
    this.y,
    this.dy,
    this.width,
    this.height,
  });

  /// The empty set of properties.
  static const SvgAttributes empty = SvgAttributes._(raw: <String, String>{});

  /// The raw attribute map.
  final Map<String, String> raw;

  /// Whether either the stroke or fill on this object has opacity.
  bool get hasOpacity => (fill?.opacity ?? stroke?.opacity) != null;

  /// Generated from https://www.w3.org/TR/SVG11/single-page.html
  ///
  /// Using this:
  /// ```javascript
  /// let set = '<String>{';
  /// document.querySelectorAll('.propdef')
  ///   .forEach((propdef) => {
  ///     const nameNode = propdef.querySelector('.propdef-title.prop-name');
  ///     if (!nameNode) {
  ///       return;
  ///     }
  ///     const inherited = propdef.querySelector('tbody tr:nth-child(4) td:nth-child(2)').innerText.startsWith('yes');
  ///     if (inherited) {
  ///       set += `'${nameNode.innerText.replaceAll(/[‘’]/g, '')}',`;
  ///     }
  ///   });
  /// set += '};';
  /// console.log(set);
  /// ```
  static const Set<String> _heritableProps = <String>{
    'writing-mode',
    'glyph-orientation-vertical',
    'glyph-orientation-horizontal',
    'direction',
    'text-anchor',
    'font-family',
    'font-style',
    'font-variant',
    'font-weight',
    'font-stretch',
    'font-size',
    'font-size-adjust',
    'font',
    'kerning',
    'letter-spacing',
    'word-spacing',
    'fill',
    'fill-rule',
    'fill-opacity',
    'stroke',
    'stroke-width',
    'stroke-linecap',
    'stroke-linejoin',
    'stroke-miterlimit',
    'stroke-dasharray',
    'stroke-dashoffset',
    'stroke-opacity',
    'visibility',
    'marker-start',
    'marker',
    'color-interpolation',
    'color-interpolation-filters',
    'color-rendering',
    'shape-rendering',
    'text-rendering',
    'image-rendering',
    'color',
    'color-profile',
    'clip-rule',
    'pointer-events',
    'cursor',
  };

  /// The properties in [raw] that are heritable per the SVG 1.1 specification.
  Iterable<MapEntry<String, String>> get heritable {
    return raw.entries.where((MapEntry<String, String> entry) {
      return _heritableProps.contains(entry.key);
    });
  }

  /// The `@id` attribute.
  final String? id;

  /// The `@href` attribute.
  final String? href;

  /// The `@color` attribute, which provides an indirect current color.
  ///
  /// Does _not_ include the opacity value, which is specified on the [fill] or
  /// [stroke].
  ///
  /// https://www.w3.org/TR/SVG11/color.html#ColorProperty
  final ColorOrNone color;

  /// The stroking properties of this element.
  final SvgStrokeAttributes? stroke;

  /// The filling properties of this element.
  final SvgFillAttributes? fill;

  /// The `@transform` attribute.
  final AffineMatrix transform;

  /// The `@fill-rule` attribute.
  final PathFillType? fillRule;

  /// The `@clip-rule` attribute.
  final PathFillType? clipRule;

  /// The raw identifier for clip path(s) to apply.
  final String? clipPathId;

  /// The `mix-blend-mode` attribute.
  final BlendMode? blendMode;

  /// The `font-family` attribute, as a string.
  final String? fontFamily;

  /// The font weight attribute.
  final FontWeight? fontWeight;

  /// The `font-size` attribute.
  final double? fontSize;

  /// The `text-decoration` attribute.
  final TextDecoration? textDecoration;

  /// The `text-decoration-style` attribute.
  final TextDecorationStyle? textDecorationStyle;

  /// The `text-decoration-color` attribute.
  final Color? textDecorationColor;

  /// The `width` attribute.
  final double? width;

  /// The `height` attribute.
  final double? height;

  /// The x translation.
  final DoubleOrPercentage? x;

  /// A multiplier for text-anchoring.
  final double? textAnchorMultiplier;

  /// The y translation.
  final DoubleOrPercentage? y;

  /// The relative x translation.
  final DoubleOrPercentage? dx;

  /// The relative y translation.
  final DoubleOrPercentage? dy;

  /// A copy of these attributes after absorbing a saveLayer.
  ///
  /// Specifically, this will null out `blendMode` and any opacity related
  /// attributes, since those have been applied in a saveLayer call.
  ///
  /// The [raw] map preserves old values.
  SvgAttributes forSaveLayer() {
    return SvgAttributes._(
      raw: raw,
      id: id,
      href: href,
      transform: transform,
      color: color,
      stroke: stroke?.forSaveLayer(),
      fill: fill?.forSaveLayer(),
      fillRule: fillRule,
      clipRule: clipRule,
      clipPathId: clipPathId,
      blendMode: blendMode,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      textDecoration: textDecoration,
      textDecorationStyle: textDecorationStyle,
      textDecorationColor: textDecorationColor,
      x: x,
      textAnchorMultiplier: textAnchorMultiplier,
      y: y,
      width: width,
      height: height,
    );
  }

  /// Creates a new set of attributes as if this inherited from `parent`.
  ///
  /// If `includePosition` is true, the `x`/`y` coordinates are also inherited. This
  /// is intended to be used by text parsing. Defaults to `false`.
  SvgAttributes applyParent(
    SvgAttributes parent, {
    bool includePosition = false,
    AffineMatrix? transformOverride,
    String? hrefOverride,
  }) {
    final Map<String, String> newRaw = <String, String>{
      ...Map<String, String>.fromEntries(parent.heritable),
      if (includePosition && parent.raw.containsKey('x')) 'x': parent.raw['x']!,
      if (includePosition && parent.raw.containsKey('y')) 'y': parent.raw['y']!,
      ...raw,
    };

    return SvgAttributes._(
      raw: newRaw,
      id: newRaw['id'],
      href: newRaw['href'],
      transform: transformOverride ?? transform,
      color: color._applyParent(parent.color),
      stroke: stroke?.applyParent(parent.stroke) ?? parent.stroke,
      fill: fill?.applyParent(parent.fill) ?? parent.fill,
      fillRule: fillRule ?? parent.fillRule,
      clipRule: clipRule ?? parent.clipRule,
      clipPathId: clipPathId ?? parent.clipPathId,
      blendMode: blendMode ?? parent.blendMode,
      fontFamily: fontFamily ?? parent.fontFamily,
      fontWeight: fontWeight ?? parent.fontWeight,
      fontSize: fontSize ?? parent.fontSize,
      textDecoration: textDecoration ?? parent.textDecoration,
      textDecorationStyle: textDecorationStyle ?? parent.textDecorationStyle,
      textDecorationColor: textDecorationColor ?? parent.textDecorationColor,
      textAnchorMultiplier: textAnchorMultiplier ?? parent.textAnchorMultiplier,
      height: height ?? parent.height,
      width: width ?? parent.width,
      x: x,
      y: y,
      dx: dx,
      dy: dy,
    );
  }
}

/// A value that represents either an absolute pixel coordinate or a percentage
/// of a bounding dimension.
@immutable
class DoubleOrPercentage {
  const DoubleOrPercentage._(this._value, this._isPercentage);

  /// Constructs a [DoubleOrPercentage] from a raw SVG attribute string.
  static DoubleOrPercentage? fromString(String? raw) {
    if (raw == null || raw == '') {
      return null;
    }

    if (isPercentage(raw)) {
      return DoubleOrPercentage._(parsePercentage(raw), true);
    }
    return DoubleOrPercentage._(parseDouble(raw)!, false);
  }

  final double _value;
  final bool _isPercentage;

  /// Calculates the result of applying this dimension within [bound].
  ///
  /// If this is a percentage, it will return a percentage of bound. Otherwise,
  /// it returns the value of this.
  double calculate(double bound) {
    if (_isPercentage) {
      return _value * bound;
    }
    return _value;
  }

  @override
  int get hashCode => Object.hash(_value, _isPercentage);

  @override
  bool operator ==(Object other) {
    return other is DoubleOrPercentage &&
        other._isPercentage == _isPercentage &&
        other._value == _value;
  }
}

/// SVG attributes specific to stroking.
class SvgStrokeAttributes {
  const SvgStrokeAttributes._(
    this._definitions, {
    this.color = const ColorOrNone.color(),
    this.shaderId,
    this.join,
    this.cap,
    this.miterLimit,
    this.width,
    this.dashArray,
    this.dashOffset,
    this.hasPattern,
    this.opacity,
  });

  final _Resolver? _definitions;

  /// The color to use for stroking. Does _not_ include the [opacity] value. Only
  /// opacity is used if the [shaderId] is not null.
  final ColorOrNone color;

  /// The literal reference to a shader defined elsewhere.
  final String? shaderId;

  /// The join style to use for the stroke.
  final StrokeJoin? join;

  /// The cap style to use for the stroke.
  final StrokeCap? cap;

  /// The miter limit to use if the [join] is [StrokeJoin.miter].
  final double? miterLimit;

  /// The width of the stroke.
  final double? width;

  /// The dashing array to use if the path is dashed.
  final List<double>? dashArray;

  /// The offset for [dashArray], if any.
  final double? dashOffset;

  /// Indicates whether or not a pattern is used for stroke.
  final bool? hasPattern;

  /// The opacity to apply to a default color, if [color] is null.
  final double? opacity;

  /// A copy of these attributes after absorbing a saveLayer.
  ///
  /// Specifically, this will null out any opacity related
  /// attributes, since those have been applied in a saveLayer call.
  SvgStrokeAttributes forSaveLayer() {
    return SvgStrokeAttributes._(
      _definitions,
      color: color,
      shaderId: shaderId,
      join: join,
      cap: cap,
      miterLimit: miterLimit,
      width: width,
      dashArray: dashArray,
      dashOffset: dashOffset,
      hasPattern: hasPattern,
    );
  }

  /// Inherits attributes in this from parent.
  SvgStrokeAttributes applyParent(SvgStrokeAttributes? parent) {
    return SvgStrokeAttributes._(
      _definitions,
      color: color._applyParent(parent?.color),
      shaderId: shaderId ?? parent?.shaderId,
      join: join ?? parent?.join,
      cap: cap ?? parent?.cap,
      miterLimit: miterLimit ?? parent?.miterLimit,
      width: width ?? parent?.width,
      dashArray: dashArray ?? parent?.dashArray,
      dashOffset: dashOffset ?? parent?.dashOffset,
      hasPattern: hasPattern ?? parent?.hasPattern,
      opacity: opacity ?? parent?.opacity,
    );
  }

  /// Creates a stroking paint object from this set of attributes, using the
  /// bounds and transform specified for shader computation.
  ///
  /// Returns null if this is [none].
  Stroke? toStroke(Rect shaderBounds, AffineMatrix transform) {
    // A zero width stroke is a hairline in Flutter, but a nop in SVG.
    if (color.isNone ||
        (color.color == null && hasPattern == null && shaderId == null ||
            width == 0)) {
      return null;
    }

    if (hasPattern ?? false) {
      return Stroke(
        join: join,
        cap: cap,
        miterLimit: miterLimit,
        width: width,
      );
    }

    if (_definitions == null) {
      return null;
    }

    Gradient? shader;
    if (shaderId != null) {
      shader = _definitions
          .getGradient<Gradient>(shaderId!)
          ?.applyBounds(shaderBounds, transform);
      if (shader == null) {
        return null;
      }
    }

    return Stroke(
      color: opacity == null ? color.color : color.color!.withOpacity(opacity!),
      shader: shader,
      join: join,
      cap: cap,
      miterLimit: miterLimit,
      width: transform.scaleStrokeWidth(width),
    );
  }
}

/// SVG attributes specific to filling.
class SvgFillAttributes {
  /// Create a new [SvgFillAttributes];
  const SvgFillAttributes._(
    this._definitions, {
    this.color = const ColorOrNone.color(),
    this.shaderId,
    this.hasPattern,
    this.opacity,
  });

  final _Resolver? _definitions;

  /// The color to use for filling. Does _not_ include the [opacity] value. Only
  /// opacity is used if the [shaderId] is not null.
  final ColorOrNone color;

  /// The opacity to apply to a default color, if [color] is null.
  final double? opacity;

  /// The literal reference to a shader defined elsewhere.
  final String? shaderId;

  /// If there is a pattern a default fill will be returned.
  final bool? hasPattern;

  /// A copy of these attributes after absorbing a saveLayer.
  ///
  /// Specifically, this will null out any opacity related
  /// attributes, since those have been applied in a saveLayer call.
  SvgFillAttributes forSaveLayer() {
    return SvgFillAttributes._(
      _definitions,
      color: color,
      shaderId: shaderId,
      hasPattern: hasPattern,
    );
  }

  /// Inherits attributes in this from parent.
  SvgFillAttributes applyParent(SvgFillAttributes? parent) {
    return SvgFillAttributes._(
      _definitions,
      color: color._applyParent(parent?.color),
      shaderId: shaderId ?? parent?.shaderId,
      hasPattern: hasPattern ?? parent?.hasPattern,
      opacity: opacity ?? parent?.opacity,
    );
  }

  /// Creates a [Fill] from this information with appropriate transforms and
  /// bounds for shaders.
  ///
  /// Returns null if this is [none].
  Fill? toFill(
    Rect shaderBounds,
    AffineMatrix transform, {
    Color? defaultColor,
  }) {
    if (color.isNone) {
      return null;
    }
    final Color? resolvedColor = color.color?.withOpacity(opacity ?? 1.0) ??
        defaultColor?.withOpacity(opacity ?? 1.0);
    if (resolvedColor == null) {
      return null;
    }
    if (hasPattern ?? false) {
      return Fill(color: resolvedColor);
    }

    if (_definitions == null) {
      return null;
    }
    Gradient? shader;
    if (shaderId != null) {
      shader = _definitions
          .getGradient<Gradient>(shaderId!)
          ?.applyBounds(shaderBounds, transform);
      if (shader == null) {
        return null;
      }
    }

    return Fill(color: resolvedColor, shader: shader);
  }

  @override
  String toString() {
    return 'SvgFillAttributes('
        'definitions: $_definitions, '
        'color: $color, '
        'shaderId: $shaderId, '
        'hasPattern: $hasPattern, '
        'oapctiy: $opacity)';
  }
}

/// Represents a color for filling or stroking.
///
/// If the [color] is not null, [isNone] is false.
///
/// If the [color] is null and [isNone] is false, color should be inherited from
/// the parent or defaulted as per the SVG specification.
///
/// If the [color] is null and [isNone] is true, inheritence should be cleared
/// and no painting should happen.
class ColorOrNone {
  /// See [ColorOrNone].
  const ColorOrNone.none()
      : isNone = true,
        color = null;

  /// See [ColorOrNone].
  const ColorOrNone.color([this.color]) : isNone = false;

  /// Whether to paint anything.
  final bool isNone;

  /// The color to use when painting. If null and [isNone] is false, inherit
  /// from parent.
  final Color? color;

  ColorOrNone _applyParent(ColorOrNone? parent) {
    if (parent == null || isNone) {
      return this;
    }

    if (parent.isNone && color == null) {
      return const ColorOrNone.none();
    }

    return ColorOrNone.color(color ?? parent.color);
  }

  @override
  String toString() => isNone ? '"none"' : (color?.toString() ?? 'null');
}
