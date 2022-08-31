import 'package:flutter/material.dart';
// #docregion import
import 'package:dynamic_layouts/dynamic_layouts.dart';
// #enddocregion import

void main() {
  runApp(const StaggeredLayout());
}

class StaggeredLayout extends StatefulWidget {
  const StaggeredLayout({super.key});

  @override
  State<StaggeredLayout> createState() => _StaggeredLayoutState();
}

class _StaggeredLayoutState extends State<StaggeredLayout> {
  final List<Widget> children = List.generate(
    50,
    (int index) => DynamicSizedTile(index: index),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Staggered Layout Example"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              children.add(DynamicSizedTile(index: children.length));
            });
          },
          child: const Icon(Icons.plus_one),
        ),
        body: DynamicGridView.staggered(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          children: [...children],
        ),
      ),
    );
  }
}

class DynamicSizedTile extends StatelessWidget {
  const DynamicSizedTile({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: index % 3 * 50 + 20,
      color: Colors.amber[index % 9 * 100],
      child: Center(child: Text("Index $index")),
    );
  }
}
