import 'package:hooks/hooks.dart';
import 'package:vector_graphics_compiler/build.dart';

void main(List<String> args) {
  build(args, (BuildInput input, BuildOutputBuilder output) async {
    await compileSvg(
      input,
      output,
      name: 'example',
      file: input.packageRoot.resolve('assets/example.svg'),
      // ignore: avoid_redundant_argument_values
      options: const Options(dumpDebug: false),
    );
  });
}
