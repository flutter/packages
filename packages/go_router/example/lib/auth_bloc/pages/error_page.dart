// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// if navigation has some error, show this page.
class ErrorPage extends StatefulWidget {
  /// Creates an [HomePage].
  const ErrorPage({
    Key? key,
    required this.exception,
  }) : super(key: key);

  /// error message
  final Exception? exception;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Error'),
      ),
      body: Center(
        child: Text(widget.exception.toString()),
      ),
    );
  }
}
