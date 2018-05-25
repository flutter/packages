import 'package:flutter/material.dart';
import 'package:flutter_svg/avd.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/src/picture_provider.dart';

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
  'assets/simple/ellipse.svg',
  'assets/simple/dash_path.svg',
  'assets/simple/nested_group.svg',
  'assets/wikimedia/chess_knight.svg',
  'assets/wikimedia/Ghostscript_Tiger.svg',
];

const List<String> uriNames = const <String>[
  // 'http://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg',
  // 'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/410.svg',
  // 'https://upload.wikimedia.org/wikipedia/commons/b/b4/Chess_ndd45.svg',
];

void main() => runApp(new MyApp());

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

  final ErrorWidgetBuilder customErrorBuilder = (FlutterErrorDetails details) {
    debugPrint(details.toString());
    return new Row(children: const <Widget>[
      const Icon(
        Icons.error,
        color: Colors.red,
      ),
      const Text('Error Loading')
    ]);
  };

  @override
  void initState() {
    super.initState();
    _dimension = 250.0;

    for (String assetName in assetNames) {
      _painters.add(
        // new FractionallySizedBox(
        //size: new Size.square(_dimension),
        // child:
        new SvgPicture(new ExactAssetPicture(assetName), _dimension, _dimension),
        // ),

        // _painters.add(new SvgImage.asset(
        //   assetName,
        //   new Size(_dimension, _dimension),
        //   errorWidgetBuilder: customErrorBuilder,
        // ),
      );
    }

    for (String uriName in uriNames) {
      _painters.add(
        new SvgImage.network(
          uriName,
          new Size(_dimension, _dimension),
          loadingPlaceholderBuilder: (BuildContext context) => new Container(
              padding: const EdgeInsets.all(30.0),
              child: const CircularProgressIndicator()),
        ),
      );
    }
    _painters.add(new AvdImage.asset('assets/android_vd/battery_charging.xml',
        new Size(_dimension, _dimension)));
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
