// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

/// This sample app shows the platform details of the device it is running on.
void main() => runApp(const MyApp());

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const LocalPlatform platform = LocalPlatform();
    return MaterialApp(
      title: 'Platform Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Platform Example'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FormatDetails(
                  title: 'Operating System:',
                  value: platform.operatingSystem,
                ),
                FormatDetails(
                  title: 'Number of Processors:',
                  value: platform.numberOfProcessors.toString(),
                ),
                FormatDetails(
                  title: 'Path Separator:',
                  value: platform.pathSeparator,
                ),
                FormatDetails(
                  title: 'Local Hostname:',
                  value: platform.localHostname,
                ),
                FormatDetails(
                  title: 'Environment:',
                  value: platform.environment.toString(),
                ),
                FormatDetails(
                  title: 'Executable:',
                  value: platform.executable,
                ),
                FormatDetails(
                  title: 'Resolved Executable:',
                  value: platform.resolvedExecutable,
                ),
                FormatDetails(
                  title: 'Script:',
                  value: platform.script.toString(),
                ),
                FormatDetails(
                  title: 'Executable Arguments:',
                  value: platform.executableArguments.toString(),
                ),
                FormatDetails(
                  title: 'Package Config:',
                  value: platform.packageConfig.toString(),
                ),
                FormatDetails(
                  title: 'Version:',
                  value: platform.version,
                ),
                FormatDetails(
                  title: 'Stdin Supports ANSI:',
                  value: platform.stdinSupportsAnsi.toString(),
                ),
                FormatDetails(
                  title: 'Stdout Supports ANSI:',
                  value: platform.stdoutSupportsAnsi.toString(),
                ),
                FormatDetails(
                  title: 'Locale Name:',
                  value: platform.localeName,
                ),
                FormatDetails(
                  title: 'isAndroid:',
                  value: platform.isAndroid.toString(),
                ),
                FormatDetails(
                  title: 'isFuchsia:',
                  value: platform.isFuchsia.toString(),
                ),
                FormatDetails(
                  title: 'isIOS:',
                  value: platform.isIOS.toString(),
                ),
                FormatDetails(
                  title: 'isLinux:',
                  value: platform.isLinux.toString(),
                ),
                FormatDetails(
                  title: 'isMacOS:',
                  value: platform.isMacOS.toString(),
                ),
                FormatDetails(
                  title: 'isWindows:',
                  value: platform.isWindows.toString(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget to format the details.
class FormatDetails extends StatelessWidget {
  /// Constructs a [FormatDetails].
  const FormatDetails({
    super.key,
    required this.title,
    required this.value,
  });

  /// The title of the field.
  final String title;

  /// The value of the field.
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(value),
        const SizedBox(height: 20),
      ],
    );
  }
}
