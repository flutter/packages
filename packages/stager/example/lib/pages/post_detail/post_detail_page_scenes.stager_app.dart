// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StagerAppGenerator
// **************************************************************************

import 'package:stager/stager.dart';

import 'post_detail_page_scenes.dart';

void main() {
  final List<Scene> scenes = <Scene>[
    PostDetailPageScene(),
  ];

  if (const String.fromEnvironment('Scene').isNotEmpty) {
    const String sceneName = String.fromEnvironment('Scene');
    final Scene scene =
        scenes.firstWhere((Scene scene) => scene.title == sceneName);
    runStagerApp(scenes: <Scene>[scene]);
  } else {
    runStagerApp(scenes: scenes);
  }
}
