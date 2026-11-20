// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: MyWidget(onPressed: onPressed),
          ),
        ),
      ),
    );
  }
}

// #region body
class MyWidget extends StatefulWidget {
  const MyWidget({super.key, this.onPressed});

  /// Something important this widget must do when pressed.
  final VoidCallback? onPressed;

  @override
  State<MyWidget> createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> with MaterialStateMixin<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isPressed ? Colors.black : Colors.white,
      child: InkWell(
        onTap: () {},
        onHighlightChanged: updateMaterialState(
          WidgetState.pressed,
          onChanged: (bool val) {
            if (val) {
              widget.onPressed?.call();
            }
          },
        ),
      ),
    );
  }
}

// #endregion body
