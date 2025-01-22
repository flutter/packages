import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> _assetNames = <String>[
  // 'assets/notfound.svg', // uncomment to test an asset that doesn't exist.
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
const List<String> iconNames = <String>[
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
const List<String> uriNames = <String>[
  'http://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg',
  'https://upload.wikimedia.org/wikipedia/commons/b/b4/Chess_ndd45.svg',
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
  final List<Widget> _painters = <Widget>[];
  late double _dimension;

  @override
  void initState() {
    super.initState();
    _dimension = 203.0;
    for (final String assetName in _assetNames) {
      _painters.add(
        SvgPicture.asset(assetName),
      );
    }

    for (int i = 0; i < iconNames.length; i++) {
      _painters.add(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SvgPicture.asset(
            iconNames[i],
            colorFilter: ColorFilter.mode(
              Colors.blueGrey[(i + 1) * 100] ?? Colors.blueGrey,
              BlendMode.srcIn,
            ),
            matchTextDirection: true,
          ),
        ),
      );
    }

    for (final String uriName in uriNames) {
      _painters.add(
        SvgPicture.network(
          uriName,
          placeholderBuilder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(30.0),
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }
    // Shows an example of an SVG image that will fetch a raster image from a URL.
    _painters.add(SvgPicture.string('''
<svg viewBox="0 0 200 200"
  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <image xlink:href="https://mdn.mozillademos.org/files/6457/mdn_logo_only_color.png" height="200" width="200"/>
</svg>'''));
  }

  @override
  Widget build(BuildContext context) {
    if (_dimension > MediaQuery.of(context).size.width - 10.0) {
      _dimension = MediaQuery.of(context).size.width - 10.0;
    }
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
            setState(() => _dimension = val);
          },
        ),
        Expanded(
          child: GridView.extent(
            // shrinkWrap: true,
            maxCrossAxisExtent: _dimension,
            padding: const EdgeInsets.all(4.0),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            children: _painters.toList(),
          ),
        ),
      ]),
    );
  }
}
