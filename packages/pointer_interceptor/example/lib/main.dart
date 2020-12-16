// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'src/shim/dart_ui.dart' as ui;

const String _htmlElementViewType = '_htmlElementViewType';
const num _videoWidth = 640;
const num _videoHeight = 480;

/// The html.Element that will be rendered underneath the flutter UI.
html.Element htmlElement = html.DivElement()
  ..style.width = '100%'
  ..style.height = '100%'
  ..style.backgroundColor = '#fabada'
  ..style.cursor = 'auto'
  ..id = 'background-html-view';

// See other examples commented out below...

// html.Element htmlElement = html.VideoElement()
//   ..style.width = '100%'
//   ..style.height = '100%'
//   ..style.cursor = 'auto'
//   ..style.backgroundColor = 'black'
//   ..id = 'background-html-view'
//   ..src = 'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4'
//   ..poster = 'https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217'
//   ..controls = true;

// html.Element htmlElement = html.IFrameElement()
//       ..width = '100%'
//       ..height = '100%'
//       ..id = 'background-html-view'
//       ..src = 'https://www.youtube.com/embed/IyFZznAk69U'
//       ..style.border = 'none';

void main() {
  runApp(MyApp());
}

/// Main app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_htmlElementViewType,
        (int viewId) {
      final html.Element wrapper = html.DivElement();
      wrapper.append(htmlElement);
      return wrapper;
    });

    return MaterialApp(
      title: 'Stopping Clicks with some DOM',
      home: MyHomePage(),
    );
  }
}

/// First page
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
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
                  HtmlElement(
                    onClick: () {
                      _clickedOn('html-element');
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        key: const Key('transparent-button'),
                        child: const Text('Never calls onPressed'),
                        onPressed: () {
                          _clickedOn('transparent-button');
                        },
                      ),
                      PointerInterceptor(
                        child: RaisedButton(
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

/// Initialize the videoPlayer, then render the corresponding view...
class HtmlElement extends StatelessWidget {
  /// Constructor
  const HtmlElement({this.onClick});

  /// A function to run when the element is clicked
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    htmlElement.onClick.listen((_) {
      onClick();
    });

    return const HtmlElementView(
      viewType: _htmlElementViewType,
    );
  }
}
