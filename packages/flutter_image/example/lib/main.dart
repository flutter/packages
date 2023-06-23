import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_image/network.dart';

void main() {
  runApp(const MainApp());
}

const _attemptsLimit = 3;
const _attemptTimeout = Duration(seconds: 2);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: NetworkImageWithRetry(
                'https://github.com/firebase/flutterfire/assets/59893892/82f43614-6cdb-4e4b-8e53-046f7c0714cc',
                scale: 1.5,
                fetchStrategy: (uri, failure) async {
                  final attemptInstruction = FetchInstructions.attempt(
                    uri: uri,
                    timeout: _attemptTimeout,
                  );

                  if (failure == null) return attemptInstruction;

                  if (failure.attemptCount > _attemptsLimit) {
                    return FetchInstructions.giveUp(
                      uri: uri,
                    );
                  }

                  return attemptInstruction;
                },
                headers: <String, Object>{
                  'Authorization': base64Encode(
                    utf8.encode('user:password'),
                  )
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
