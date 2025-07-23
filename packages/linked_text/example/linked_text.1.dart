// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:linked_text/linked_text.dart';

// This example demonstrates highlighting and linking X handles.

void main() {
  runApp(const LinkedTextApp());
}

class LinkedTextApp extends StatelessWidget {
  const LinkedTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Flutter Link X Handle Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  static const String _text =
      'Please check out @FlutterDev on X for the latest.';

  void _handleTapXHandle(BuildContext context, String linkText) {
    final String handleWithoutAt = linkText.substring(1);
    final String xUriString = 'https://www.x.com/$handleWithoutAt';
    final Uri? uri = Uri.tryParse(xUriString);
    if (uri == null) {
      throw Exception('Failed to parse $xUriString.');
    }

    // A package like url_launcher would be useful for actually opening the URL
    // here instead of just showing a dialog.
    Navigator.of(context).push(
      DialogRoute<void>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(title: Text('You tapped: $uri')),
      ),
    );
  }

  final RegExp _xHandleRegExp = RegExp(r'@[a-zA-Z0-9]{4,15}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Builder(
          builder: (BuildContext context) {
            return SelectionArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // #docregion linked_text_reg_exp
                  LinkedText.regExp(
                    text: _text,
                    regExp: _xHandleRegExp,
                    // TODO(justinmc): So the user has to use url_launcher directly for cases like this. That's probably not ideal for several reasons, but most importantly, in the browser when you hover the link you won't see the URL at the bottom of the browser. Right clicking and clicking "open in new tab" also doesn't work. So instead, provide a getUri parameter that passes in the link string and returns the URL. Use that to give the URL directly to Link, so everything works. Right?
                    onTap: (String xHandleString) =>
                        _handleTapXHandle(context, xHandleString),
                  ),
                  // #enddocregion linked_text_reg_exp
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
