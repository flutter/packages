// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// The demo page for [FadeScaleTransition].
class FadeScaleTransitionDemo extends StatefulWidget {
  @override
  _FadeScaleTransitionDemoState createState() =>
      _FadeScaleTransitionDemoState();
}

class _FadeScaleTransitionDemoState extends State<FadeScaleTransitionDemo>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  bool shouldEnter = true;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 75),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateAnimationController() {
    switch (controller.status) {
      case AnimationStatus.completed:
      case AnimationStatus.forward:
        controller.reverse();
        setState(() {
          shouldEnter = true;
        });
        break;
      case AnimationStatus.dismissed:
      case AnimationStatus.reverse:
        controller.forward();
        setState(() {
          shouldEnter = false;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fade Transition Demo'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 200,
                  child: Center(
                    child: FadeScaleTransition(
                      animation: controller,
                      child: _ExampleAlertDialog(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 2.0),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: updateAnimationController,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  child: shouldEnter
                      ? const Text('FADE ENTER')
                      : const Text('FADE EXIT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text('Alert Dialog'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {},
          child: const Text('CANCEL'),
        ),
        FlatButton(
          onPressed: () {},
          child: const Text('DISCARD'),
        ),
      ],
    );
  }
}
