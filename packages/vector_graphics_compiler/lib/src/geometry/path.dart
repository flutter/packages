import 'package:meta/meta.dart';
import 'package:path_parsing/path_parsing.dart';

import 'basic_types.dart';
import 'matrix.dart';
import '../util.dart';

// This is a magic number used by impeller for radius approximation:
// https://github.com/flutter/impeller/blob/a2478aa4939a9a08c6c3810f72e0db42e7383a07/geometry/path_builder.cc#L9
// See https://spencermortensen.com/articles/bezier-circle/ for more information.
const double _kArcApproximationMagic = 0.551915024494;

/// Specifies the winding rule that decies how the interior of a [Path] is
/// calculated.
///
/// This enum is used by the [Path.fillType] property.
///
/// It is compatible with the same enum in `dart:ui`.
enum PathFillType {
  /// The interior is defined by a non-zero sum of signed edge crossings.
  ///
  /// For a given point, the point is considered to be on the inside of the path
  /// if a line drawn from the point to infinity crosses lines going clockwise
  /// around the point a different number of times than it crosses lines going
  /// counter-clockwise around that point.
  nonZero,

  /// The interior is defined by an odd number of edge crossings.
  ///
  /// For a given point, the point is considered to be on the inside of the path
  /// if a line drawn from the point to infinity crosses an odd number of lines.
  evenOdd,
}

/// The available types of path verbs.
///
/// Used by [PathCommand.type].
enum PathCommandType {
  /// A path verb that picks up the pen to move it to another coordinate,
  /// starting a new contour.
  move,

  /// A path verb that draws a line from the current point to a specified
  /// coordinate.
  line,

  /// A path verb that draws a Bezier curve from the current point to a
  /// specified point using two control points.
  cubic,

  /// A path verb that draws a line from the current point to the starting
  /// point of the current contour.
  close,
}

/// An abstract, immutable representation of a path verb and its associated
/// points.
///
/// [Path] objects are collections of [PathCommand]s. To create a path object,
/// use a [PathBuilder]. To create a path object from an SVG path definition,
/// use [parseSvgPathData].
@immutable
abstract class PathCommand {
  const PathCommand._(this.type);

  /// The type of this path command.
  final PathCommandType type;

  /// Returns a new path command transformed by `matrix`.
  PathCommand transformed(AffineMatrix matrix);
}

class LineToCommand extends PathCommand {
  const LineToCommand(this.x, this.y) : super._(PathCommandType.line);

  /// The absolute offset of the destination point for this path from the x
  /// axis.
  final double x;

  /// The absolute offset of the destination point for this path from the y
  /// axis.
  final double y;

  @override
  LineToCommand transformed(AffineMatrix matrix) {
    final Point xy = matrix.transformPoint(Point(x, y));
    return LineToCommand(xy.x, xy.y);
  }

  @override
  int get hashCode => Object.hash(type, x, y);

  @override
  bool operator ==(Object other) {
    return other is LineToCommand && other.x == x && other.y == y;
  }

  @override
  String toString() {
    return '..lineTo($x, $y)';
  }
}

class MoveToCommand extends PathCommand {
  const MoveToCommand(this.x, this.y) : super._(PathCommandType.move);

  /// The absolute offset of the destination point for this path from the x
  /// axis.
  final double x;

  /// The absolute offset of the destination point for this path from the y
  /// axis.
  final double y;

  @override
  MoveToCommand transformed(AffineMatrix matrix) {
    final Point xy = matrix.transformPoint(Point(x, y));
    return MoveToCommand(xy.x, xy.y);
  }

  @override
  int get hashCode => Object.hash(type, x, y);

  @override
  bool operator ==(Object other) {
    return other is MoveToCommand && other.x == x && other.y == y;
  }

  @override
  String toString() {
    return '..moveTo($x, $y)';
  }
}

class CubicToCommand extends PathCommand {
  const CubicToCommand(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3)
      : super._(PathCommandType.cubic);

  /// The absolute offset of the first control point for this path from the x
  /// axis.
  final double x1;

  /// The absolute offset of the first control point for this path from the y
  /// axis.
  final double y1;

  /// The absolute offset of the second control point for this path from the x
  /// axis.
  final double x2;

  /// The absolute offset of the second control point for this path from the x
  /// axis.
  final double y2;

  /// The absolute offset of the destination point for this path from the x
  /// axis.
  final double x3;

  /// The absolute offset of the destination point for this path from the y
  /// axis.
  final double y3;

  @override
  CubicToCommand transformed(AffineMatrix matrix) {
    final Point xy1 = matrix.transformPoint(Point(x1, y1));
    final Point xy2 = matrix.transformPoint(Point(x2, y2));
    final Point xy3 = matrix.transformPoint(Point(x3, y3));
    return CubicToCommand(xy1.x, xy1.y, xy2.x, xy2.y, xy3.x, xy3.y);
  }

  @override
  int get hashCode => Object.hash(type, x1, y1, x2, y2, x3, y3);

  @override
  bool operator ==(Object other) {
    return other is CubicToCommand &&
        other.x1 == x1 &&
        other.y1 == y1 &&
        other.x2 == x2 &&
        other.y2 == y2 &&
        other.x3 == x3 &&
        other.y3 == y3;
  }

  @override
  String toString() {
    return '..cubicTo($x1, $y1, $x2, $y2, $x3, $y3)';
  }
}

class CloseCommand extends PathCommand {
  const CloseCommand() : super._(PathCommandType.close);

  @override
  CloseCommand transformed(AffineMatrix matrix) {
    return this;
  }

  @override
  int get hashCode => type.hashCode;

  @override
  bool operator ==(Object other) {
    return other is CloseCommand;
  }

  @override
  String toString() {
    return '..close()';
  }
}

/// Creates a new builder of [Path] objects.
class PathBuilder implements PathProxy {
  /// Creates a new path builder for paths of the specified fill type.
  ///
  /// By default, will create non-zero filled paths.
  PathBuilder([this.fillType = PathFillType.nonZero]);

  /// Creates a new mutable path builder object from an existing [Path].
  PathBuilder.fromPath(Path path) {
    addPath(path);
    fillType = path.fillType;
  }

  final List<PathCommand> _commands = <PathCommand>[];

  Point _currentSubPathPoint = Point.zero;

  /// The last destination point used by this builder.
  Point get currentPoint => _currentPoint;
  Point _currentPoint = Point.zero;

  @override
  void close() {
    _commands.add(const CloseCommand());
    _currentPoint = _currentSubPathPoint;
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
    _commands.add(CubicToCommand(x1, y1, x2, y2, x3, y3));
    _currentPoint = Point(x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    _commands.add(LineToCommand(x, y));
    _currentPoint = Point(x, y);
  }

  @override
  void moveTo(double x, double y) {
    _commands.add(MoveToCommand(x, y));
    _currentPoint = _currentSubPathPoint = Point(x, y);
  }

  /// Adds the commands of an existing path to the new path being created.
  void addPath(Path other) {
    _commands.addAll(other._commands);
  }

  /// Adds an oval command to new path.
  void addOval(Rect oval) {
    final Point r = Point(oval.width * 0.5, oval.height * 0.5);
    final Point c = Point(
      oval.left + (oval.width * 0.5),
      oval.top + (oval.height * 0.5),
    );
    final Point m = Point(
      _kArcApproximationMagic * r.x,
      _kArcApproximationMagic * r.y,
    );

    moveTo(c.x, c.y - r.y);

    // Top right arc.
    cubicTo(c.x + m.x, c.y - r.y, c.x + r.x, c.y - m.y, c.x + r.x, c.y);

    // Bottom right arc.
    cubicTo(c.x + r.x, c.y + m.y, c.x + m.x, c.y + r.y, c.x, c.y + r.y);

    // Bottom left arc.
    cubicTo(c.x - m.x, c.y + r.y, c.x - r.x, c.y + m.y, c.x - r.x, c.y);

    // Top left arc.
    cubicTo(c.x - r.x, c.y - m.y, c.x - m.x, c.y - r.y, c.x, c.y - r.y);

    close();
  }

  /// Adds a rectangle to the new path.
  void addRect(Rect rect) {
    lineTo(rect.top, rect.right);
    lineTo(rect.bottom, rect.right);
    lineTo(rect.bottom, rect.left);
    close();
  }

  /// Adds a rounded rectangle to the new path.
  void addRRect(Rect rect, double rx, double ry) {
    if (rx == 0 && ry == 0) {
      addRect(rect);
      return;
    }

    final magicRadius = Point(rx, ry) * _kArcApproximationMagic;

    moveTo(rect.left + rx, rect.top);

    // Top line.
    lineTo(rect.left + rect.width - rx, rect.top);

    // Top right arc.
    //
    cubicTo(
      rect.left + rect.width - rx + magicRadius.x,
      rect.top,
      rect.left + rect.width,
      rect.top + ry - magicRadius.y,
      rect.left + rect.width,
      rect.top + ry,
    );

    // Right line.
    lineTo(rect.left + rect.width, rect.top + rect.height - ry);

    // Bottom right arc.
    cubicTo(
      rect.left + rect.width,
      rect.top + rect.height - ry + magicRadius.y,
      rect.left + rect.width - rx + magicRadius.x,
      rect.top + rect.height,
      rect.left + rect.width - rx,
      rect.top + rect.height,
    );

    // Bottom line.
    lineTo(rect.left + rx, rect.top + rect.height);

    // Bottom left arc.
    cubicTo(
        rect.left + rx - magicRadius.x,
        rect.top + rect.height,
        rect.left,
        rect.top + rect.height - ry + magicRadius.y,
        rect.left,
        rect.top + rect.height - ry);

    // Left line.
    lineTo(rect.left, rect.top + ry);

    // Top left arc.
    cubicTo(
      rect.left,
      rect.top + ry - magicRadius.y,
      rect.left + rx - magicRadius.x,
      rect.top,
      rect.left + rx,
      rect.top,
    );

    close();
  }

  /// The fill type to use for the new path.
  late PathFillType fillType;

  /// Creates a new [Path] object from the commands in this path.
  ///
  /// If `reset` is set to false, this builder can be used to create multiple
  /// path objects with the same commands. By default, the builder will reset
  /// to an initial state.
  Path toPath({bool reset = true}) {
    // TODO: bounds
    Rect bounds = Rect.zero;

    final Path path = Path(
      commands: _commands,
      fillType: fillType,
      bounds: bounds,
    );

    if (reset) {
      _commands.clear();
    }
    return path;
  }
}

/// An immutable collection of [PathCommand]s.
@immutable
class Path {
  /// Creates a new immutable collection of [PathCommand]s.
  Path({
    List<PathCommand> commands = const <PathCommand>[],
    this.fillType = PathFillType.nonZero,
    required this.bounds,
  }) {
    _commands.addAll(commands);
  }

  /// Whether this path has any commands.
  bool get isEmpty => _commands.isEmpty;

  /// The commands this path contains.
  Iterable<PathCommand> get commands => _commands;

  final List<PathCommand> _commands = <PathCommand>[];

  /// The fill type of this path, defaulting to [PathFillType.nonZero].
  final PathFillType fillType;

  /// The bounds of this path object.
  final Rect bounds;

  Path transformed(AffineMatrix matrix) {
    final List<PathCommand> commands = <PathCommand>[];
    for (final PathCommand command in _commands) {
      commands.add(command.transformed(matrix));
    }
    return Path(
      commands: commands,
      fillType: fillType,
      // TODO: is this safe? What the commands have degenerated? Should probably
      // recalculate this.
      bounds: matrix.transformRect(bounds),
    );
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(_commands), fillType);

  @override
  bool operator ==(Object other) {
    return other is Path &&
        listEquals(_commands, other._commands) &&
        other.fillType == fillType &&
        other.bounds == bounds;
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('Path()');
    if (fillType != PathFillType.nonZero) {
      buffer.write('\n  ..fillType = $fillType');
    }
    for (final command in commands) {
      buffer.write('\n  $command');
    }
    buffer.write(';');
    return buffer.toString();
  }
}

/// Creates a new [Path] object from an SVG path data string.
Path parseSvgPathData(String svg) {
  if (svg == '') {
    return Path(bounds: Rect.zero);
  }

  final SvgPathStringSource parser = SvgPathStringSource(svg);
  final PathBuilder pathBuilder = PathBuilder();
  final SvgPathNormalizer normalizer = SvgPathNormalizer();
  for (PathSegmentData seg in parser.parseSegments()) {
    normalizer.emitSegment(seg, pathBuilder);
  }
  return pathBuilder.toPath();
}
