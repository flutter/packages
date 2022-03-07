import 'package:meta/meta.dart';

import 'geometry/path.dart';
import 'geometry/vertices.dart';
import 'paint.dart';

class VectorInstructions {
  VectorInstructions();

  double width = 0;
  double height = 0;

  final List<Paint> paints = <Paint>[];
  final List<Path> paths = <Path>[];
  final List<IndexedVertices> vertices = <IndexedVertices>[];
  final List<DrawCommand> commands = <DrawCommand>[];

  void addDrawPath(Path path, Paint paint, String? debugString) {
    commands.add(DrawCommand(
      paths.length,
      paints.length,
      DrawCommandType.path,
      debugString,
    ));
    paints.add(paint);
    paths.add(path);
  }
}

enum DrawCommandType {
  path,
  vertices,
}

@immutable
class DrawCommand {
  const DrawCommand(this.objectId, this.paintId, this.type, this.debugString);

  final String? debugString;
  final DrawCommandType type;
  final int objectId;
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
