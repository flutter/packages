// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Quick Actions Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String shortcut = 'no action set';

  @override
  void initState() {
    super.initState();

    // #docregion Initialize
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'ios_action') {
        debugPrint('You pressed ios action');
      } else if (shortcutType == 'android_action') {
        debugPrint('You pressed android action');
      }
      // #enddocregion Initialize
      setState(() {
        shortcut = shortcutType;
      });
      // #docregion Initialize
    });
    // #enddocregion Initialize

    // #docregion SetShortcuts
    quickActions.setShortcutItems(<ShortcutItem>[
      // #enddocregion SetShortcuts
      if (Platform.isIOS)
        // #docregion SetShortcuts
        const ShortcutItem(type: 'ios_action', localizedTitle: 'iOS Action', icon: 'AppIcon'),
      // #enddocregion SetShortcuts
      if (Platform.isAndroid)
        // #docregion SetShortcuts
        const ShortcutItem(type: 'android_action', localizedTitle: 'Android Action', icon: 'ic_launcher')
    ]).then((void _) {
      // #enddocregion SetShortcuts
      setState(() {
        if (shortcut == 'no action set') {
          shortcut = 'actions ready';
        }
      });
      // #docregion SetShortcuts
    });
    // #enddocregion SetShortcuts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shortcut),
      ),
      body: const Center(
        child: Text('On home screen, long press the app icon to '
            'get Action one or Action two options. Tapping on that action should  '
            'set the toolbar title.'),
      ),
    );
  }
}
