import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> assetNames = const <String>[
  // // 'assets/notfound.svg',
  'assets/flutter_logo.svg',
  'assets/dart.svg',
  'assets/simple/clip_path_3.svg',
  'assets/simple/clip_path_2.svg',
  'assets/simple/clip_path.svg',
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

const List<String> iconNames = const <String>[
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

const List<String> uriNames = const <String>[
  'http://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg',
  'https://upload.wikimedia.org/wikipedia/commons/b/b4/Chess_ndd45.svg',
];

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
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
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _painters = <Widget>[];
  double _dimension;

  @override
  void initState() {
    super.initState();
    _dimension = 250.0;

    _painters.add(SvgPicture.string('''
<svg id="acc99994-a8f7-4371-a8ec-e7fabb1ab565" data-name="Layer 1" 
    xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
    <title>ic_checked</title>
    <g id="a9c0b5e8-c624-4f06-90b7-95bea8ab2723" data-name="ic/List/Check/Checked/Black">
        <g id="db01bf07-79db-412b-9a40-32025b982b07" data-name="ic checked">
            <polygon id="0350d6c0-4373-4661-8af6-19745a3976c3" data-name="1b39d160-b6a3-47e1-9aa4-8e7c13c17c6e" points="48 0 0 0 0 48 48 48 48 0" fill="none"/>
            <path id="2c2e53a8-32f5-4c40-99de-684ef17f451f" data-name="Combined-Shape" d="M40.2,18.86l2.26-2.51a19.93,19.93,0,1,1-5.4-7.45l-2,2.22a17.08,17.08,0,1,0,5.14,7.74ZM42.93,7.45a1.5,1.5,0,1,1,2.13,2.11L24.82,30.05a1.5,1.5,0,0,1-2.14,0l-7.25-7.48a1.5,1.5,0,0,1,2.15-2.09l6.18,6.38Z" fill="#3c4043"/>
        </g>
    </g>
</svg>'''));

    // for (String assetName in assetNames) {
    //   _painters.add(
    //     new SvgPicture.asset(assetName),
    //   );
    // }

    // for (int i = 0; i < iconNames.length; i++) {
    //   _painters.add(
    //     new Directionality(
    //       textDirection: TextDirection.ltr,
    //       child: new SvgPicture.asset(
    //         iconNames[i],
    //         color: Colors.blueGrey[(i + 1) * 100],
    //         matchTextDirection: true,
    //       ),
    //     ),
    //   );
    // }

    // // _painters.add(new SvgPicture.asset(iconNames[0], color: Colors.red));

    // for (String uriName in uriNames) {
    //   _painters.add(
    //     new SvgPicture.network(
    //       uriName,
    //       placeholderBuilder: (BuildContext context) => new Container(
    //           padding: const EdgeInsets.all(30.0),
    //           child: const CircularProgressIndicator()),
    //     ),
    //   );
    // }
    // _painters
    //     .add(new AvdPicture.asset('assets/android_vd/battery_charging.xml'));
  }

  @override
  Widget build(BuildContext context) {
    if (_dimension > MediaQuery.of(context).size.width - 10.0) {
      _dimension = MediaQuery.of(context).size.width - 10.0;
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(children: <Widget>[
        new Slider(
            min: 5.0,
            max: MediaQuery.of(context).size.width - 10.0,
            value: _dimension,
            onChanged: (double val) {
              setState(() => _dimension = val);
            }),
        // new FlutterLogo(size: _dimension),
        // new Container(
        //   padding: const EdgeInsets.all(12.0),
        // child:

        // )
        new Expanded(
          child: new GridView.extent(
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
