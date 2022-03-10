import 'package:meta/meta.dart';

import 'geometry/path.dart';
import 'geometry/vertices.dart';
import 'paint.dart';

/// An immutable collection of vector instructions, with [width] and [height]
/// specifying the viewport coordinates.
class VectorInstructions {
  /// Creates a new set of [VectorInstructions].
  ///
  /// The combined lengths of [paths] and [vertices] must be greater than 0.
  const VectorInstructions(
      {required this.width,
      required this.height,
      required this.paints,
      this.paths = const <Path>[],
      this.vertices = const <IndexedVertices>[],
      required this.commands});

  /// The extent of the viewport on the x axis.
  final double width;

  /// The extent of the viewport on the y axis.
  final double height;

  /// The [Paint] objects used in [commands].
  final List<Paint> paints;

  /// The [Path] objects, if any, used in [commands].
  final List<Path> paths;

  /// The [IndexedVertices] objects, if any, used in [commands].
  final List<IndexedVertices> vertices;

  /// The painting order list of drawing commands.
  ///
  /// If the command type is [DrawCommandType.path], this command specifies
  /// drawing with [paths]. If it is [DrawCommandType.vertices], this command
  /// specifies drawing with [vertices].
  ///
  /// If drawing using vertices, the [Paint.stroke] property is ignored.
  final List<DrawCommand> commands;

  @override
  String toString() => 'VectorInstructions($width, $height)';
}

/// The drawing mode of a [DrawCommand].
///
/// See [DrawCommand.type] and [VectorInstructions.commands].
enum DrawCommandType {
  /// Specifies that this command draws a [Path].
  path,

  /// Specifies that this command draws an [IndexedVertices] object.
  ///
  /// In this case, any [Stroke] properties on the [Paint] are ignored.
  vertices,

  /// Specifies that this command saves a layer.
  ///
  /// In this case, any [Stroke] properties on the [Paint] are ignored.
  saveLayer,

  /// Specifies that this command restores a layer.
  ///
  /// In this case, both the objectId and paintId will be `-1`.
  restore,
}

/// A drawing command combining the index of a [Path] or an [IndexedVertices]
/// with a [Paint].
///
/// The type of object is specified by [type].
///
/// The debug string property is some identifier, possibly from the source SVG,
/// identifying an original source for this information.
@immutable
class DrawCommand {
  /// Creates a new canvas drawing operation.
  ///
  /// See [DrawCommand].
  const DrawCommand(this.objectId, this.paintId, this.type, this.debugString);

  /// A string, possibly from the original source SVG file, identifying a source
  /// for this command.
  final String? debugString;

  /// Whether [objectId] points to a [Path] or a [IndexedVertices] object in
  /// [VectorInstructions].
  final DrawCommandType type;

  /// The path or vertices object index in [VectorInstructions.paths] or
  /// [VectorInstructions.vertices].
  ///
  /// A value of `-1` indicates that there is no object associated with
  /// this command.
  ///
  /// Use [type] to determine which type of object this is.
  final int objectId;

  /// The index of a [Paint] for this object in [VectorInstructions.paints].
  final int paintId;

  @override
  int get hashCode => Object.hash(type, objectId, paintId, debugString);

  @override
  bool operator ==(Object other) {
    return other is DrawCommand &&
        other.type == type &&
        other.objectId == objectId &&
        other.paintId == paintId;
  }

  @override
  String toString() =>
      'DrawCommand($objectId, $paintId, $type, \'$debugString\')';
}
