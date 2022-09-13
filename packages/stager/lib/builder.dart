import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/stager_app_generator.dart';

Builder buildStagerApp(BuilderOptions options) => LibraryBuilder(
      StagerAppGenerator(),
      generatedExtension: '.stager_app.dart',
    );
