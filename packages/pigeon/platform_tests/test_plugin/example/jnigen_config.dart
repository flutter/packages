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
        'com.example.test_plugin.NiTestsError',
        'com.example.test_plugin.NIHostIntegrationCoreApi',
        'com.example.test_plugin.NIHostIntegrationCoreApiRegistrar',
        'com.example.test_plugin.NIFlutterIntegrationCoreApi',
        'com.example.test_plugin.NIFlutterIntegrationCoreApiRegistrar',
        'com.example.test_plugin.NIUnusedClass',
        'com.example.test_plugin.NIAllTypes',
        'com.example.test_plugin.NIAllNullableTypes',
        'com.example.test_plugin.NIAllNullableTypesWithoutRecursion',
        'com.example.test_plugin.NIAllClassesWrapper',
        'com.example.test_plugin.NIAnEnum',
        'com.example.test_plugin.NIAnotherEnum',
      ],
    ),
  );
}
