import 'geometry/path.dart';
import 'paint.dart';
import 'vector_instructions.dart';

/// An interface for building up a stack of vector commands.
class DrawCommandBuilder {
  final Map<Paint, int> _paints = <Paint, int>{};
  final Map<Path, int> _paths = <Path, int>{};
  final List<DrawCommand> _commands = <DrawCommand>[];

  int _getOrGenerateId<T>(T object, Map<T, int> map) =>
      map.putIfAbsent(object, () => map.length);

  /// Add a save layer to the command stack.
  void addSaveLayer(Paint paint) {
    assert(paint.fill!.color != null);

    final int paintId = _getOrGenerateId(paint, _paints);
    _commands.add(DrawCommand(
      DrawCommandType.saveLayer,
      paintId: paintId,
    ));
  }

  /// Add a restore to the command stack.
  void restore() {
    _commands.add(const DrawCommand(DrawCommandType.restore));
  }

  /// Adds a clip to the command stack.
  void addClip(Path path) {
    final int pathId = _getOrGenerateId(path, _paths);
    _commands.add(DrawCommand(DrawCommandType.clip, objectId: pathId));
  }

  /// Adds a mask to the command stack.
  void addMask() {
    _commands.add(const DrawCommand(DrawCommandType.mask));
  }

  /// Add a path to the current draw command stack
  void addPath(Path path, Paint paint, String? debugString) {
    final int pathId = _getOrGenerateId(path, _paths);
    final int paintId = _getOrGenerateId(paint, _paints);
    _commands.add(DrawCommand(
      DrawCommandType.path,
      objectId: pathId,
      paintId: paintId,
      debugString: debugString,
    ));
  }

  /// Create a new [VectorInstructions] with the given width and height.
  VectorInstructions toInstructions(double width, double height) {
    return VectorInstructions(
      width: width,
      height: height,
      paints: _paints.keys.toList(),
      paths: _paths.keys.toList(),
      commands: _commands,
    );
  }
}
