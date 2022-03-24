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
  /// In this case, both the objectId and paintId will be `null`.
  restore,

  /// Specifies that this command adds a clip to the stack.
  ///
  /// In this case, the objectId will be for a path, and the paint id will be
  /// `null`.
  clip,

  /// Specifies that this command adds a mask to the stack.
  ///
  /// Implementations should save a layer using a grey scale color matrix.
  mask,
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
  const DrawCommand(this.type, {this.objectId, this.paintId, this.debugString});

  /// A string, possibly from the original source SVG file, identifying a source
  /// for this command.
  final String? debugString;

  /// Whether [objectId] points to a [Path] or a [IndexedVertices] object in
  /// [VectorInstructions].
  final DrawCommandType type;

  /// The path or vertices object index in [VectorInstructions.paths] or
  /// [VectorInstructions.vertices].
  ///
  /// A value of `null` indicates that there is no object associated with
  /// this command.
  ///
  /// Use [type] to determine which type of object this is.
  final int? objectId;

  /// The index of a [Paint] for this object in [VectorInstructions.paints].
  ///
  /// A value of `null` indicates that there is no paint object associated with
  /// this command.
  final int? paintId;

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
  String toString() {
    final StringBuffer buffer = StringBuffer('DrawCommand($type');
    if (objectId != null) {
      buffer.write(', objectId: $objectId');
    }
    if (paintId != null) {
      buffer.write(', paintId: $paintId');
    }
    if (debugString != null) {
      buffer.write(", debugString: '$debugString'");
    }
    buffer.write(')');
    return buffer.toString();
  }
}
