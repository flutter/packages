import 'package:flutter/material.dart';

import 'scene.dart';
import 'scene_container.dart';

/// A [ListView] showing available [Scenes]. Tapping on a Scene name will setUp
/// the Scene before displaying it.
class SceneList extends StatefulWidget {
  final List<Scene> scenes;

  SceneList({super.key, required this.scenes});

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
        itemBuilder: (context, index) {
          final scene = widget.scenes[index];
          return ListTile(
            title: Text(widget.scenes[index].title),
            onTap: () async {
              await scene.setUp();
              Navigator.of(context).push(
                MaterialPageRoute(
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
