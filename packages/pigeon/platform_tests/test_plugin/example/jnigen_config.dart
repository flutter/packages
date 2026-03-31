// ignore_for_file: prefer_const_constructors
import 'package:jnigen/jnigen.dart';
import 'package:logging/logging.dart';

void main() async {
  await generateJniBindings(
    Config(
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: './',
      ),
      summarizerOptions: SummarizerOptions(backend: SummarizerBackend.asm),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: Uri.file(
            '../../shared_test_plugin_code/lib/src/generated/ni_tests.gen.jni.dart',
          ),
          structure: OutputStructure.singleFile,
        ),
      ),
      logLevel: Level.ALL,
      classes: [
        'NiTestsError',
        'NIHostIntegrationCoreApi',
        'NIHostIntegrationCoreApiRegistrar',
        'NIFlutterIntegrationCoreApi',
        'NIFlutterIntegrationCoreApiRegistrar',
        'NIUnusedClass',
        'NIAllTypes',
        'NIAllNullableTypes',
        'NIAllNullableTypesWithoutRecursion',
        'NIAllClassesWrapper',
        'NIAnEnum',
        'NIAnotherEnum',
      ],
    ),
  );
}
