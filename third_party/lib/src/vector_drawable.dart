import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart' hide TextStyle;
import 'package:meta/meta.dart';
import 'package:path_drawing/path_drawing.dart';

import 'render_picture.dart' as render_picture;

typedef Paint PaintServer(Rect bounds);

/// Base interface for vector drawing.
@immutable
abstract class Drawable {
  /// Whether this [Drawable] would be visible if [draw]n.
  bool get hasDrawableContent;

  /// Draws the contents or children of this [Drawable] to the `canvas`, using
  /// the `parentPaint` to optionally override the child's paint.
  void draw(Canvas canvas, ColorFilter colorFilter);
}

/// Styling information for vector drawing.
///
/// Contains [Paint], [Path], dashing, transform, and text styling information.
@immutable
class DrawableStyle {
  /// This should be used where 'stroke' or 'fill' are 'none'.
  ///
  /// This will not result in a drawing operation, but will clear out
  /// inheritance. Modifying this paint should not result in any changes to
  /// the image, but it should not be modified.
  static final Paint emptyPaint = new Paint()..color = const Color(0x00000000);

  /// Used where 'dasharray' is 'none'
  ///
  /// This will not result in a drawing operation, but will clear out
  /// inheritence.
  static final CircularIntervalList<double> emptyDashArray =
      new CircularIntervalList<double>(const <double>[]);

  /// If not `null` and not `identical` with [emptyPaint], will result in a stroke
  /// for the rendered [DrawableShape]. Drawn __after__ the [fill].
  final Paint stroke;

  /// The dashing array to use for the [stroke], if any.
  final CircularIntervalList<double> dashArray;

  /// The [DashOffset] to use for where to begin the [dashArray].
  final DashOffset dashOffset;

  /// If not `null` and not `identical` with [emptyPaint], will result in a fill
  /// for the rendered [DrawableShape].  Drawn __before__ the [stroke].
  final Paint fill;

  /// The 4x4 matrix ([Matrix4]) for a transform, if any.
  final Float64List transform;

  final DrawableTextStyle textStyle;

  /// The fill rule to use for this path.
  final PathFillType pathFillType;

  /// The clip to apply, if any.
  final List<Path> clipPath;

  /// Controls inheriting opacity.  Will be averaged with child opacity.
  final double groupOpacity;

  const DrawableStyle(
      {this.stroke,
      this.dashArray,
      this.dashOffset,
      this.fill,
      this.transform,
      this.textStyle,
      this.pathFillType,
      this.groupOpacity,
      this.clipPath});

  /// Creates a new [DrawableStyle] if `parent` is not null, filling in any null properties on
  /// this with the properties from other (except [groupOpacity], which is averaged).
  static DrawableStyle mergeAndBlend(DrawableStyle parent,
      {Paint fill,
      Paint stroke,
      CircularIntervalList<double> dashArray,
      DashOffset dashOffset,
      Float64List transform,
      DrawableTextStyle textStyle,
      PathFillType pathFillType,
      double groupOpacity,
      List<Path> clipPath}) {
    final DrawableStyle ret = new DrawableStyle(
      fill: fill ?? parent?.fill,
      stroke: stroke ?? parent?.stroke,
      dashArray: dashArray ?? parent?.dashArray,
      dashOffset: dashOffset ?? parent?.dashOffset,
      // transforms aren't inherited because they're applied to canvas with save/restore
      // that wraps any potential children
      transform: transform,
      textStyle: new DrawableTextStyle.merge(textStyle, parent?.textStyle),
      pathFillType: pathFillType ?? parent?.pathFillType,
      groupOpacity: mergeOpacity(groupOpacity, parent?.groupOpacity),
      // clips don't make sense to inherit - applied to canvas with save/restore
      // that wraps any potential children
      clipPath: clipPath,
    );

    if (ret.fill != null) {
      ret.fill.color = ret.fill.color.withOpacity(ret.fill.color.opacity == 1.0
          ? ret.groupOpacity ?? 1.0
          : mergeOpacity(ret.groupOpacity, ret.fill.color.opacity));
    }
    if (ret.stroke != null) {
      ret.stroke.color = ret.stroke.color.withOpacity(
          ret.stroke.color.opacity == 1.0
              ? ret.groupOpacity ?? 1.0
              : mergeOpacity(ret.groupOpacity, ret.stroke.color.opacity));
    }

    return ret;
  }

  /// Averages [back] and [front].  If either is null, returns the other.
  ///
  /// Result is null if both [back] and [front] are null.
  static double mergeOpacity(double back, double front) {
    if (back == null) {
      return front;
    } else if (front == null) {
      return back;
    }
    return (front + back) / 2.0;
  }

  @override
  String toString() {
    return 'DrawableStyle{$stroke,$dashArray,$dashOffset,$fill,$transform,$textStyle,$pathFillType,$groupOpacity,$clipPath}';
  }
}

class DrawableTextStyle {
  const DrawableTextStyle({
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.fontWeight,
    this.fontFamily,
    this.fontSize,
    this.fontStyle,
    this.foreground,
    this.background,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.locale,
    this.textBaseline,
  });

  factory DrawableTextStyle.merge(DrawableTextStyle a, DrawableTextStyle b) {
    if (b == null) {
      return a;
    }
    if (a == null) {
      return b;
    }
    return new DrawableTextStyle(
      decoration: a.decoration ?? b.decoration,
      decorationColor: a.decorationColor ?? b.decorationColor,
      decorationStyle: a.decorationStyle ?? b.decorationStyle,
      fontWeight: a.fontWeight ?? b.fontWeight,
      fontStyle: a.fontStyle ?? b.fontStyle,
      textBaseline: a.textBaseline ?? b.textBaseline,
      fontFamily: a.fontFamily ?? b.fontFamily,
      fontSize: a.fontSize ?? b.fontSize,
      letterSpacing: a.letterSpacing ?? b.letterSpacing,
      wordSpacing: a.wordSpacing ?? b.wordSpacing,
      height: a.height ?? b.height,
      locale: a.locale ?? b.locale,
      background: a.background ?? b.background,
      foreground: a.foreground ?? b.foreground,
    );
  }

  final TextDecoration decoration;
  final Color decorationColor;
  final TextDecorationStyle decorationStyle;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final TextBaseline textBaseline;
  final String fontFamily;
  final double fontSize;
  final double letterSpacing;
  final double wordSpacing;
  final double height;
  final Locale locale;
  final Paint background;
  final Paint foreground;

  TextStyle buildTextStyle({Paint foregroundOverride}) {
    return new TextStyle(
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      textBaseline: textBaseline,
      fontFamily: fontFamily,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      locale: locale,
      background: background,
      color: foregroundOverride?.color ??
          foreground?.color ??
          const Color(0xFF000000),
      // this will be supported in Flutter 0.5.6 or 0.5.7
      // foreground: foregroundOverride ?? foreground,
    );
  }

  @override
  String toString() {
    return 'DrawableTextStyle{$decoration,$decorationColor,$decorationStyle,$fontWeight,$fontFamily,$fontSize,$fontStyle,$foreground,$background,$letterSpacing,$wordSpacing,$height,$locale,$textBaseline}';
  }
}

enum DrawableTextAnchorPosition { start, middle, end }

// WIP.  This only handles very, very minimal use cases right now.
class DrawableText implements Drawable {
  final Offset offset;
  final DrawableTextAnchorPosition anchor;
  final Paragraph fill;
  final Paragraph stroke;

  DrawableText(this.fill, this.stroke, this.offset, this.anchor)
      : assert(fill != null || stroke != null);

  @override
  bool get hasDrawableContent =>
      (fill?.width ?? 0.0) + (stroke?.width ?? 0.0) > 0.0;

  @override
  void draw(Canvas canvas, ColorFilter colorFilter) {
    if (!hasDrawableContent) {
      return;
    }
    if (fill != null) {
      canvas.drawParagraph(fill, resolveOffset(fill, anchor, offset));
    }
    if (stroke != null) {
      canvas.drawParagraph(stroke, resolveOffset(stroke, anchor, offset));
    }
  }

  static Offset resolveOffset(
      Paragraph paragraph, DrawableTextAnchorPosition anchor, Offset offset) {
    assert(paragraph != null);
    assert(anchor != null);
    assert(offset != null);
    switch (anchor) {
      case DrawableTextAnchorPosition.middle:
        return new Offset(
            offset.dx - paragraph.minIntrinsicWidth / 2, offset.dy);
        break;
      case DrawableTextAnchorPosition.end:
        return new Offset(offset.dx - paragraph.minIntrinsicWidth, offset.dy);
        break;
      case DrawableTextAnchorPosition.start:
      default:
        return offset;
        break;
    }
  }
}

/// Contains reusable drawing elements that can be referenced by a String ID.
class DrawableDefinitionServer {
  final Map<String, PaintServer> _paintServers = <String, PaintServer>{};
  final Map<String, List<Path>> _clipPaths = <String, List<Path>>{};

  /// Attempt to lookup a pre-defined [Paint] by [id].
  ///
  /// [id] and [bounds] must not be null.
  Paint getPaint(String id, Rect bounds) {
    assert(id != null);
    assert(bounds != null);
    final PaintServer srv = _paintServers[id];

    return srv != null ? srv(bounds) : null;
  }

  void addPaintServer(String id, PaintServer server) {
    assert(id != null);
    _paintServers[id] = server;
  }

  List<Path> getClipPath(String id) {
    assert(id != null);
    return _clipPaths[id];
  }

  void addClipPath(String id, List<Path> paths) {
    assert(id != null);
    _clipPaths[id] = paths;
  }
}

/// The root element of a drawable.
class DrawableRoot implements Drawable {
  /// The expected coordinates used by child paths for drawing.
  final Rect viewBox;

  /// The actual child or group to draw.
  final List<Drawable> children;

  /// Contains reusable definitions such as gradients and clipPaths.
  final DrawableDefinitionServer definitions;
  // /// Contains [Paint]s that are used by multiple children, e.g.
  // /// gradient shaders that are referenced by an identifier.
  // final Map<String, PaintServer> paintServers;

  /// The [DrawableStyle] for inheritence.
  final DrawableStyle style;

  const DrawableRoot(this.viewBox, this.children, this.definitions, this.style);

  /// Scales the `canvas` so that the drawing units in this [Drawable]
  /// will scale to the `desiredSize`.
  ///
  /// If the `viewBox` dimensions are not 1:1 with `desiredSize`, will scale to
  /// the smaller dimension and translate to center the image along the larger
  /// dimension.
  void scaleCanvasToViewBox(Canvas canvas, Size desiredSize) {
    render_picture.scaleCanvasToViewBox(canvas, desiredSize, viewBox);
  }

  /// Clips the canvas to a rect corresponding to the `viewBox`.
  void clipCanvasToViewBox(Canvas canvas) {
    canvas.clipRect(viewBox.translate(viewBox.left, viewBox.top));
  }

  @override
  bool get hasDrawableContent =>
      children.isNotEmpty == true && viewBox != null && !viewBox.isEmpty;

  @override
  void draw(Canvas canvas, ColorFilter colorFilter) {
    if (!hasDrawableContent) {
      return;
    }
    for (Drawable child in children) {
      child.draw(canvas, colorFilter);
    }
  }

  static CircularIntervalList<BlendMode> bms =
      new CircularIntervalList<BlendMode>(BlendMode.values);

  /// Creates a [Picture] from this [DrawableRoot].
  ///
  /// Be cautious about not clipping to the ViewBox - you will be
  /// allowing your drawing to take more memory than it otherwise would,
  /// particularly when it is eventually rasterized.
  Picture toPicture(
      {Size size, bool clipToViewBox = true, ColorFilter colorFilter}) {
    if (viewBox == null || viewBox.size.width == 0) {
      return null;
    }

    final PictureRecorder recorder = new PictureRecorder();
    final Canvas canvas = new Canvas(recorder, viewBox);
    canvas.save();
    if (size != null) {
      scaleCanvasToViewBox(canvas, size);
    }
    if (clipToViewBox == true) {
      clipCanvasToViewBox(canvas);
    }

    draw(canvas, colorFilter);
    canvas.restore();
    return recorder.endRecording();
  }
}

/// Represents an element that is not rendered and has no chidlren, e.g.
/// a descriptive element.
// TODO: tie some of this into semantics/accessibility
class DrawableNoop implements Drawable {
  final String name;
  const DrawableNoop(this.name);

  @override
  bool get hasDrawableContent => false;

  @override
  void draw(Canvas canvas, ColorFilter colorFilter) {}
}

/// Represents a group of drawing elements that may share a common `transform`, `stroke`, or `fill`.
class DrawableGroup implements Drawable {
  final List<Drawable> children;
  final DrawableStyle style;

  const DrawableGroup(this.children, this.style);

  @override
  bool get hasDrawableContent => children != null && children.isNotEmpty;

  @override
  void draw(Canvas canvas, ColorFilter colorFilter) {
    if (!hasDrawableContent) {
      return;
    }

    final Function innerDraw = () {
      if (style?.transform != null) {
        canvas.save();
        canvas.transform(style?.transform);
      }
      for (Drawable child in children) {
        child.draw(canvas, colorFilter);
      }
      if (style?.transform != null) {
        canvas.restore();
      }
    };

    if (style?.clipPath?.isNotEmpty == true) {
      for (Path clipPath in style.clipPath) {
        canvas.save();
        canvas.clipPath(clipPath);

        if (children.length > 1) {
          canvas.saveLayer(clipPath.getBounds(), DrawableStyle.emptyPaint);
        }

        innerDraw();

        if (children.length > 1) {
          canvas.restore();
        }
        canvas.restore();
      }
    } else {
      innerDraw();
    }
  }
}

/// Represents a drawing element that will be rendered to the canvas.
class DrawableShape implements Drawable {
  final DrawableStyle style;
  final Path path;

  const DrawableShape(this.path, this.style)
      : assert(path != null),
        assert(style != null);

  Rect get bounds => path.getBounds();

  // can't use bounds.isEmpty here because some paths give a 0 width or height
  // see https://skia.org/user/api/SkPath_Reference#SkPath_getBounds
  // can't rely on style because parent style may end up filling or stroking
  // TODO: implement display properties - but that should really be done on style.
  @override
  bool get hasDrawableContent => bounds.width + bounds.height > 0;

  @override
  void draw(Canvas canvas, ColorFilter colorFilter) {
    if (!hasDrawableContent || style == null) {
      return;
    }

    path.fillType = style.pathFillType ?? PathFillType.nonZero;

    // if we have multiple clips to apply, need to wrap this in a loop.
    final Function innerDraw = () {
      if (style.fill != null &&
          !identical(style.fill, DrawableStyle.emptyPaint)) {
        style.fill.colorFilter = colorFilter;
        canvas.drawPath(path, style.fill);
      }

      if (style.stroke != null &&
          !identical(style.stroke, DrawableStyle.emptyPaint)) {
        style.stroke.colorFilter = colorFilter;
        if (style.dashArray != null &&
            !identical(style.dashArray, DrawableStyle.emptyDashArray)) {
          canvas.drawPath(
              dashPath(path,
                  dashArray: style.dashArray, dashOffset: style.dashOffset),
              style.stroke);
        } else {
          canvas.drawPath(path, style.stroke);
        }
      }
    };

    if (style.clipPath?.isNotEmpty == true) {
      for (Path clip in style.clipPath) {
        canvas.save();
        canvas.clipPath(clip);
        innerDraw();
        canvas.restore();
      }
    } else {
      innerDraw();
    }
  }
}
