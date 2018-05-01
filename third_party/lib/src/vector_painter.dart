import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

typedef Paint PaintServer(Rect bounds);

/// Base interface for vector drawing.
@immutable
abstract class Drawable {
  /// Whether this [Drawable] would be visible if [draw]n.
  bool get isVisible;

  /// Draws the contents or children of this [Drawable] to the `canvas`, using
  /// the `parentPaint` to optionally override the child's paint.
  void draw(Canvas canvas, [DrawableStyle parentStyle]);
}

@immutable
class DrawableStyle {
  final Paint stroke;
  final Paint fill;
  final Float64List transform;
  final TextStyle textStyle;

  const DrawableStyle({this.stroke, this.fill, this.transform, this.textStyle});

  /// Creates a new [DrawableStyle] if `other` is not null, filling in any null properties on
  /// this with the properties from other.
  ///
  /// If `other` is null, returns this.
  DrawableStyle merge(DrawableStyle other) {
    if (other == null) return this;

    return new DrawableStyle(
        fill: this.fill ?? other.fill,
        stroke: this.stroke ?? other.stroke,
        transform: this.transform ?? other.transform,
        textStyle: this.textStyle ?? other.textStyle);
  }
}

class DrawableText implements Drawable {
  final String text;
  final TextStyle style;
  final Float64List transform;

  const DrawableText(this.text, this.style, this.transform)
      : assert(text != null && text != '');

  @override
  bool get isVisible => true;

  @override
  draw(Canvas canvas, [DrawableStyle parentStyle]) {}
}

/// The root element of a drawable.
class DrawableRoot implements Drawable {
  /// The expected coordinates used by child paths for drawing.
  final Rect viewBox;

  /// The actual child or group to draw.
  final List<Drawable> children;

  final Map<String, PaintServer> paintServers;

  const DrawableRoot(this.viewBox, this.children, this.paintServers);

  /// Scales the `canvas` so that the drawing units in this [Drawable]
  /// will scale to the `desiredSize`.
  ///
  /// If the `viewBox` dimensions are not 1:1 with `desiredSize`, will scale to
  /// the smaller dimension and translate to center the image along the larger
  /// dimension.
  void scaleToViewBox(Canvas canvas, Size desiredSize) {
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
  void clipToViewBox(Canvas canvas) {
    canvas.clipRect(viewBox.translate(viewBox.left, viewBox.top));
  }

  @override
  bool get isVisible =>
      children.isNotEmpty == true && viewBox != null && !viewBox.isEmpty;

  @override
  void draw(Canvas canvas, [DrawableStyle parentStyle]) {
    children.forEach((child) => child.draw(canvas, parentStyle));
  }
}

/// Represents an element that is not rendered and has no chidlren.
class DrawableNoop implements Drawable {
  final String name;
  const DrawableNoop(this.name);

  @override
  bool get isVisible => false;

  @override
  void draw(Canvas canvas, [DrawableStyle parentStyle]) {}
}

/// Represents a group of drawing elements that may share a common `transform`, `stroke`, or `fill`.
class DrawableGroup implements Drawable {
  final List<Drawable> children;
  final DrawableStyle style;

  const DrawableGroup(this.children, this.style);

  @override
  bool get isVisible => children != null && children.length > 0;

  @override
  void draw(Canvas canvas, [DrawableStyle parentStyle]) {
    if (style?.transform != null) {
      canvas.save();
      canvas.transform(style?.transform);
    }
    children.forEach((child) {
      child.draw(canvas, style?.merge(parentStyle) ?? parentStyle);
    });
    if (style?.transform != null) {
      canvas.restore();
    }
  }
}

/// Represents a drawing element that will be rendered to the canvas.
class DrawableShape implements Drawable {
  final DrawableStyle style;
  final Path path;
  static final  Paint _blackPaint = new Paint()..color = const Color(0xFF000000);

  Rect get bounds => path?.getBounds();

  const DrawableShape(this.path, this.style) : assert(path != null);

  @override
  bool get isVisible =>
      !bounds.isEmpty && (style?.stroke != null || style?.fill != null);

  @override
  void draw(Canvas canvas, [DrawableStyle parentStyle]) {
    if (style?.stroke != null) {
      canvas.drawPath(path, style.stroke);
    } else if (parentStyle?.stroke != null) {
      canvas.drawPath(path, parentStyle.stroke);
    }
    
    if (style?.fill != null) {
      canvas.drawPath(path, style.fill);
    } else if (parentStyle?.fill != null) {
      canvas.drawPath(path, parentStyle.fill);
    } else {
      canvas.drawPath(path, _blackPaint);
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
        drawable.viewBox.size.width == 0) return;

    drawable.scaleToViewBox(canvas, size);
    if (_clipToViewBox) {
      drawable.clipToViewBox(canvas);
    }

    drawable.draw(canvas);
  }

  @override
  bool shouldRepaint(VectorPainter oldPainter) => true;
}
