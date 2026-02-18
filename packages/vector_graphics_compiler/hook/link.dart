import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:vector_graphics_compiler/build.dart';

Future<void> main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    await compileSvgs(
      input,
      output,
      nameToFile: Map.fromEntries(
        input.assets.data.map((e) => MapEntry(e.name, e.file)),
      ),
    );
  });
}
