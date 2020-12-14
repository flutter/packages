// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:web_mouse_click_boundary/web_mouse_click_boundary.dart';

const String _htmlElementViewType = '_htmlElementViewType';
const num _videoWidth = 640;
const num _videoHeight = 480;

/// The html.Element that will be rendered underneath the flutter UI.
/// Check the HtmlElement class at the end for different examples...

// html.Element htmlElement = html.VideoElement()
//   ..style.width = '100%'
//   ..style.height = '100%'
//   ..style.cursor = 'auto'
//   ..style.backgroundColor = 'black'
//   ..src = 'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4'
//   ..poster = 'https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217'
//   ..controls = true;

// html.Element htmlElement = html.IFrameElement()
//       ..width = '100%'
//       ..height = '100%'
//       ..src = 'https://www.youtube.com/embed/IyFZznAk69U'
//       ..style.border = 'none';

html.Element htmlElement = html.DivElement()
  ..style.width = '100%'
  ..style.height = '100%'
  ..style.backgroundColor = '#fabada';

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('MouseClickBoundary demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Last click on: $_lastClick', key: const Key('last-clicked'),),
            Container(
              color: Colors.black,
              width: _videoWidth,
              height: _videoHeight,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  HtmlElement(
                    onClick: () { _clickedOn('html-element'); },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        key: const Key('transparent-button'),
                        child: const Text('Never calls onPressed'),
                        onPressed: () { _clickedOn('transparent-button'); },
                      ),
                      MouseClickBoundary(
                        child: RaisedButton(
                          key: const Key('clickable-button'),
                          child: const Text('Works As Expected'),
                          onPressed: () { _clickedOn('clickable-button'); },
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
    htmlElement.onClick.listen((_) { onClick(); });

    return const HtmlElementView(
      viewType: _htmlElementViewType,
    );
  }
}
