import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

/// A listener implementation for the vector graphics codec that converts the
/// format into a [ui.Picture].
class FlutterVectorGraphicsListener extends VectorGraphicsCodecListener {

  /// Create a new [FlutterVectorGraphicsListener].
  factory FlutterVectorGraphicsListener() {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    return FlutterVectorGraphicsListener._(canvas, recorder);
  }

  FlutterVectorGraphicsListener._(this._canvas, this._recorder);

  final ui.PictureRecorder _recorder;
  final ui.Canvas _canvas;
  final List<ui.Paint> _paints = <ui.Paint>[];
  final List<ui.Path> _paths = <ui.Path>[];
  ui.Path? _currentPath;
  bool _done = false;

  static final _emptyPaint = ui.Paint();

  /// Convert the vector graphics asset this listener decoded into a [ui.Picture].
  ///
  /// This method can only be called once for a given listener instance.
  ui.Picture toPicture() {
    assert(!_done);
    _done = true;
    return _recorder.endRecording();
  }

  @override
  void onDrawPath(int pathId, int? paintId) {
    final ui.Path path = _paths[pathId];
    ui.Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    _canvas.drawPath(path, paint ?? _emptyPaint);
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    final ui.Vertices vextexData =
        ui.Vertices.raw(ui.VertexMode.triangles, vertices, indices: indices);
    ui.Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    _canvas.drawVertices(
        vextexData, ui.BlendMode.srcOver, paint ?? _emptyPaint);
  }

  @override
  void onPaintObject({
    required int color,
    required int? strokeCap,
    required int? strokeJoin,
    required int blendMode,
    required double? strokeMiterLimit,
    required double? strokeWidth,
    required int paintStyle,
    required int id,
  }) {
    assert(_paints.length == id, 'Expect ID to be ${_paints.length}');
    final ui.Paint paint = ui.Paint();
    if (paintStyle == 0) {
      // fill
      paint
        ..color = ui.Color(color)
        ..blendMode = ui.BlendMode.values[blendMode]
        ..style = ui.PaintingStyle.fill;
    } else {
      paint
        ..color = ui.Color(color)
        ..blendMode = ui.BlendMode.values[blendMode]
        ..style = ui.PaintingStyle.stroke
        ..strokeCap = ui.StrokeCap.values[strokeCap ?? 0]
        ..strokeJoin = ui.StrokeJoin.values[strokeJoin ?? 0];
      if (strokeMiterLimit != null) {
        paint.strokeMiterLimit = strokeMiterLimit;
      }
      if (strokeWidth != null) {
        paint.strokeWidth = strokeWidth;
      }
    }
    _paints.add(paint);
  }

  @override
  void onPathClose() {
    _currentPath!.close();
  }

  @override
  void onPathCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _currentPath!.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void onPathFinished() {
    _currentPath = null;
  }

  @override
  void onPathLineTo(double x, double y) {
    _currentPath!.lineTo(x, y);
  }

  @override
  void onPathMoveTo(double x, double y) {
    _currentPath!.moveTo(x, y);
  }

  @override
  void onPathStart(int id, int fillType) {
    assert(_currentPath == null);
    assert(_paths.length == id, 'Expected Id to be $id');

    final ui.Path path = ui.Path();
    path.fillType = ui.PathFillType.values[fillType];
    _paths.add(path);
    _currentPath = path;
  }
}
