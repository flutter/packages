// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'extensions.dart';

/// Default error page implementation for WidgetsApp.
class ErrorScreen extends StatelessWidget {
  /// Provide an exception to this page for it to be displayed.
  const ErrorScreen(this.error, {super.key});

  /// The exception to be displayed.
  final Exception? error;

  static const Color _kWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Page Not Found',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(error?.toString() ?? 'page not found'),
          const SizedBox(height: 16),
          _Button(
            onPressed: () => context.go('/'),
            child: const Text(
              'Go to home page',
              style: TextStyle(color: _kWhite),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Button extends StatefulWidget {
  const _Button({required this.onPressed, required this.child});

  final VoidCallback onPressed;

  /// The child subtree.
  final Widget child;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  late final Color _color;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _color =
        (context as Element)
            .findAncestorWidgetOfExactType<WidgetsApp>()
            ?.color ??
        const Color(0xFF2196F3); // blue
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onPressed,
    child: Container(
      padding: const EdgeInsets.all(8),
      color: _color,
      child: widget.child,
    ),
  );
}
