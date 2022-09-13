// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StagerAppGenerator
// **************************************************************************

import 'posts_list_page_scenes.dart';

import 'package:stager/stager.dart';

void main() {
  final scenes = [
    EmptyListScene(),
    WithPostsScene(),
    LoadingScene(),
    ErrorScene(),
  ];

  if (const String.fromEnvironment('Scene').isNotEmpty) {
    const sceneName = String.fromEnvironment('Scene');
    final scene = scenes.firstWhere((scene) => scene.title == sceneName);
    runStagerApp(scenes: [scene]);
  } else {
    runStagerApp(scenes: scenes);
  }
}
