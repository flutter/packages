// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:convert' show jsonEncode;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:poll_ios_stats/poll_ios_stats.dart';

String _hostIp;

Future<String> _getHostIp() async {
  return rootBundle.loadString('assets/ip.txt');
}

Future<void> _sendResult(double result) async {
  assert(_hostIp != null);
  print('sending result $result...');
  final String measurementName =
      '${Platform.isAndroid ? "android_" : "ios_"}startup_time';
  final http.Response response = await http.post(
    Uri.http(_hostIp),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'test': 'smiley',
      'platform': 'flutter',
      'results': <String, double>{measurementName: result},
    }),
  );
  if (response.statusCode != 200) {
    print('error when posting results:${response.statusCode}');
  }
}

void main() {
  runApp(const MyApp());
  // Hide status bar.
  // TODO(stuartmorgan): Remove this and migrate to the new API once it is
  // available on stable (likely late 2021).
  // ignore:deprecated_member_use
  SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
  _getHostIp().then((String ip) async {
    _hostIp = ip;
  });
}

/// Top level Material App.
class MyApp extends StatelessWidget {
  /// Create top level Material App.
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

/// `Scaffold` that has the image widget.
class MyHomePage extends StatefulWidget {
  /// Standard constructor for a StatefulWidget.
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AssetImage _image = const AssetImage('images/smiley.png');
  bool _loading = true;

  @override
  void initState() {
    _image
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((_, __) {
      if (mounted) {
        setState(() {
          _loading = false;
          // This should get called when the image has actually been drawn to the screen.
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final DateTime renderTime = DateTime.now();
            final PollIosStats poller = PollIosStats();
            final StartupTime startupTime = await poller.pollStartupTime();
            final Duration diff = renderTime.difference(
                DateTime.fromMicrosecondsSinceEpoch(startupTime.startupTime));
            _sendResult(diff.inMicroseconds / 1000000.0);
          });
        });
      }
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_loading) Container() else Image(image: _image),
          ],
        ),
      ),
    );
  }
}
