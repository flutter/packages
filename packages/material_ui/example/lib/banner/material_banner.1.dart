// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [MaterialBanner].

void main() => runApp(const MaterialBannerExampleApp());

class MaterialBannerExampleApp extends StatelessWidget {
  const MaterialBannerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MaterialBannerExample());
  }
}

class MaterialBannerExample extends StatelessWidget {
  const MaterialBannerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The MaterialBanner is below')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Show MaterialBanner'),
          onPressed: () {
            final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
              context,
            );
            messenger.showMaterialBanner(
              MaterialBanner(
                padding: const .all(20),
                content: const Text('Hello, I am a Material Banner'),
                leading: const Icon(Icons.agriculture_outlined),
                backgroundColor: Colors.green,
                actions: <Widget>[
                  TextButton(
                    onPressed: messenger.hideCurrentMaterialBanner,
                    child: const Text('DISMISS'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
// #endregion body
