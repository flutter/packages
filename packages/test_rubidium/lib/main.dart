import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
    // return PlatformViewLink(
    //   viewType: 'myPlatformView',
    //   surfaceFactory: (
    //       BuildContext context,
    //       PlatformViewController controller,
    //       ) {
    //     return AndroidViewSurface(
    //       controller: controller as AndroidViewController,
    //       hitTestBehavior: PlatformViewHitTestBehavior.opaque,
    //       gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    //     );
    //   },
    //   onCreatePlatformView: (PlatformViewCreationParams params) {
    //     return PlatformViewsService.initSurfaceAndroidView(
    //       id: params.id,
    //       viewType: 'plugins.flutter.io/webview',
    //       layoutDirection: TextDirection.ltr,
    //       creationParams: null,
    //       creationParamsCodec: const StandardMessageCodec(),
    //     );
    //   },
    // );
  }
}
