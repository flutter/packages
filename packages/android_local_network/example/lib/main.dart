// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:android_local_network/android_local_network.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Local Network Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Unknown';
  String _lastAction = 'None';
  bool _isScanning = false;
  final List<String> _foundDevices = [];
  final List<String> _interfacesInfo = [];

  @override
  void initState() {
    super.initState();
    _refreshInterfaces();
  }

  Future<void> _refreshInterfaces() async {
    final interfaces = await NetworkInterface.list();
    setState(() {
      _interfacesInfo.clear();
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            _interfacesInfo.add('${interface.name}: ${addr.address}');
          }
        }
      }
    });
  }

  Future<void> _checkPermission() async {
    final bool granted = await AndroidLocalNetwork.checkPermission();
    setState(() {
      _status = granted ? 'Granted' : 'Denied/Not Requested';
      _lastAction = 'Checked Permission';
    });
  }

  Future<void> _scanLan() async {
    setState(() {
      _isScanning = true;
      _foundDevices.clear();
      _lastAction = 'Scanning all IPv4 interfaces (ports 80, 8080, 443)...';
    });

    try {
      final interfaces = await NetworkInterface.list();
      final List<String> subnets = [];
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final parts = addr.address.split('.');
            subnets.add('${parts[0]}.${parts[1]}.${parts[2]}');
          }
        }
      }

      if (subnets.isEmpty) {
        setState(() {
          _lastAction = 'No non-loopback IPv4 interfaces found';
          _isScanning = false;
        });
        return;
      }

      final List<Future<void>> scans = [];
      final List<int> ports = [80, 8080, 443, 22];

      for (final subnet in subnets) {
        for (int i = 1; i <= 254; i++) {
          final ip = '$subnet.$i';
          for (final port in ports) {
            scans.add(() async {
              try {
                final socket = await AndroidLocalAreaSocket.connect(
                  ip,
                  port,
                  timeout: const Duration(milliseconds: 500),
                );
                await socket.close();
                setState(() {
                  final entry = '$ip:$port';
                  if (!_foundDevices.contains(entry)) {
                    _foundDevices.add(entry);
                  }
                });
              } catch (_) {
                // Ignore connection failures
              }
            }());
          }
        }
      }

      await Future.wait(scans);
      setState(() {
        _lastAction = 'Scan complete. Found ${_foundDevices.length} devices.';
      });
    } catch (e) {
      setState(() {
        _lastAction = 'Scan error: $e';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Android Local Network'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshInterfaces,
            tooltip: 'Refresh Interfaces',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Permission Status:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  _status,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _status == 'Granted' ? Colors.green : Colors.red,
                      ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text('Detected Interfaces:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ..._interfacesInfo.map((info) => Text(info)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Last Action:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  _lastAction,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _checkPermission,
                      child: const Text('Check Status'),
                    ),
                    ElevatedButton(
                      onPressed: _isScanning ? null : _scanLan,
                      child: _isScanning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Deep Scan LAN'),
                    ),
                  ],
                ),
                if (_foundDevices.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text('Found Devices:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _foundDevices.length,
                    itemBuilder: (context, index) {
                      return Center(child: Text(_foundDevices[index]));
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
