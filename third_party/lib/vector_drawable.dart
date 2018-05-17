import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'src/vector_painter.dart';

enum PaintLocation { Foreground, Background }

/// Handles rendering the [DrawableRoot] from `future` to a [Canvas].
///
/// To control the coordinate space, use the `size` parameter. In most
/// contexts, you should prefer keeping `clipToViewBox` as true to avoid
/// potentially drawing outside the bounds of the canvas.  By default,
/// this will draw to the background (meaning the child widget will be
/// rendered after drawing).  You can change that by specifying
/// `PaintLocation.Foreground`.
///
/// By default, a [LimitedBox] will be rendered while the `future` is resolving.
/// This can be replaced by specifying `loadingPlaceholderBuilder`, and is
/// especially useful if you're loading a network asset.
///
/// By default, an [ErrorWidget] will be rendered if an error occurs. This
/// can be replace with a custom [ErrorWidgetBuilder] to taste.
class VectorDrawableImage extends StatelessWidget {
  static final WidgetBuilder defaultPlaceholderBuilder =
      (BuildContext ctx) => const LimitedBox();

  /// The size of the coordinate space to render this image in.
  final Size size;

  /// The [Future] that resolves the drawing content.
  final Future<DrawableRoot> future;

  /// Whether to allow drawing outside of the canvas or not.  Defaults to
  /// true.
  final bool clipToViewBox;

  /// Whether to draw before or after child content.  Defaults to background
  /// (before).
  final PaintLocation paintLocation;

  /// [ErrorWidgetBuilder] to specify what to render if an exception is thrown.
  final ErrorWidgetBuilder errorWidgetBuilder;

  /// [WidgetBuilder] to use while the [future] is resolving.
  final WidgetBuilder loadingPlaceholderBuilder;

  /// Child content for this widget.
  final Widget child;

  const VectorDrawableImage(this.future, this.size,
      {this.clipToViewBox = true,
      Key key,
      this.paintLocation = PaintLocation.Background,
      this.errorWidgetBuilder,
      this.loadingPlaceholderBuilder,
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ErrorWidgetBuilder localErrorBuilder =
        errorWidgetBuilder ?? ErrorWidget.builder;
    final WidgetBuilder localPlaceholder =
        loadingPlaceholderBuilder ?? defaultPlaceholderBuilder;
    return new FutureBuilder<DrawableRoot>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<DrawableRoot> snapShot) {
        if (snapShot.hasError) {
          return localErrorBuilder(new FlutterErrorDetails(
            context: 'SVG Rendering',
            exception: snapShot.error,
            library: 'flutter_svg',
            stack: StackTrace.current,
          ));
        } else if (snapShot.hasData) {
          final CustomPainter painter =
              new VectorPainter(snapShot.data, clipToViewBox: clipToViewBox);
          return new RepaintBoundary.wrap(
              CustomPaint(
                  painter: paintLocation == PaintLocation.Background
                      ? painter
                      : null,
                  foregroundPainter: paintLocation == PaintLocation.Foreground
                      ? painter
                      : null,
                  size: size,
                  isComplex: true,
                  willChange: false,
                  child: child),
              0);
        }
        return localPlaceholder(context);

        // return const LimitedBox();
      },
    );
  }
}
