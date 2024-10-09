// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Run this example with: flutter run -t lib/encoding.dart -d emulator

// This file is used to extract code samples for the README.md file.
// Run update-excerpts if you modify this file.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Encode [params] so it produces a correct query string.
/// Workaround for: https://github.com/dart-lang/sdk/issues/43838
// #docregion encode-query-parameters
String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}
// #enddocregion encode-query-parameters

void main() => runApp(
      const MaterialApp(
        home: Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: _composeMail,
                child: Text('Compose an email'),
              ),
            ],
          ),
        ),
      ),
    );

void _composeMail() {
// #docregion encode-query-parameters
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'smith@example.com',
    query: encodeQueryParameters(<String, String>{
      'subject': 'Example Subject & Symbols are allowed!',
    }),
  );

  launchUrl(emailLaunchUri);
// #enddocregion encode-query-parameters
}
