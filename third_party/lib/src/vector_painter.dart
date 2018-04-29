import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

typedef Paint PaintServer(Size size);

/// Base interface for vector drawing.
@immutable
abstract class Drawable {
  /// Whether this [Drawable] would be visible if [draw]n.
  bool get isVisible;

  /// Draws the contents or children of this [Drawable] to the `canvas`, using
  /// the `parentPaint` to optionally override the child's paint.
  void draw(Canvas canvas, [Paint parentPaint]);
}

/// The root element of a drawable.
class DrawableRoot implements Drawable {
  /// The expected coordinates used by child paths for drawing.
  final Rect viewBox;

  /// The actual child or group to draw.
  final List<Drawable> children;

  const DrawableRoot(this.viewBox, this.children);

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
  void draw(Canvas canvas, [Paint parentPaint]) {
    children.forEach((child) => child.draw(canvas, parentPaint));
  }
}

class DrawableNoop implements Drawable {
  final String name;
  const DrawableNoop(this.name);

  @override
  bool get isVisible => false;

  @override
  void draw(Canvas canvas, [Paint parentPaint]) {
    print('Attempted to draw $name');
  }
}

class DrawableGroup implements Drawable {
  final List<Drawable> children;
  final Paint stroke;
  final Paint fill;
  final Float64List transform;

  const DrawableGroup(this.children, this.transform, this.stroke, this.fill);

  @override
  bool get isVisible => children != null && children.length > 0;

  @override
  void draw(Canvas canvas, [Paint parentPaint]) {
    if (transform != null) {
      canvas.save();
      canvas.transform(transform);
    }
    children.forEach((child) {
      if (stroke != null) {
        child.draw(canvas, stroke);
      }
      if (fill != null) {
        child.draw(canvas, fill);
      }
      if (stroke == null && fill == null) {
        child.draw(canvas);
      }
    });
    if (transform != null) {
      canvas.restore();
    }
  }
}

class DrawableShape implements Drawable {
  final Paint stroke;
  final Paint fill;
  final Path path;
  final Size size;

  const DrawableShape(this.path, this.size, {this.stroke, this.fill})
      : assert(path != null),
        assert(size != null);

  @override
  bool get isVisible => !size.isEmpty && (stroke != null || fill != null);

  @override
  void draw(Canvas canvas, [Paint parentPaint]) {
    if (parentPaint != null) {
      canvas.drawPath(path, parentPaint);
      return;
    }
    if (stroke != null) canvas.drawPath(path, stroke);
    if (fill != null) canvas.drawPath(path, fill);
  }
}

class VectorPainter extends CustomPainter {
  final DrawableRoot drawable;
  final Map<String, PaintServer> paintServers;
  final bool _clipToViewBox;

  VectorPainter(this.drawable, this.paintServers, {bool clipToViewBox = true})
      : _clipToViewBox = clipToViewBox;

  @override
  void paint(Canvas canvas, Size size) {
    if (drawable == null ||
        drawable.viewBox == null ||
        drawable.viewBox.size.width == 0) return;

    drawable.scaleToViewBox(canvas, size);
    if (_clipToViewBox) {
      drawable.clipToViewBox(canvas);
    }

    drawable.draw(canvas);
    // final Map<String, PaintServer> paintServers = <String, PaintServer>{};
    //
    // for (var el in _rawSvg.rootElement.children) {
    //   if (el is XmlElement) {
    //     if (el.name.local == 'defs') {
    //       parseDefs(el, paintServers, size);
    //     } else {
    //       new SvgElement.fromXml(el, paintServers, size).draw(canvas);
    //     }
    //   }
    // }
  }

  @override
  bool shouldRepaint(VectorPainter oldPainter) => true;
  // _rawSvg != null && oldPainter._rawSvg != _rawSvg;
}
