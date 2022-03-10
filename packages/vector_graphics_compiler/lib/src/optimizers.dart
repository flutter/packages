import 'paint.dart';
import 'vector_instructions.dart';

/// An optimization pass for a [VectorInstructions] object.
///
/// For example, an optimizer may de-duplicate objects or transform objects
/// into more efficiently drawable objects.
///
/// Optimizers are composable, but may expect certain ordering to reach maximum
/// efficiency.
abstract class Optimizer {
  /// Allows inheriting classes to create const instances.
  const Optimizer();

  /// Takes `original` and produces a new object that is optimized.
  VectorInstructions optimize(VectorInstructions original);
}

/// An optimizer that removes duplicate [Paint] objects and rewrites
/// [DrawCommand]s to refer to the updated paint index.
///
/// The resulting [VectorInstructions.paints] is effectively the original paint
/// list converted to a set and then back to a list.
class PaintDeduplicator extends Optimizer {
  /// Creates a new paint deduplicator.
  const PaintDeduplicator();

  @override
  VectorInstructions optimize(VectorInstructions original) {
    final VectorInstructions result = VectorInstructions(
      width: original.width,
      height: original.height,
      paths: original.paths,
      paints: <Paint>[],
      commands: <DrawCommand>[],
    );

    final Map<Paint, int> paints = <Paint, int>{};
    for (final DrawCommand command in original.commands) {
      if (command.paintId == -1) {
        result.commands.add(command);
        continue;
      }
      final Paint originalPaint = original.paints[command.paintId];
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
    }
    return result;
  }
}
