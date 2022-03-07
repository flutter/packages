import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'package:test/test.dart';

void main() {
  test('Deduplicator preserves width/height', () {
    const VectorInstructions original = VectorInstructions(
      width: 10,
      height: 20,
      paints: <Paint>[],
      commands: <DrawCommand>[],
    );

    final VectorInstructions optimized =
        const PaintDeduplicator().optimize(original);
    expect(optimized.width, original.width);
    expect(optimized.height, original.height);
  });

  test('Deduplicator removes duplicated paints', () {
    final VectorInstructions original = VectorInstructions(
      width: 10,
      height: 20,
      paints: <Paint>[],
      commands: <DrawCommand>[],
      paths: <Path>[Path()],
    );

    const Paint paintA = Paint(blendMode: BlendMode.color);
    const Paint paintB = Paint(blendMode: BlendMode.darken);
    original.paints.addAll(List<Paint>.filled(4, paintA));
    original.paints.addAll(List<Paint>.filled(4, paintB));

    original.paints.addAll(List<Paint>.filled(2, paintA));

    original.commands.addAll(List<DrawCommand>.generate(
      original.paints.length,
      (int index) => DrawCommand(0, index, DrawCommandType.path, ''),
    ));

    final VectorInstructions optimized =
        const PaintDeduplicator().optimize(original);

    expect(optimized.paints, const <Paint>[paintA, paintB]);
    expect(optimized.paths, <Path>[Path()]);
    expect(optimized.commands, const <DrawCommand>[
      DrawCommand(0, 0, DrawCommandType.path, ''),
      DrawCommand(0, 0, DrawCommandType.path, ''),
      DrawCommand(0, 0, DrawCommandType.path, ''),
      DrawCommand(0, 0, DrawCommandType.path, ''),
      DrawCommand(0, 1, DrawCommandType.path, ''),
      DrawCommand(0, 1, DrawCommandType.path, ''),
      DrawCommand(0, 1, DrawCommandType.path, ''),
      DrawCommand(0, 1, DrawCommandType.path, ''),
      DrawCommand(0, 0, DrawCommandType.path, ''),
      DrawCommand(0, 0, DrawCommandType.path, ''),
    ]);
  });
}
