import 'dart:typed_data';
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';
import 'package:flutter/widgets.dart' hide TextStyle;
import 'package:meta/meta.dart';

typedef Paint PaintServer(Rect bounds);

/// Base interface for vector drawing.
@immutable
abstract class Drawable {
  /// Whether this [Drawable] would be visible if [draw]n.
  bool get isVisible;

  /// Draws the contents or children of this [Drawable] to the `canvas`, using
  /// the `parentPaint` to optionally override the child's paint.
  void draw(Canvas canvas);
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
  static final Paint emptyPaint = new Paint();

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

  final TextStyle textStyle;

  /// The fill rule to use for this path.
  final PathFillType pathFillType;

  /// The clip to apply, if any.
  final Path clipPath;

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
      TextStyle textStyle,
      PathFillType pathFillType,
      double groupOpacity,
      Path clipPath}) {
    final DrawableStyle ret = new DrawableStyle(
      fill: fill ?? parent?.fill,
      stroke: stroke ?? parent?.stroke,
      dashArray: dashArray ?? parent?.dashArray,
      dashOffset: dashOffset ?? parent?.dashOffset,
      // transforms aren't inherited because they're applied to canvas with save/restore
      // that wraps any potential children
      transform: transform,
      textStyle: textStyle ?? parent?.textStyle,
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
}

// WIP
class DrawableText implements Drawable {
  final Offset offset;
  final DrawableStyle style;
  final Paragraph _paragraph;

  DrawableText(String text, this.offset, this.style)
      : assert(text != null && text != ''),
        _paragraph = _buildParagraph(text, style);

  static Paragraph _buildParagraph(String text, DrawableStyle style) {
    final ParagraphBuilder pb = new ParagraphBuilder(new ParagraphStyle())
      ..pushStyle(style.textStyle)
      ..addText(text);

    return pb.build()..layout(new ParagraphConstraints(width: double.infinity));
  }

  @override
  bool get isVisible => _paragraph.width > 0.0;

  @override
  void draw(Canvas canvas) {
    if (!isVisible) {
      return;
    }
    canvas.drawParagraph(_paragraph, offset);
  }
}

/// Contains reusable drawing elements that can be referenced by a String ID.
class DrawableDefinitionServer {
  final Map<String, PaintServer> _paintServers = <String, PaintServer>{};
  final Map<String, Path> _clipPaths = <String, Path>{};

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

  Path getClipPath(String id) {
    assert(id != null);
    return _clipPaths[id];
  }

  void addClipPath(String id, Path path) {
    assert(id != null);
    _clipPaths[id] = path;
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
    final double xscale = desiredSize.width / viewBox.size.width;
    final double yscale = desiredSize.height / viewBox.size.height;

    if (xscale == yscale) {
      canvas.scale(xscale, yscale);
    } else if (xscale < yscale) {
      final double xtranslate = (viewBox.size.width - viewBox.size.height) / 2;
      canvas.scale(xscale, xscale);
      canvas.translate(0.0, xtranslate);
    } else {
      final double ytranslate = (viewBox.size.height - viewBox.size.width) / 2;
      canvas.scale(yscale, yscale);
      canvas.translate(ytranslate, 0.0);
    }
  }

  /// Clips the canvas to a rect corresponding to the `viewBox`.
  void clipCanvasToViewBox(Canvas canvas) {
    canvas.clipRect(viewBox.translate(viewBox.left, viewBox.top));
  }

  @override
  bool get isVisible =>
      children.isNotEmpty == true && viewBox != null && !viewBox.isEmpty;

  @override
  void draw(Canvas canvas) {
    if (!isVisible) {
      return;
    }
    for (Drawable child in children) {
      child.draw(canvas);
    }
  }
}

/// Represents an element that is not rendered and has no chidlren, e.g.
/// a descriptive element.
// TODO: tie some of this into semantics/accessibility
class DrawableNoop implements Drawable {
  final String name;
  const DrawableNoop(this.name);

  @override
  bool get isVisible => false;

  @override
  void draw(Canvas canvas) {}
}

/// Represents a group of drawing elements that may share a common `transform`, `stroke`, or `fill`.
class DrawableGroup implements Drawable {
  final List<Drawable> children;
  final DrawableStyle style;

  const DrawableGroup(this.children, this.style);

  @override
  bool get isVisible => children != null && children.isNotEmpty;

  @override
  void draw(Canvas canvas) {
    if (!isVisible) {
      return;
    }

    if (style?.clipPath != null) {
      canvas.save();
      canvas.clipPath(style.clipPath);
      if (children.length > 1) {
        canvas.saveLayer(style.clipPath.getBounds(), DrawableStyle.emptyPaint);
      }
    }

    if (style?.transform != null) {
      canvas.save();
      canvas.transform(style?.transform);
    }
    for (Drawable child in children) {
      child.draw(canvas);
    }
    if (style?.transform != null) {
      canvas.restore();
    }

    if (style?.clipPath != null) {
      if (children.length > 1) {
        canvas.restore();
      }
      canvas.restore();
    }
  }
}

/// Represents a drawing element that will be rendered to the canvas.
class DrawableShape implements Drawable {
  final DrawableStyle style;
  final Path path;

  const DrawableShape(this.path, this.style) : assert(path != null);

  Rect get bounds => path?.getBounds();

  // can't use bounds.isEmpty here because some paths give a 0 width or height
  // see https://skia.org/user/api/SkPath_Reference#SkPath_getBounds
  // can't rely on style because parent style may end up filling or stroking
  // TODO: implement display properties
  @override
  bool get isVisible => bounds.width + bounds.height > 0;

  @override
  void draw(Canvas canvas) {
    if (!isVisible) {
      return;
    }

    path.fillType = style.pathFillType ?? PathFillType.nonZero;

    if (style?.clipPath != null) {
      canvas.save();
      canvas.clipPath(style.clipPath);
    }

    if (style?.fill != null &&
        !identical(style.fill, DrawableStyle.emptyPaint)) {
      canvas.drawPath(path, style.fill);
    }

    if (style?.stroke != null &&
        !identical(style.stroke, DrawableStyle.emptyPaint)) {
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

    if (style?.clipPath != null) {
      canvas.restore();
    }
  }
}

/// A [CustomPainter] that can render a [DrawableRoot] to a [Canvas].
class VectorPainter extends CustomPainter {
  final DrawableRoot drawable;
  final bool _clipToViewBox;

  VectorPainter(this.drawable, {bool clipToViewBox = true})
      : _clipToViewBox = clipToViewBox;

  @override
  void paint(Canvas canvas, Size size) {
    Rect p;
    p.hashCode;
    if (drawable == null ||
        drawable.viewBox == null ||
        drawable.viewBox.size.width == 0) {
      return;
    }

    drawable.scaleCanvasToViewBox(canvas, size);
    if (_clipToViewBox) {
      drawable.clipCanvasToViewBox(canvas);
    }

    drawable.draw(canvas);
  }

  // TODO: implement semanticsBuilder

  @override
  bool shouldRepaint(VectorPainter oldDelegate) => true;
}
