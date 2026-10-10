// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [DropdownButton.builder].

void main() => runApp(const DropdownButtonBuilderApp());

class DropdownButtonBuilderApp extends StatelessWidget {
  const DropdownButtonBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('DropdownButton.builder Sample')),
        body: const Center(child: DropdownButtonBuilderExample()),
      ),
    );
  }
}

class DropdownButtonBuilderExample extends StatefulWidget {
  const DropdownButtonBuilderExample({super.key});

  @override
  State<DropdownButtonBuilderExample> createState() => _DropdownButtonBuilderExampleState();
}

class _DropdownButtonBuilderExampleState extends State<DropdownButtonBuilderExample> {
  int? dropdownValue = 100;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>.builder(
      selectedItemIndex: dropdownValue,
      itemCount: 10000,
      itemBuilder: (BuildContext context, int index) {
        return DropdownMenuItem<int>(value: index, child: Text('Item $index'));
      },
      customSelectedItemBuilder: (BuildContext context, int? value) {
        return Text('Selected Lazy Item $value');
      },
      onChanged: (int? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value;
        });
      },
    );
  }
}
// #endregion body
