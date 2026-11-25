// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [ScaffoldMessengerState.showMaterialBanner].

void main() => runApp(const ShowMaterialBannerExampleApp());

class ShowMaterialBannerExampleApp extends StatelessWidget {
  const ShowMaterialBannerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ScaffoldMessengerState Sample')),
        body: const Center(child: ShowMaterialBannerExample()),
      ),
    );
  }
}

class ShowMaterialBannerExample extends StatelessWidget {
  const ShowMaterialBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
        messenger.showMaterialBanner(
          MaterialBanner(
            content: const Text('This is a MaterialBanner'),
            actions: <Widget>[
              TextButton(
                onPressed: messenger.hideCurrentMaterialBanner,
                child: const Text('DISMISS'),
              ),
            ],
          ),
        );
      },
      child: const Text('Show MaterialBanner'),
    );
  }
}
// #endregion body
