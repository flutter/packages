// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' show jsonEncode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:poll_ios_stats/poll_ios_stats.dart';

String _hostIp;

Future<String> _getHostIp() async {
  return await rootBundle.loadString('assets/ip.txt');
}

Future<void> _sendResult(double result) async {
  assert(_hostIp != null);
  print('sending result $result...');
  final http.Response response = await http.post(
    'http://$_hostIp',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'test': 'smiley',
      'platform': 'flutter',
      'results': <String, double>{
        'startupTime': result
      },
    }),
  );
  if (response.statusCode != 200) {
    print('error when posting results:${response.statusCode}');
  }
}

void main() {
  runApp(MyApp());
  // Hide status bar.
  SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
  _getHostIp().then((String ip) async {
    _hostIp = ip;
  });
}

/// Top level Material App.
class MyApp extends StatelessWidget {
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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AssetImage _image = const AssetImage('images/smiley.png');
  bool _loading = true;

  @override
  void initState() {
    _image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((_, __) {
      if (mounted) {
        setState(() {
          _loading = false;
          // This should get called when the image has actually been drawn to the screen.
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final DateTime renderTime = DateTime.now();
            final PollIosStats _poller = PollIosStats();
            final StartupTime startupTime = await _poller.pollStartupTime();
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
            _loading ? Container() : Image(image: _image),
          ],
        ),
      ),
    );
  }
}
