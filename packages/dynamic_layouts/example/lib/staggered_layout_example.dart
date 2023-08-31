// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dynamic_layouts/dynamic_layouts.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const StaggeredExample());
}

/// A staggered layout example. Clicking the upper-right button will change
/// between a grid with a fixed cross axis count and one with a main axis
/// extent.
class StaggeredExample extends StatefulWidget {
  /// Creates a [StaggeredExample].
  const StaggeredExample({super.key});

  @override
  State<StaggeredExample> createState() => _StaggeredExampleState();
}

class _StaggeredExampleState extends State<StaggeredExample> {
  final List<Widget> children = List<Widget>.generate(
    50,
    (int index) => _DynamicSizedTile(index: index),
  );

  bool fixedCrossAxisCount = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staggered Layout Example'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  fixedCrossAxisCount = !fixedCrossAxisCount;
                });
              },
              child: Text(
                fixedCrossAxisCount ? 'FIXED' : 'MAX',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            children.add(_DynamicSizedTile(index: children.length));
          });
        },
        child: const Icon(Icons.plus_one),
      ),
      body: fixedCrossAxisCount
          ? DynamicGridView.staggered(
              crossAxisCount: 4,
              children: <Widget>[...children],
            )
          : DynamicGridView.staggered(
              maxCrossAxisExtent: 100,
              children: <Widget>[...children],
            ),
    );
  }
}

class _DynamicSizedTile extends StatelessWidget {
  const _DynamicSizedTile({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: index % 3 * 50 + 20,
      color: Colors.amber[(index % 8 + 1) * 100],
      child: Text('Index $index'),
    );
  }
}
