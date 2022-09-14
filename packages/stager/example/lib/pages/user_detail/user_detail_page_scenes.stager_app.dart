// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StagerAppGenerator
// **************************************************************************

import 'package:stager/stager.dart';

import 'user_detail_page_scenes.dart';

void main() {
  final List<Scene> scenes = <Scene>[
    LoadingUserDetailPageScene(),
    ErrorUserDetailPageScene(),
    EmptyUserDetailPageScene(),
    WithPostsUserDetailPageScene(),
    ComplexUserDetailPageScene(),
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
