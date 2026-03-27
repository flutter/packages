import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

const String htmlPage = '''
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebView Test</title>
    <style>
        header {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            padding-top: env(safe-area-inset-top);
            background-color: blue;
            color: #ffffff;
        }
        .content {
            padding-top: 72px;
        }
    </style>
</head>
<body>
<div class="container">
    <header><h1>Webview AppBar</h1></header>
    <div class="content">
        <p>This is some webview content</p>
    </div>
</div>
</body>
</html>
''';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final PlatformWebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    )..setJavaScriptMode(JavaScriptMode.unrestricted);

    Future.delayed(Duration(seconds: 5)).then((_) {
      _controller.loadHtmlString(htmlPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 100),
        Expanded(
          child: PlatformWebViewWidget(
            PlatformWebViewWidgetCreationParams(controller: _controller),
          ).build(context),
        ),
      ],
    );
  }
}
