// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';
import 'package:pointer_interceptor_web/pointer_interceptor_web.dart';
import 'package:web/web.dart' as web;

const String _htmlElementViewType = '_htmlElementViewType';
const double _containerWidth = 640;
const double _containerHeight = 480;

/// The html.Element that will be rendered underneath the flutter UI.
final web.Element _htmlElement =
    (web.document.createElement('div') as web.HTMLDivElement)
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = '#fabada'
      ..style.cursor = 'auto'
      ..id = 'background-html-view';

// See other examples commented out below...

// final web.Element _htmlElement =
//     (web.document.createElement('video') as web.HTMLVideoElement)
//       ..style.width = '100%'
//       ..style.height = '100%'
//       ..style.cursor = 'auto'
//       ..style.backgroundColor = 'black'
//       ..id = 'background-html-view'
//       ..src =
//           'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4'
//       ..poster =
//           'https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217'
//       ..controls = true;

// final web.Element _htmlElement =
//     (web.document.createElement('video') as web.HTMLIFrameElement)
//       ..width = '100%'
//       ..height = '100%'
//       ..id = 'background-html-view'
//       ..src = 'https://www.youtube.com/embed/IyFZznAk69U'
//       ..style.border = 'none';

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
      title: 'Stopping Clicks with PointerInterceptor',
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
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(
      _htmlElementViewType,
      (int viewId) => _htmlElement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PointerInterceptor demo'),
        actions: <Widget>[
          PointerInterceptorPlatform.instance.buildWidget(
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
              width: _containerWidth,
              height: _containerHeight,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  HtmlElement(
                    key: const Key('background-widget'),
                    onClick: () {
                      _clickedOn('html-element');
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        key: const Key('transparent-button'),
                        child: const Text('Never calls onPressed'),
                        onPressed: () {
                          _clickedOn('transparent-button');
                        },
                      ),
                      PointerInterceptorWeb().buildWidget(
                          intercepting: false,
                          child: ElevatedButton(
                            key: const Key('wrapped-transparent-button'),
                            child:
                                const Text('Never calls onPressed transparent'),
                            onPressed: () {
                              _clickedOn('wrapped-transparent-button');
                            },
                          )),
                      PointerInterceptorPlatform.instance.buildWidget(
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
          PointerInterceptorPlatform.instance.buildWidget(
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
        child: PointerInterceptorPlatform.instance.buildWidget(
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

/// Initialize the videoPlayer, then render the corresponding view...
class HtmlElement extends StatelessWidget {
  /// Constructor
  const HtmlElement({super.key, required this.onClick});

  /// A function to run when the element is clicked
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    _htmlElement.addEventListener(
      'click',
      (JSAny? _) {
        onClick();
      }.toJS,
    );

    return const HtmlElementView(
      viewType: _htmlElementViewType,
    );
  }
}
