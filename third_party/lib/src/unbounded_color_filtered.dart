import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Supports SvgPicture - not meant for public use, visible for testing.
@visibleForTesting
class UnboundedColorFiltered extends SingleChildRenderObjectWidget {
  /// Supports SvgPicture - not meant for public use, visible for testing.
  const UnboundedColorFiltered({
    Key? key,
    required this.colorFilter,
    required Widget child,
  }) : super(key: key, child: child);

  /// The color filter to apply.
  final ColorFilter? colorFilter;

  @override
  _UnboundedColorFilteredRenderBox createRenderObject(BuildContext context) =>
      _UnboundedColorFilteredRenderBox(colorFilter);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _UnboundedColorFilteredRenderBox renderObject,
  ) {
    renderObject.colorFilter = colorFilter;
  }
}

class _UnboundedColorFilteredRenderBox extends RenderProxyBox {
  _UnboundedColorFilteredRenderBox(
    this._colorFilter,
  );

  ColorFilter? _colorFilter;
  ColorFilter? get colorFilter => _colorFilter;
  set colorFilter(ColorFilter? value) {
    if (value == _colorFilter) {
      return;
    }
    _colorFilter = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()..colorFilter = colorFilter;
    context.canvas.saveLayer(offset & size, paint);
    if (child != null) {
      context.paintChild(child!, offset);
    }
    context.canvas.restore();
  }
}
