// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'scene_container.dart';
import 'stager_scene.dart';

/// A [ListView] showing available [Scenes]. Tapping on a Scene name will setUp
/// the Scene before displaying it.
class SceneList extends StatefulWidget {
  /// Creates a [SceneList] widget.
  const SceneList({super.key, required this.scenes});

  /// The list of [StagerScene]s displayed by this widget.
  final List<StagerScene> scenes;

  @override
  State<SceneList> createState() => _SceneListState();
}

class _SceneListState extends State<SceneList> {
  @override
  Widget build(BuildContext context) {
    if (widget.scenes.length == 1) {
      return SceneContainer(
        child: widget.scenes.first.build(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scenes')),
      body: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          final StagerScene scene = widget.scenes[index];
          return ListTile(
            title: Text(widget.scenes[index].title),
            onTap: () async {
              await scene.setUp();
              if (!mounted) {
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SceneContainer(
                    child: scene.build(),
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: widget.scenes.length,
      ),
    );
  }
}
