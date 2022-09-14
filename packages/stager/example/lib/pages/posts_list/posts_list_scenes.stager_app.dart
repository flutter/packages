// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StagerAppGenerator
// **************************************************************************

import 'package:stager/stager.dart';

import 'posts_list_page_scenes.dart';

// #docregion StagerMain
void main() {
  final List<StagerScene> scenes = <StagerScene>[
    EmptyListScene(),
    WithPostsScene(),
    LoadingScene(),
    ErrorScene(),
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
// #enddocregion StagerMain
