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
