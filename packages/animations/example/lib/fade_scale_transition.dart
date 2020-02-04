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
  AnimationController _controller;

  bool _showFab = true;

  @override
  void initState() {
    _controller = AnimationController(
      value: 1.0,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 75),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fade'),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget child) {
          return FadeScaleTransition(
            animation: _controller,
            child: child,
          );
        },
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {},
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Divider(height: 0.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    showModal<void>(
                      context: context,
                      configuration: FadeScaleTransitionConfiguration(),
                      builder: (BuildContext context) {
                        return _ExampleAlertDialog();
                      },
                    );
                  },
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  child: const Text('SHOW MODAL'),
                ),
                const SizedBox(width: 10),
                RaisedButton(
                  onPressed: () {
                    if (_showFab) {
                      setState(() {
                        _showFab = false;
                      });
                      _controller.reverse();
                    } else {
                      setState(() {
                        _showFab = true;
                      });
                      _controller.forward();
                    }
                  },
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  child: _showFab
                      ? const Text('HIDE FAB')
                      : const Text('SHOW FAB'),
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('DISCARD'),
        ),
      ],
    );
  }
}
