import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> assetNames = <String>[
  // 'assets/notfound.svg',
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
  // This widget is the root of your application.
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

    _painters.add(
      SvgPicture.string(
        '''<?xml version="1.0" encoding="UTF-8"?>
<svg height="22px" width="22px" viewBox="0 0 22 22" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <!-- Generator: Sketch 51.2 (57519) - http://www.bohemiancoding.com/sketch -->
    <title>Fill 1</title>
    <desc>Created with Sketch.</desc>
    <defs></defs>
    <g id="02.-Agenda" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="Agenda" transform="translate(-37.000000, -629.000000)" fill="#FFFFFF">
            <g id="Tab-bar" transform="translate(0.000000, 611.000000)">
                <polygon id="Fill-1" points="48 18 37 25.7 37 40 44.5 40 44.5 33.3989 51.5 33.3989 51.5 40 59 40 59 25.7"></polygon>
            </g>
        </g>
    </g>
</svg>''',
        color: Colors.black,
      ),
    );

    _painters.add(SvgPicture.string('''<?xml version="1.0" encoding="UTF-8"?>
<svg width="18px" height="18px" viewBox="0 0 18 18" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <!-- Generator: Sketch 51.2 (57519) - http://www.bohemiancoding.com/sketch -->
    <title>Close</title>
    <desc>Created with Sketch.</desc>

    <defs></defs>
    <g id="03.-Agenda" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" stroke-linecap="square">
        <g id="Filter" transform="translate(-338.000000, -22.000000)" stroke="#1A1A1A" stroke-width="4">
            <g id="Close" transform="translate(347.000000, 31.000000) rotate(-45.000000) translate(-347.000000, -31.000000) translate(339.000000, 23.000000)">
                <path d="M0,8 L16,8" id="Line-2"></path>
                <path d="M8,0 L8,16" id="Line-2"></path>
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
