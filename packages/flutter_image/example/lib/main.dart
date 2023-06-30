import 'package:flutter/material.dart';
import 'package:flutter_image/flutter_image.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'flutter_image example app',
      home: RetryNetworkImage(imageUrl: 'https://picsum.photos/250?image=9'),
    );
  }
}

class RetryNetworkImage extends StatelessWidget {
  final String imageUrl;

  const RetryNetworkImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    int maxAttempt = 3;
    Duration attemptTimeout = const Duration(seconds: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Image example'),
      ),
      body: Center(
        child: Image(
          image: NetworkImageWithRetry(
            imageUrl,
            scale: 0.8,
            fetchStrategy: (uri, failure) async {
              final fetchInstruction = FetchInstructions.attempt(
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
