// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NetworkImageWithRetry Demo',
      home: NetworkImageWithRetryDemo(),
    );
  }
}

class NetworkImageWithRetryDemo extends StatefulWidget {
  const NetworkImageWithRetryDemo({super.key});

  @override
  State<NetworkImageWithRetryDemo> createState() =>
      _NetworkImageWithRetryDemoState();
}

class _NetworkImageWithRetryDemoState extends State<NetworkImageWithRetryDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo'),
      ),
      body: const Center(
        child: Image(
          image: NetworkImageWithRetry('https://picsum.photos/250?image=9'),
        ),
      ),
    );
  }
}
