import 'package:flutter/material.dart';
import 'package:platform/platform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const platform = LocalPlatform();
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
              children: [
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
                FormatDetails(
                  title: 'isAndroid:',
                  value: platform.isAndroid.toString(),
                ),
                FormatDetails(
                  title: 'isIOS:',
                  value: platform.isIOS.toString(),
                ),
                FormatDetails(
                  title: 'isFuchsia:',
                  value: platform.isFuchsia.toString(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormatDetails extends StatelessWidget {
  const FormatDetails({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
