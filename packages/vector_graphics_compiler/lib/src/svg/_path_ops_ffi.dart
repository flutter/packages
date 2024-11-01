// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: camel_case_types
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'path_ops.dart';

// TODO(dnfield): Figure out where to put this.
// https://github.com/flutter/flutter/issues/99563
final ffi.DynamicLibrary _dylib = ffi.DynamicLibrary.open(_dylibPath);
late final String _dylibPath;

/// Creates a path object to operate on.
///
/// First, build up the path contours with the [moveTo], [lineTo], [cubicTo],
/// and [close] methods. All methods expect absolute coordinates.
///
/// Finally, use the [dispose] method to clean up native resources. After
/// [dispose] has been called, this class must not be used again.
class Path implements PathProxy {
  /// Creates an empty path object with the specified fill type.
  Path([FillType fillType = FillType.nonZero])
      : _path = _createPathFn(fillType.index);

  /// Creates a copy of this path.
  factory Path.from(Path other) {
    final Path result = Path(other.fillType);
    other.replay(result);
    return result;
  }

  /// The [FillType] of this path.
  FillType get fillType {
    assert(_path != null);
    return FillType.values[_getFillTypeFn(_path!)];
  }

  ffi.Pointer<_SkPath>? _path;
  ffi.Pointer<_PathData>? _pathData;

  /// The number of points used by each [PathVerb].
  static const Map<PathVerb, int> pointsPerVerb = <PathVerb, int>{
    PathVerb.moveTo: 2,
    PathVerb.lineTo: 2,
    PathVerb.cubicTo: 6,
    PathVerb.close: 0,
  };

  /// Makes the appropriate calls using [verbs] and [points] to replay this path
  /// on [proxy].
  ///
  /// Calls [PathProxy.reset] first if [reset] is true.
  void replay(PathProxy proxy, {bool reset = true}) {
    if (reset) {
      proxy.reset();
    }
    int index = 0;
    for (final PathVerb verb in verbs.toList()) {
      switch (verb) {
        case PathVerb.moveTo:
          proxy.moveTo(points[index++], points[index++]);
        case PathVerb.lineTo:
          proxy.lineTo(points[index++], points[index++]);
        case PathVerb.quadTo:
          // TODO(dnfield): Avoid degree elevation?
          // The binary format only supports cubics. Skia might have
          // used a quad when combining paths somewhere though.
          final double cpX = points[index++];
          final double cpY = points[index++];
          proxy.cubicTo(
            cpX,
            cpY,
            cpX,
            cpY,
            points[index++],
            points[index++],
          );
        case PathVerb.cubicTo:
          proxy.cubicTo(
            points[index++],
            points[index++],
            points[index++],
            points[index++],
            points[index++],
            points[index++],
          );
        case PathVerb.close:
          proxy.close();
      }
    }
    assert(index == points.length);
  }

  /// The list of path verbs in this path.
  ///
  /// This may not match the verbs supplied by calls to [moveTo], [lineTo],
  /// [cubicTo], and [close] after [applyOp] is invoked.
  ///
  /// This list determines the meaning of the [points] array.

  static const Map<int, PathVerb> pathVerbDict = <int, PathVerb>{
    0: PathVerb.moveTo,
    1: PathVerb.lineTo,
    2: PathVerb.quadTo,
    4: PathVerb.cubicTo,
    5: PathVerb.close
  };

  /// Retrieves PathVerbs.
  Iterable<PathVerb> get verbs {
    _updatePathData();
    final int count = _pathData!.ref.verbCount;
    return List<PathVerb>.generate(count, (int index) {
      return pathVerbDict[_pathData!.ref.verbs[index]]!;
    }, growable: false);
  }

  /// The list of points to use with [verbs].
  ///
  /// Each verb uses a specific number of points, specified by the
  /// [pointsPerVerb] map.
  Float32List get points {
    _updatePathData();
    return _pathData!.ref.points.asTypedList(_pathData!.ref.pointCount);
  }

  void _updatePathData() {
    assert(_path != null);
    _pathData ??= _dataFn(_path!);
  }

  void _resetPathData() {
    if (_pathData != null) {
      _destroyDataFn(_pathData!);
    }
    _pathData = null;
  }

  @override
  void moveTo(double x, double y) {
    assert(_path != null);
    _resetPathData();
    _moveToFn(_path!, x, y);
  }

  @override
  void lineTo(double x, double y) {
    assert(_path != null);
    _resetPathData();
    _lineToFn(_path!, x, y);
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    assert(_path != null);
    _resetPathData();
    _cubicToFn(_path!, x1, y1, x2, y2, x3, y3);
  }

  @override
  void close() {
    assert(_path != null);
    _resetPathData();
    _closeFn(_path!, true);
  }

  @override
  void reset() {
    assert(_path != null);
    _resetPathData();
    _resetFn(_path!);
  }

  /// Releases native resources.
  ///
  /// After calling dispose, this class must not be used again.
  void dispose() {
    assert(_path != null);
    _resetPathData();
    _destroyFn(_path!);
    _path = null;
  }

  /// Applies the operation described by [op] to this path using [other].
  Path applyOp(Path other, PathOp op) {
    assert(_path != null);
    assert(other._path != null);
    final Path result = Path.from(this);
    _opFn(result._path!, other._path!, op.index);
    return result;
  }
}

/// Whether or not PathOps should be used.
bool get isPathOpsInitialized => _isPathOpsInitialized;
bool _isPathOpsInitialized = false;

/// Initialize the libpathops dynamic library.
void initializeLibPathOps(String path) {
  _dylibPath = path;
  _isPathOpsInitialized = true;
}

base class _SkPath extends ffi.Opaque {}

base class _PathData extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> verbs;

  @ffi.Size()
  external int verbCount;

  external ffi.Pointer<ffi.Float> points;

  @ffi.Size()
  external int pointCount;
}

typedef _CreatePathType = ffi.Pointer<_SkPath> Function(int);
typedef _create_path_type = ffi.Pointer<_SkPath> Function(ffi.Int);

final _CreatePathType _createPathFn =
    _dylib.lookupFunction<_create_path_type, _CreatePathType>(
  'CreatePath',
);

typedef _MoveToType = void Function(ffi.Pointer<_SkPath>, double, double);
typedef _move_to_type = ffi.Void Function(
    ffi.Pointer<_SkPath>, ffi.Float, ffi.Float);

final _MoveToType _moveToFn = _dylib.lookupFunction<_move_to_type, _MoveToType>(
  'MoveTo',
);

typedef _LineToType = void Function(ffi.Pointer<_SkPath>, double, double);
typedef _line_to_type = ffi.Void Function(
    ffi.Pointer<_SkPath>, ffi.Float, ffi.Float);

final _LineToType _lineToFn = _dylib.lookupFunction<_line_to_type, _LineToType>(
  'LineTo',
);

typedef _CubicToType = void Function(
    ffi.Pointer<_SkPath>, double, double, double, double, double, double);
typedef _cubic_to_type = ffi.Void Function(ffi.Pointer<_SkPath>, ffi.Float,
    ffi.Float, ffi.Float, ffi.Float, ffi.Float, ffi.Float);

final _CubicToType _cubicToFn =
    _dylib.lookupFunction<_cubic_to_type, _CubicToType>('CubicTo');

typedef _CloseType = void Function(ffi.Pointer<_SkPath>, bool);
typedef _close_type = ffi.Void Function(ffi.Pointer<_SkPath>, ffi.Bool);

final _CloseType _closeFn =
    _dylib.lookupFunction<_close_type, _CloseType>('Close');

typedef _ResetType = void Function(ffi.Pointer<_SkPath>);
typedef _reset_type = ffi.Void Function(ffi.Pointer<_SkPath>);

final _ResetType _resetFn =
    _dylib.lookupFunction<_reset_type, _ResetType>('Reset');

typedef _DestroyType = void Function(ffi.Pointer<_SkPath>);
typedef _destroy_type = ffi.Void Function(ffi.Pointer<_SkPath>);

final _DestroyType _destroyFn =
    _dylib.lookupFunction<_destroy_type, _DestroyType>('DestroyPath');

typedef _OpType = void Function(
    ffi.Pointer<_SkPath>, ffi.Pointer<_SkPath>, int);
typedef _op_type = ffi.Void Function(
    ffi.Pointer<_SkPath>, ffi.Pointer<_SkPath>, ffi.Int);

final _OpType _opFn = _dylib.lookupFunction<_op_type, _OpType>('Op');

typedef _PathDataType = ffi.Pointer<_PathData> Function(ffi.Pointer<_SkPath>);
typedef _path_data_type = ffi.Pointer<_PathData> Function(ffi.Pointer<_SkPath>);

final _PathDataType _dataFn =
    _dylib.lookupFunction<_path_data_type, _PathDataType>('Data');

typedef _DestroyDataType = void Function(ffi.Pointer<_PathData>);
typedef _destroy_data_type = ffi.Void Function(ffi.Pointer<_PathData>);

final _DestroyDataType _destroyDataFn =
    _dylib.lookupFunction<_destroy_data_type, _DestroyDataType>('DestroyData');

typedef _GetFillTypeType = int Function(ffi.Pointer<_SkPath>);
typedef _get_fill_type_type = ffi.Int32 Function(ffi.Pointer<_SkPath>);

final _GetFillTypeType _getFillTypeFn =
    _dylib.lookupFunction<_get_fill_type_type, _GetFillTypeType>('GetFillType');
