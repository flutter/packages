// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Launcher',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'URL Launcher'),
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
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  bool _hasCallSupport = false;
  bool _hasCustomTabSupport = false;
  Future<void>? _launched;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    // Check for phone call support.
    launcher.canLaunch('tel:123').then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
    // Check for Android Custom Tab support.
    launcher.supportsMode(PreferredLaunchMode.inAppBrowserView).then((
      bool result,
    ) {
      setState(() {
        _hasCustomTabSupport = result;
      });
    });
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launcher.launchUrl(
      url,
      const LaunchOptions(mode: PreferredLaunchMode.externalApplication),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInNonBrowserExternalApp(String url) async {
    if (!await launcher.launchUrl(
      url,
      const LaunchOptions(
        mode: PreferredLaunchMode.externalNonBrowserApplication,
      ),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInCustomTab(String url) async {
    if (!await launcher.launchUrl(
      url,
      const LaunchOptions(mode: PreferredLaunchMode.inAppBrowserView),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInWebView(String url) async {
    if (!await launcher.launchUrl(
      url,
      const LaunchOptions(mode: PreferredLaunchMode.inAppWebView),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInWebViewWithCustomHeaders(String url) async {
    if (!await launcher.launchUrl(
      url,
      const LaunchOptions(
        mode: PreferredLaunchMode.inAppWebView,
        webViewConfiguration: InAppWebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'},
        ),
      ),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInWebViewWithoutJavaScript(String url) async {
    if (!await launcher.launchUrl(
      url,
      const LaunchOptions(
        mode: PreferredLaunchMode.inAppWebView,
        webViewConfiguration: InAppWebViewConfiguration(
          enableJavaScript: false,
        ),
      ),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInWebViewWithoutDomStorage(String url) async {
    if (!await launcher.launchUrl(
      url,
      const LaunchOptions(
        mode: PreferredLaunchMode.inAppWebView,
        webViewConfiguration: InAppWebViewConfiguration(
          enableDomStorage: false,
        ),
      ),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
    // Just using 'tel:$phoneNumber' would create invalid URLs in some cases.
    final launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launcher.launchUrl(launchUri.toString(), const LaunchOptions());
  }

  @override
  Widget build(BuildContext context) {
    // onPressed calls using this URL are not gated on a 'canLaunch' check
    // because the assumption is that every device can launch a web URL.
    const toLaunch = 'https://www.cylog.org/headers/';
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (String text) => _phone = text,
                  decoration: const InputDecoration(
                    hintText: 'Input the phone number to launch',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _hasCallSupport
                    ? () => setState(() {
                        _launched = _makePhoneCall(_phone);
                      })
                    : null,
                child: _hasCallSupport
                    ? const Text('Make phone call')
                    : const Text('Calling not supported'),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(toLaunch),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInBrowser(toLaunch);
                }),
                child: const Text('Launch in browser'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInNonBrowserExternalApp(toLaunch);
                }),
                child: const Text('Launch in non-browser app'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              ElevatedButton(
                onPressed: _hasCustomTabSupport
                    ? () => setState(() {
                        _launched = _launchInCustomTab(toLaunch);
                      })
                    : null,
                child: const Text('Launch in Android Custom Tab'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebView(toLaunch);
                }),
                child: const Text('Launch in web view'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewWithCustomHeaders(toLaunch);
                }),
                child: const Text('Launch in web view (Custom headers)'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewWithoutJavaScript(toLaunch);
                }),
                child: const Text('Launch in web view (JavaScript OFF)'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewWithoutDomStorage(toLaunch);
                }),
                child: const Text('Launch in web view (DOM storage OFF)'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              ElevatedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebView(toLaunch);
                  Timer(const Duration(seconds: 5), () {
                    launcher.closeWebView();
                  });
                }),
                child: const Text('Launch in web view + close after 5 seconds'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              FutureBuilder<void>(future: _launched, builder: _launchStatus),
            ],
          ),
        ],
      ),
    );
  }
}
