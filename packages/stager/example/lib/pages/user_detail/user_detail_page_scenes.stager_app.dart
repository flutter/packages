// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StagerAppGenerator
// **************************************************************************

import 'user_detail_page_scenes.dart';

import 'package:stager/stager.dart';

void main() {
  final scenes = [
    LoadingUserDetailPageScene(),
    ErrorUserDetailPageScene(),
    EmptyUserDetailPageScene(),
    WithPostsUserDetailPageScene(),
    ComplexUserDetailPageScene(),
  ];

  if (const String.fromEnvironment('Scene').isNotEmpty) {
    const sceneName = String.fromEnvironment('Scene');
    final scene = scenes.firstWhere((scene) => scene.title == sceneName);
    runStagerApp(scenes: [scene]);
  } else {
    runStagerApp(scenes: scenes);
  }
}
