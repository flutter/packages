import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> assetNames = <String>[
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

const List<String> uriNames = <String>[
  'http://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg',
  'https://upload.wikimedia.org/wikipedia/commons/b/b4/Chess_ndd45.svg',
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter SVG Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _painters = <Widget>[];
  double _dimension;

  @override
  void initState() {
    super.initState();
    _dimension = 250.0;

  _painters.add(SvgPicture.string('''<svg xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 99.75 100.347">
    <defs>
        <style>.a{fill:#fff;}.b{fill:url(#c);}.c{fill:#512da8;}.d{fill:#362c66;}.e{fill:url(#d);}.f{fill:#007066;}.g{filter:url(#a);}</style>
        <linearGradient id="c" x1="0.935" y1="0.877" x2="0.077" y2="0.206" gradientUnits="objectBoundingBox">
            <stop offset="0" stop-color="#fff"/>
            <stop offset="0.515" stop-color="#e6e6e6"/>
            <stop offset="1" stop-color="#f5f5f5"/>
        </linearGradient>
        <linearGradient id="d" y1="0.5" x2="1" y2="0.5" gradientUnits="objectBoundingBox">
            <stop offset="0" stop-color="#35bdb2"/>
            <stop offset="1" stop-color="#008d7f"/>
        </linearGradient>
    </defs>
    <g transform="translate(-13 -8)">
        <g class="g" transform="matrix(1, 0, 0, 1, 13, 8)">
            <rect class="a" width="81.75" height="82.347" rx="19" transform="translate(9 6)"/>
        </g>
        <path class="b" d="M25.911,53.347,0,26.709,19.1,27.9,35.206,39.145V20.169h5.848L54.778,32.461,57.524,0,70.054,12.531v9.815a31,31,0,0,1-31,31Z" transform="translate(33.695 43)"/>
        <g transform="translate(33.338 27.128)">
            <g transform="translate(0 0)">
                <path class="c" d="M5.119,45.433v16.12H18.759a2.542,2.542,0,0,1,1.609.571h0l11.939,9.69V45.579L18.6,34.052,5.119,45.433ZM0,64.1V44.251H.006a2.548,2.548,0,0,1,.9-1.95L16.945,28.767l0,.005a2.548,2.548,0,0,1,3.285-.005L36.317,42.294a2.556,2.556,0,0,1,1.11,2.11V77.177h-.008a2.552,2.552,0,0,1-4.161,1.98l-15.407-12.5H2.784c-.074.006-.149.011-.225.011A2.56,2.56,0,0,1,0,64.1Z" transform="translate(0 -22.785)"/>
                <path class="d" d="M130.086,69.7l-2.009-1.69,3.2-3.969,4.154,3.494Z" transform="translate(-103.599 -51.801)"/>
                <path class="e" d="M112.144,17.264V33.385h6.734v5.1h-9.069c-.074.007-.149.01-.225.01a2.56,2.56,0,0,1-2.56-2.56V16.083h.006a2.548,2.548,0,0,1,.9-1.95L123.97.6l0,0a2.548,2.548,0,0,1,3.285,0l16.082,13.527a2.556,2.556,0,0,1,1.11,2.11V49.008h-.008a2.552,2.552,0,0,1-4.161,1.98l-15.406-12.5H124v-5.1h1.786a2.54,2.54,0,0,1,1.609.571h0l11.939,9.69V17.411l-13.7-11.528L112.144,17.264Z" transform="translate(-86.571 -0.001)"/>
                <path class="f" d="M195.833,174.678h.993l-.675,5.1h-.318Z" transform="translate(-158.406 -141.294)"/>
            </g>
        </g>
    </g>
</svg>'''));
    for (String assetName in assetNames) {
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
            color: Colors.blueGrey[(i + 1) * 100],
            matchTextDirection: true,
          ),
        ),
      );
    }

    for (String uriName in uriNames) {
      _painters.add(
        SvgPicture.network(
          uriName,
          placeholderBuilder: (BuildContext context) => Container(
              padding: const EdgeInsets.all(30.0),
              child: const CircularProgressIndicator()),
        ),
      );
    }
    // Shows an example of an SVG image that will fetch a raster image from a URL.
    _painters.add(SvgPicture.string('''<svg viewBox="0 0 200 200"
  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <image xlink:href="https://mdn.mozillademos.org/files/6457/mdn_logo_only_color.png" height="200" width="200"/>
</svg>'''));
    _painters.add(AvdPicture.asset('assets/android_vd/battery_charging.xml'));
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
            }),
        Expanded(
          child: GridView.extent(
            shrinkWrap: true,
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
