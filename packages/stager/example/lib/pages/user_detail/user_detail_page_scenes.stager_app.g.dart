// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StagerAppGenerator
// **************************************************************************

import 'package:stager/stager.dart';

import 'user_detail_page_scenes.dart';

void main() {
  final List<StagerScene> scenes = <StagerScene>[
    LoadingUserDetailPageScene(),
    ErrorUserDetailPageScene(),
    EmptyUserDetailPageScene(),
    WithPostsUserDetailPageScene(),
    ComplexUserDetailPageScene(),
  ];

  if (const String.fromEnvironment('Scene').isNotEmpty) {
    const String sceneName = String.fromEnvironment('Scene');
    final StagerScene scene =
        scenes.firstWhere((StagerScene scene) => scene.title == sceneName);
    runStagerApp(scenes: <StagerScene>[scene]);
  } else {
    runStagerApp(scenes: scenes);
  }
}
