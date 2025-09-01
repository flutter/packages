import 'package:hooks/hooks.dart';
import 'package:vector_graphics_compiler/build.dart';

void main(List<String> args) {
  build(args, (input, output) async {
    await svgBuilder(input, output, {
      'example': input.packageRoot.resolve('assets/example.svg'),
    });
  });
}
