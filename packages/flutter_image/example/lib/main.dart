// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';

void main() => runApp(const MyApp());

/// The main app
class MyApp extends StatelessWidget {
  /// Contructs main app
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'flutter_image example app',
      home: HomeScreen(imageUrl: 'https://picsum.photos/250?image=9'),
    );
  }
}

/// The home screen
class HomeScreen extends StatelessWidget {
  /// Contructs a [HomeScreen]
  const HomeScreen({
    super.key,
    required this.imageUrl,
  });

  /// URL of the network image
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    const int maxAttempt = 3;
    const Duration attemptTimeout = Duration(seconds: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Image example'),
      ),
      body: Center(
        child: Image(
          image: NetworkImageWithRetry(
            imageUrl,
            scale: 0.8,
            fetchStrategy: (Uri uri, FetchFailure? failure) async {
              final FetchInstructions fetchInstruction =
                  FetchInstructions.attempt(
                uri: uri,
                timeout: attemptTimeout,
              );

              if (failure != null && failure.attemptCount > maxAttempt) {
                return FetchInstructions.giveUp(uri: uri);
              }

              return fetchInstruction;
            },
          ),
        ),
      ),
    );
  }
}
