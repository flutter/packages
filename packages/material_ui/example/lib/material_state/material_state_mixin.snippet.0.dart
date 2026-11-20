// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: MyWidget(
            color: WidgetStateColor.resolveWith((Set<WidgetState> states) {
              return states.contains(WidgetState.focused)
                  ? Colors.orange
                  : Colors.blue;
            }),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );
  }
}

// #region body
class MyWidget extends StatefulWidget {
  const MyWidget({super.key, required this.color, required this.child});

  final WidgetStateColor color;
  final Widget child;

  @override
  State<MyWidget> createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> with MaterialStateMixin<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      onFocusChange: updateMaterialState(WidgetState.focused),
      child: ColoredBox(
        color: widget.color.resolve(materialStates),
        child: widget.child,
      ),
    );
  }
}

// #endregion body
