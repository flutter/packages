import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> _assetNames = <String>[
  'assets/invalid.svg',
  'assets/notfound.svg', // uncomment to test an asset that doesn't exist.
  'assets/flutter_logo.svg',
  'assets/dart.svg',
  'assets/simple/clip_path_3.svg',
  'assets/simple/clip_path_2.svg',
  'assets/simple/clip_path.svg',
  'assets/simple/fill-rule-inherit.svg',
  'assets/simple/group_fill_opacity.svg',
  'assets/simple/group_opacity.svg',
  'assets/simple/text.svg',
  'assets/simple/text_2.svg',
  'assets/simple/text_5.svg',
  'assets/simple/linear_gradient.svg',
  'assets/simple/linear_gradient_2.svg',
  'assets/simple/male.svg',
  'assets/simple/radial_gradient.svg',
  'assets/simple/rect_rrect.svg',
  'assets/simple/rect_rrect_no_ry.svg',
  'assets/simple/style_attr.svg',
  'assets/w3samples/aa.svg',
  'assets/w3samples/alphachannel.svg',
  'assets/simple/ellipse.svg',
  'assets/simple/dash_path.svg',
  'assets/simple/nested_group.svg',
  'assets/simple/stroke_inherit_circles.svg',
  'assets/simple/use_circles.svg',
  'assets/simple/use_opacity_grid.svg',
  'assets/wikimedia/chess_knight.svg',
  'assets/wikimedia/Ghostscript_Tiger.svg',
  'assets/wikimedia/Firefox_Logo_2017.svg',
];

/// Assets treated as "icons" - using a color filter to render differently.
const List<String> _iconNames = <String>[
  'assets/deborah_ufw/new-action-expander.svg',
  'assets/deborah_ufw/new-camera.svg',
  'assets/deborah_ufw/new-gif-button.svg',
  'assets/deborah_ufw/new-gif.svg',
  'assets/deborah_ufw/new-image.svg',
  'assets/deborah_ufw/new-mention.svg',
  'assets/deborah_ufw/new-pause-button.svg',
  'assets/deborah_ufw/new-play-button.svg',
  'assets/deborah_ufw/new-send-circle.svg',
  'assets/deborah_ufw/numeric_25.svg',
];

/// Assets to test network access.
const List<String> _uriNames = <String>[
  'http://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg',
  'https://upload.wikimedia.org/wikipedia/commons/b/b4/Chess_ndd45.svg',
];

const List<String> _uriFailedNames = <String>[
  'an error image url.svg', // invalid url.
  'https: /sadf.svg', // invalid url.
  'http://www.google.com/404', // 404 url.
  'https://picsum.photos/200', // wrong format image url.
];

const List<String> _stringNames = <String>[
  '''<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <image xlink:href="https://mdn.mozillademos.org/files/6457/mdn_logo_only_color.png" height="200" width="200"/></svg>''', // Shows an example of an SVG image that will fetch a raster image from a URL.
  '''<svg height="100" width="100" xmlns="http://www.w3.org/2000/svg"> <circle r="45" cx="50" cy="50" fill="red" /> </svg> ''', // valid svg
  '''<svg></svg>''', // empty svg.
  'sdf sdf ', // invalid svg.
  '', // empty string.
];

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _MyHomePage(title: 'Flutter SVG Demo'),
    );
  }
}

class _MyHomePage extends StatefulWidget {
  const _MyHomePage({required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  double _dimension = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: <Widget>[
        Slider(
          min: 5.0,
          max: MediaQuery.of(context).size.width - 10.0,
          value: _dimension,
          onChanged: (double val) {
            setState(() => _dimension = min(MediaQuery.of(context).size.width - 10.0, val));
          },
        ),
        Expanded(
          child: GridView.extent(
            // shrinkWrap: true,
            maxCrossAxisExtent: _dimension,
            padding: const EdgeInsets.all(4.0),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            children: <Widget>[
              ..._assetNames.map(
                (String e) => SvgPicture.asset(
                  e,
                  placeholderBuilder: (BuildContext context) => Container(
                    padding: const EdgeInsets.all(30.0),
                    child: const CircularProgressIndicator(),
                  ),
                  errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) => Container(
                    color: Colors.brown,
                    width: 10,
                    height: 10,
                  ),
                ),
              ),
              ..._iconNames.map(
                (String e) => Directionality(
                  textDirection: TextDirection.ltr,
                  child: SvgPicture.asset(
                    e,
                    colorFilter: ColorFilter.mode(
                      Colors.blueGrey[(_iconNames.indexOf(e) + 1) * 100] ?? Colors.blueGrey,
                      BlendMode.srcIn,
                    ),
                    matchTextDirection: true,
                    placeholderBuilder: (BuildContext context) => Container(
                      padding: const EdgeInsets.all(30.0),
                      child: const CircularProgressIndicator(),
                    ),
                    errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) => Container(
                      color: Colors.yellow,
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
              ),
              ..._uriNames.map(
                (String e) => SvgPicture.network(
                  e,
                  placeholderBuilder: (BuildContext context) => Container(
                    padding: const EdgeInsets.all(30.0),
                    child: const CircularProgressIndicator(),
                  ),
                  errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) => Container(
                    color: Colors.red,
                    width: 10,
                    height: 10,
                  ),
                ),
              ),
              ..._uriFailedNames.map(
                (String e) => SvgPicture.network(
                  e,
                  placeholderBuilder: (BuildContext context) => Container(
                    padding: const EdgeInsets.all(30.0),
                    child: const CircularProgressIndicator(),
                  ),
                  errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) => Container(
                    color: Colors.deepPurple,
                    width: 10,
                    height: 10,
                  ),
                ),
              ),
              ..._stringNames.map(
                (String e) => SvgPicture.string(
                  e,
                  placeholderBuilder: (BuildContext context) => Container(
                    padding: const EdgeInsets.all(30.0),
                    child: const CircularProgressIndicator(),
                  ),
                  errorBuilder: (BuildContext context, Object error, StackTrace stackTrace) => Container(
                    color: Colors.pinkAccent,
                    width: 10,
                    height: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
