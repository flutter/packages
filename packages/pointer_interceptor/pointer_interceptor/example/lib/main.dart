// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'native_widget.dart';

const double _videoWidth = 640;
const double _videoHeight = 480;

void main() {
  runApp(const MyApp());
}

/// Main app
class MyApp extends StatelessWidget {
  /// Creates main app.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Stopping Clicks with some DOM',
      home: MyHomePage(),
    );
  }
}

/// First page
class MyHomePage extends StatefulWidget {
  /// Creates first page.
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _lastClick = 'none';

  void _clickedOn(String key) {
    setState(() {
      _lastClick = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PointerInterceptor demo'),
        actions: <Widget>[
          PointerInterceptor(
            // debug: true,
            child: IconButton(
              icon: const Icon(Icons.add_alert),
              tooltip: 'AppBar Icon',
              onPressed: () {
                _clickedOn('appbar-icon');
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Last click on: $_lastClick',
              key: const Key('last-clicked'),
            ),
            Container(
              color: Colors.black,
              width: _videoWidth,
              height: _videoHeight,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  NativeWidget(
                    key: const ValueKey<String>('background-widget'),
                    onClick: () {
                      _clickedOn('native-element');
                    },
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        key: const Key('transparent-button'),
                        child: const Text('Never calls onPressed'),
                        onPressed: () {
                          _clickedOn('transparent-button');
                        },
                      ),
                      PointerInterceptor(
                        intercepting: false,
                        child: ElevatedButton(
                          key: const Key('wrapped-transparent-button'),
                          child:
                              const Text('Never calls onPressed transparent'),
                          onPressed: () {
                            _clickedOn('wrapped-transparent-button');
                          },
                        ),
                      ),
                      PointerInterceptor(
                        child: ElevatedButton(
                          key: const Key('clickable-button'),
                          child: const Text('Works As Expected'),
                          onPressed: () {
                            _clickedOn('clickable-button');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          PointerInterceptor(
            // debug: true,
            child: FloatingActionButton(
              child: const Icon(Icons.navigation),
              onPressed: () {
                _clickedOn('fab-1');
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: PointerInterceptor(
          // debug: true, // Enable this to "see" the interceptor covering the column.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title: const Text('Item 1'),
                onTap: () {
                  _clickedOn('drawer-item-1');
                },
              ),
              ListTile(
                title: const Text('Item 2'),
                onTap: () {
                  _clickedOn('drawer-item-2');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
