// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';

void main() => runApp(const MyApp());

/// The main app.
class MyApp extends StatelessWidget {
  /// Contructs main app.
  const MyApp({super.key});

  /// Returns the URL to load an asset from this example app as a network source.
  String getUrlForAssetAsNetworkSource(String assetKey) {
    return 'https://github.com/flutter/packages/blob/b96a6dae0ca418cf1e91633f275866aa9cffe437/packages/flutter_image/example/$assetKey?raw=true';
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        getUrlForAssetAsNetworkSource('assets/flutter-mark-square-64.png');

    return MaterialApp(
      title: 'flutter_image example app',
      home: HomeScreen(imageUrl: imageUrl),
    );
  }
}

/// The home screen.
class HomeScreen extends StatelessWidget {
  /// Contructs a [HomeScreen]
  const HomeScreen({
    super.key,
    required this.imageUrl,
  });

  /// URL of the network image.
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
