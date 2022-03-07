import 'paint.dart';
import 'vector_instructions.dart';

abstract class Optimizer {
  const Optimizer();

  VectorInstructions optimize(VectorInstructions original);
}

class PaintDeduplicator extends Optimizer {
  const PaintDeduplicator();

  @override
  VectorInstructions optimize(VectorInstructions original) {
    final VectorInstructions result = VectorInstructions();
    result.paths.addAll(original.paths);
    final Map<Paint, int> paints = <Paint, int>{};
    for (final command in original.commands) {
      final originalPaint = original.paints[command.paintId];
      final int paintId = paints.putIfAbsent(
        original.paints[command.paintId],
        () {
          result.paints.add(originalPaint);
          return result.paints.length - 1;
        },
      );
      result.commands.add(DrawCommand(
        command.objectId,
        paintId,
        command.type,
        command.debugString,
      ));
      print(result.commands.last);
    }
    return result;
  }
}
