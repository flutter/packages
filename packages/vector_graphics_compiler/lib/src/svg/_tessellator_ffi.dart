// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: camel_case_types
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import '../geometry/path.dart';
import '../geometry/vertices.dart';
import '../paint.dart';
import 'node.dart';
import 'parser.dart';
import 'resolver.dart';
import 'tessellator.dart' as api;
import 'visitor.dart';

// TODO(dnfield): Figure out where to put this.
// https://github.com/flutter/flutter/issues/99563
final ffi.DynamicLibrary _dylib = ffi.DynamicLibrary.open(_dylibPath);
late final String _dylibPath;

/// Whether or not tesselation should be used.
bool get isTesselatorInitialized => _isTesselatorInitialized;
bool _isTesselatorInitialized = false;

/// Initialize the libtesselator dynamic library.
///
/// This method must be called before [VerticesBuilder] can be used or
/// constructed.
void initializeLibTesselator(String path) {
  _dylibPath = path;
  _isTesselatorInitialized = true;
}

/// A visitor that replaces fill paths with tesselated vertices.
class Tessellator extends Visitor<Node, void>
    with ErrorOnUnResolvedNode<Node, void>
    implements api.Tessellator {
  @override
  Node visitEmptyNode(Node node, void data) {
    return node;
  }

  @override
  Node visitParentNode(ParentNode parentNode, void data) {
    return ParentNode(SvgAttributes.empty, children: <Node>[
      for (final Node child in parentNode.children) child.accept(this, data)
    ]);
  }

  @override
  Node visitResolvedClipNode(ResolvedClipNode clipNode, void data) {
    return ResolvedClipNode(
      clips: clipNode.clips,
      child: clipNode.child.accept(this, data),
    );
  }

  @override
  Node visitResolvedMaskNode(ResolvedMaskNode maskNode, void data) {
    return ResolvedMaskNode(
      child: maskNode.child.accept(this, data),
      mask: maskNode.mask,
      blendMode: maskNode.blendMode,
    );
  }

  @override
  Node visitResolvedTextPositionNode(
      ResolvedTextPositionNode textPositionNode, void data) {
    return ResolvedTextPositionNode(
      textPositionNode.textPosition,
      <Node>[
        for (final Node child in textPositionNode.children)
          child.accept(this, data)
      ],
    );
  }

  @override
  Node visitResolvedPath(ResolvedPathNode pathNode, void data) {
    final Fill? fill = pathNode.paint.fill;
    final Stroke? stroke = pathNode.paint.stroke;
    if (fill == null && stroke != null) {
      return pathNode;
    }

    final List<Node> children = <Node>[];
    if (fill != null) {
      final VerticesBuilder builder = VerticesBuilder();
      for (final PathCommand command in pathNode.path.commands) {
        switch (command.type) {
          case PathCommandType.move:
            final MoveToCommand move = command as MoveToCommand;
            builder.moveTo(move.x, move.y);
          case PathCommandType.line:
            final LineToCommand line = command as LineToCommand;
            builder.lineTo(line.x, line.y);
          case PathCommandType.cubic:
            final CubicToCommand cubic = command as CubicToCommand;
            builder.cubicTo(
              cubic.x1,
              cubic.y1,
              cubic.x2,
              cubic.y2,
              cubic.x3,
              cubic.y3,
            );
          case PathCommandType.close:
            builder.close();
        }
      }
      final Float32List rawVertices = builder.tessellate(
        fillType: pathNode.path.fillType,
      );
      if (rawVertices.isNotEmpty) {
        final Vertices vertices = Vertices.fromFloat32List(rawVertices);
        final IndexedVertices indexedVertices = vertices.createIndex();
        children.add(ResolvedVerticesNode(
          paint: Paint(blendMode: pathNode.paint.blendMode, fill: fill),
          vertices: indexedVertices,
          bounds: pathNode.bounds,
        ));
      }
    }
    if (stroke != null) {
      children.add(ResolvedPathNode(
          paint: Paint(
            blendMode: pathNode.paint.blendMode,
            stroke: stroke,
          ),
          bounds: pathNode.bounds,
          path: pathNode.path));
    }
    if (children.isEmpty) {
      return Node.empty;
    }
    if (children.length > 1) {
      return ParentNode(SvgAttributes.empty, children: children);
    }
    return children[0];
  }

  @override
  Node visitResolvedText(ResolvedTextNode textNode, void data) {
    return textNode;
  }

  @override
  Node visitSaveLayerNode(SaveLayerNode layerNode, void data) {
    return SaveLayerNode(SvgAttributes.empty,
        paint: layerNode.paint,
        children: <Node>[
          for (final Node child in layerNode.children) child.accept(this, data),
        ]);
  }

  @override
  Node visitViewportNode(ViewportNode viewportNode, void data) {
    return ViewportNode(
      SvgAttributes.empty,
      width: viewportNode.width,
      height: viewportNode.height,
      transform: viewportNode.transform,
      children: <Node>[
        for (final Node child in viewportNode.children)
          child.accept(this, data),
      ],
    );
  }

  @override
  Node visitResolvedVerticesNode(ResolvedVerticesNode verticesNode, void data) {
    return verticesNode;
  }

  @override
  Node visitResolvedImageNode(ResolvedImageNode resolvedImageNode, void data) {
    return resolvedImageNode;
  }

  @override
  Node visitResolvedPatternNode(ResolvedPatternNode patternNode, void data) {
    return patternNode;
  }
}

/// Creates vertices from path commands.
///
/// First, build up the path contours with the [moveTo], [lineTo], [cubicTo],
/// and [close] methods. All methods expect absolute coordinates.
///
/// Then, use the [tessellate] method to create a [Float32List] of vertex pairs.
///
/// Finally, use the [dispose] method to clean up native resources. After
/// [dispose] has been called, this class must not be used again.
class VerticesBuilder {
  /// Create a new [VerticesBuilder].
  VerticesBuilder() : _builder = _createPathFn();

  ffi.Pointer<_PathBuilder>? _builder;
  final List<ffi.Pointer<_Vertices>> _vertices = <ffi.Pointer<_Vertices>>[];

  /// Adds a move verb to the absolute coordinates x,y.
  void moveTo(double x, double y) {
    assert(_builder != null);
    _moveToFn(_builder!, x, y);
  }

  /// Adds a line verb to the absolute coordinates x,y.
  void lineTo(double x, double y) {
    assert(_builder != null);
    _lineToFn(_builder!, x, y);
  }

  /// Adds a cubic Bezier curve with x1,y1 as the first control point, x2,y2 as
  /// the second control point, and end point x3,y3.
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    assert(_builder != null);
    _cubicToFn(_builder!, x1, y1, x2, y2, x3, y3);
  }

  /// Adds a close command to the start of the current contour.
  void close() {
    assert(_builder != null);
    _closeFn(_builder!, true);
  }

  /// Tessellates the path created by the previous method calls into a list of
  /// vertices.
  Float32List tessellate({
    PathFillType fillType = PathFillType.nonZero,
    api.SmoothingApproximation smoothing = const api.SmoothingApproximation(),
  }) {
    assert(_vertices.isEmpty);
    assert(_builder != null);
    final ffi.Pointer<_Vertices> vertices = _tessellateFn(
      _builder!,
      fillType.index,
      smoothing.scale,
      smoothing.angleTolerance,
      smoothing.cuspLimit,
    );
    _vertices.add(vertices);
    return vertices.ref.points.asTypedList(vertices.ref.size);
  }

  /// Releases native resources.
  ///
  /// After calling dispose, this class must not be used again.
  void dispose() {
    assert(_builder != null);
    _vertices.forEach(_destroyVerticesFn);
    _destroyFn(_builder!);
    _vertices.clear();
    _builder = null;
  }
}

base class _Vertices extends ffi.Struct {
  external ffi.Pointer<ffi.Float> points;

  @ffi.Uint32()
  external int size;
}

base class _PathBuilder extends ffi.Opaque {}

typedef _CreatePathBuilderType = ffi.Pointer<_PathBuilder> Function();
typedef _create_path_builder_type = ffi.Pointer<_PathBuilder> Function();

final _CreatePathBuilderType _createPathFn =
    _dylib.lookupFunction<_create_path_builder_type, _CreatePathBuilderType>(
  'CreatePathBuilder',
);

typedef _MoveToType = void Function(ffi.Pointer<_PathBuilder>, double, double);
typedef _move_to_type = ffi.Void Function(
  ffi.Pointer<_PathBuilder>,
  ffi.Float,
  ffi.Float,
);

final _MoveToType _moveToFn = _dylib.lookupFunction<_move_to_type, _MoveToType>(
  'MoveTo',
);

typedef _LineToType = void Function(ffi.Pointer<_PathBuilder>, double, double);
typedef _line_to_type = ffi.Void Function(
  ffi.Pointer<_PathBuilder>,
  ffi.Float,
  ffi.Float,
);

final _LineToType _lineToFn = _dylib.lookupFunction<_line_to_type, _LineToType>(
  'LineTo',
);

typedef _CubicToType = void Function(
  ffi.Pointer<_PathBuilder>,
  double,
  double,
  double,
  double,
  double,
  double,
);
typedef _cubic_to_type = ffi.Void Function(
  ffi.Pointer<_PathBuilder>,
  ffi.Float,
  ffi.Float,
  ffi.Float,
  ffi.Float,
  ffi.Float,
  ffi.Float,
);

final _CubicToType _cubicToFn =
    _dylib.lookupFunction<_cubic_to_type, _CubicToType>('CubicTo');

typedef _CloseType = void Function(ffi.Pointer<_PathBuilder>, bool);
typedef _close_type = ffi.Void Function(ffi.Pointer<_PathBuilder>, ffi.Bool);

final _CloseType _closeFn =
    _dylib.lookupFunction<_close_type, _CloseType>('Close');

typedef _TessellateType = ffi.Pointer<_Vertices> Function(
  ffi.Pointer<_PathBuilder>,
  int,
  double,
  double,
  double,
);
typedef _tessellate_type = ffi.Pointer<_Vertices> Function(
  ffi.Pointer<_PathBuilder>,
  ffi.Int,
  ffi.Float,
  ffi.Float,
  ffi.Float,
);

final _TessellateType _tessellateFn =
    _dylib.lookupFunction<_tessellate_type, _TessellateType>('Tessellate');

typedef _DestroyType = void Function(ffi.Pointer<_PathBuilder>);
typedef _destroy_type = ffi.Void Function(ffi.Pointer<_PathBuilder>);

final _DestroyType _destroyFn =
    _dylib.lookupFunction<_destroy_type, _DestroyType>(
  'DestroyPathBuilder',
);

typedef _DestroyVerticesType = void Function(ffi.Pointer<_Vertices>);
typedef _destroy_vertices_type = ffi.Void Function(ffi.Pointer<_Vertices>);

final _DestroyVerticesType _destroyVerticesFn =
    _dylib.lookupFunction<_destroy_vertices_type, _DestroyVerticesType>(
  'DestroyVertices',
);
