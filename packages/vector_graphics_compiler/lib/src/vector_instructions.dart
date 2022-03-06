import 'geometry/path.dart';
import 'geometry/vertices.dart';
import 'paint.dart';

class VectorInstructions {
  VectorInstructions();

  double width = 0;
  double height = 0;

  final List<Paint> paints = [];
  final List<Path> paths = [];
  final List<IndexedVertices> vertices = [];
  final List<DrawCommand> commands = [];

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

class DrawCommand {
  const DrawCommand(this.objectId, this.paintId, this.type, this.debugString);

  final String? debugString;
  final DrawCommandType type;
  final int objectId;
  final int paintId;
}
