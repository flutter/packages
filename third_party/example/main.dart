import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> assetNames = const <String>[
  // 'assets/notfound.svg',
  'assets/flutter_logo.svg',
  'assets/dart.svg',
  'assets/simple/clip_path_3.svg',
  'assets/simple/clip_path_2.svg',
  'assets/simple/clip_path.svg',
  'assets/simple/group_opacity.svg',
  'assets/simple/text.svg',
  'assets/simple/linear_gradient.svg',
  'assets/simple/linear_gradient_2.svg',
  'assets/simple/radial_gradient.svg',
  'assets/simple/rect_rrect.svg',
  'assets/simple/style_attr.svg',
  'assets/w3samples/aa.svg',
  'assets/w3samples/alphachannel.svg',
  'assets/simple/ellipse.svg',
  'assets/simple/dash_path.svg',
  'assets/simple/nested_group.svg',
  'assets/wikimedia/chess_knight.svg',
  'assets/wikimedia/Ghostscript_Tiger.svg',
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
    _dimension = 580.0;

_painters.add(new SvgPicture.string('''<svg width="26" height="26" viewBox="0 0 26 26" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M22.1595 3.80852C19.6789 1.35254 16.3807 -4.80966e-07 12.8727 -4.80966e-07C9.36452 -4.80966e-07 6.06642 1.35254 3.58579 3.80852C1.77297 5.60333 0.53896 7.8599 0.0171889 10.3343C-0.0738999 10.7666 0.206109 11.1901 0.64265 11.2803C1.07908 11.3706 1.50711 11.0934 1.5982 10.661C2.05552 8.49195 3.13775 6.51338 4.72783 4.9391C9.21893 0.492838 16.5262 0.492728 21.0173 4.9391C25.5082 9.38548 25.5082 16.6202 21.0173 21.0667C16.5265 25.5132 9.21893 25.5133 4.72805 21.0669C3.17644 19.5307 2.10538 17.6035 1.63081 15.4937C1.53386 15.0627 1.10252 14.7908 0.66697 14.887C0.231645 14.983 -0.0427272 15.4103 0.0542205 15.8413C0.595668 18.2481 1.81686 20.4461 3.5859 22.1976C6.14623 24.7325 9.50955 26 12.8727 26C16.236 26 19.5991 24.7326 22.1595 22.1976C27.2802 17.1277 27.2802 8.87841 22.1595 3.80852Z" fill="black"/>
<path d="M5.50468 7.22599L5.43239 7.19961V2.75006L5.55078 2.75838C6.48068 2.82416 7.05364 3.10795 7.47194 3.31513C7.71834 3.43728 7.91301 3.5337 8.0838 3.5337C8.62293 3.5337 8.90493 2.827 8.90493 2.44821C8.90493 1.93294 8.29428 1.60853 7.78191 1.42707C7.17789 1.2131 6.33963 1.07148 5.53973 1.04817L5.43239 1.0451V0.372776C5.43239 0.188139 5.16763 1.20242e-07 4.90774 1.20242e-07C4.59678 1.20242e-07 4.40421 0.193502 4.40421 0.372776V1.07925L4.30516 1.08954C3.12532 1.21256 0.381048 1.82798 0.381048 4.88C0.381048 7.49544 2.47941 8.2341 4.3307 8.88585L4.40421 8.91179V14.0339L4.28504 14.0247C2.89693 13.917 2.15407 13.2913 1.61174 12.8345C1.31692 12.586 1.084 12.3899 0.863465 12.3899C0.418744 12.3899 1.21448e-07 13.0014 1.21448e-07 13.4754C1.21448e-07 14.4115 1.67331 15.7978 4.29543 15.8398L4.40421 15.8415V16.599C4.40421 16.7781 4.59678 16.9717 4.90774 16.9717C5.16752 16.9717 5.43239 16.7836 5.43239 16.5991V15.791L5.52768 15.7779C7.91611 15.4495 9.28609 13.9149 9.28609 11.5677C9.2862 8.83201 7.41821 7.92283 5.50468 7.22599ZM4.53134 6.88331L4.38177 6.82738C3.23056 6.39726 2.27755 5.93813 2.27755 4.67052C2.27755 3.61972 3.01389 2.97333 4.40709 2.80095L4.53134 2.78563V6.88331ZM5.43604 13.9812L5.30537 14.0052V9.28413L5.45947 9.34958C6.46211 9.775 7.38991 10.366 7.38991 11.7981C7.38991 12.9749 6.69591 13.7502 5.43604 13.9812Z" transform="translate(8.22925 5.12915)" fill="black"/>
</svg>'''));
    _painters.add(new SvgPicture.string('''<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg viewBox="0 0 1000 300"
     xmlns="http://www.w3.org/2000/svg" version="1.1">
  <desc>Example tspan01 - using tspan to change visual attributes</desc>

  <g font-family="Verdana" font-size="45" >
    <text x="200" y="150" fill="blue" >
      You are <tspan font-weight="bold" fill="red" >not</tspan> <tspan stroke="green">a</tspan> banana.
    </text>
  </g>

  <!-- Show outline of canvas using 'rect' element -->
  <rect x="1" y="1" width="998" height="298"
        fill="none" stroke="blue" stroke-width="2" />
</svg>'''));
    for (String assetName in assetNames) {
      _painters.add(
        new SvgPicture.asset(assetName),
      );
    }

    for (int i = 0; i < iconNames.length; i++) {
      _painters.add(
        new Directionality(
          textDirection: TextDirection.ltr,
          child: new SvgPicture.asset(
            iconNames[i],
            color: Colors.blueGrey[(i + 1) * 100],
            matchTextDirection: true,
          ),
        ),
      );
    }

    // _painters.add(new SvgPicture.asset(iconNames[0], color: Colors.red));

    for (String uriName in uriNames) {
      _painters.add(
        new SvgPicture.network(
          uriName,
          placeholderBuilder: (BuildContext context) => new Container(
              padding: const EdgeInsets.all(30.0),
              child: const CircularProgressIndicator()),
        ),
      );
    }
    _painters
        .add(new AvdPicture.asset('assets/android_vd/battery_charging.xml'));
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
