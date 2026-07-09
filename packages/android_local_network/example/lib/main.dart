// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:android_local_network/android_local_network.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// The main application.
class MyApp extends StatelessWidget {
  /// Create the main application.
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

/// The main home page screen.
class MyHomePage extends StatefulWidget {
  /// Create the home page.
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Unknown';
  String _lastAction = 'None';
  bool _isScanning = false;
  int _totalAttempts = 0;
  int _permissionGrants = 0;
  int _permissionDenials = 0;
  int _connectionSuccesses = 0;
  int _connectionFailures = 0;
  final List<String> _foundDevices = [];
  final List<String> _interfacesInfo = [];

  @override
  void initState() {
    super.initState();
    _refreshInterfaces();
  }

  Future<void> _refreshInterfaces() async {
    final List<NetworkInterface> interfaces = await NetworkInterface.list();
    setState(() {
      _interfacesInfo.clear();
      for (final interface in interfaces) {
        for (final InternetAddress addr in interface.addresses) {
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

  Future<void> _requestPermission() async {
    final bool granted = await AndroidLocalNetwork.requestPermission();
    setState(() {
      _status = granted ? 'Granted' : 'Denied';
      _lastAction = 'Proactively Requested Permission';
    });
  }

  Future<void> _testStandardSocket() async {
    setState(() {
      _totalAttempts = 1;
      _permissionGrants = 0;
      _permissionDenials = 0;
      _connectionSuccesses = 0;
      _connectionFailures = 0;
      _lastAction =
          'Attempting AndroidLocalAreaSocket.connect("1.1.1.1", 80)...';
    });

    try {
      final Socket socket = await AndroidLocalAreaSocket.connect(
        '1.1.1.1',
        80,
        timeout: const Duration(seconds: 5),
      );
      await socket.close();
      setState(() {
        _permissionGrants++;
        _connectionSuccesses++;
        _lastAction = 'AndroidLocalAreaSocket.connect successful';
      });
      await _checkPermission();
    } catch (e) {
      setState(() {
        if (e is SocketException &&
            e.message.contains('ACCESS_LOCAL_NETWORK')) {
          _permissionDenials++;
        } else {
          _permissionGrants++;
          _connectionFailures++;
        }
        _lastAction = 'AndroidLocalAreaSocket.connect failed: $e';
      });
      await _checkPermission();
    }
  }

  Future<void> _scanLan() async {
    setState(() {
      _isScanning = true;
      _foundDevices.clear();
      _totalAttempts = 0;
      _permissionGrants = 0;
      _permissionDenials = 0;
      _connectionSuccesses = 0;
      _connectionFailures = 0;
      _lastAction = 'Scanning LAN...';
    });

    try {
      final List<NetworkInterface> interfaces = await NetworkInterface.list();
      final subnets = <String>[];
      for (final interface in interfaces) {
        for (final InternetAddress addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final List<String> parts = addr.address.split('.');
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

      final scans = <Future<void>>[];
      final ports = <int>[80, 8080, 443, 22];

      for (final subnet in subnets) {
        for (var i = 1; i <= 254; i++) {
          final ip = '$subnet.$i';
          for (final port in ports) {
            scans.add(() async {
              setState(() {
                _totalAttempts++;
              });
              try {
                final Socket socket = await AndroidLocalAreaSocket.connect(
                  ip,
                  port,
                  timeout: const Duration(milliseconds: 500),
                );
                await socket.close();
                setState(() {
                  _permissionGrants++;
                  _connectionSuccesses++;
                  final entry = '$ip:$port';
                  if (!_foundDevices.contains(entry)) {
                    _foundDevices.add(entry);
                  }
                });
              } catch (e) {
                setState(() {
                  if (e is SocketException &&
                      e.message.contains('ACCESS_LOCAL_NETWORK')) {
                    _permissionDenials++;
                  } else {
                    _permissionGrants++;
                    _connectionFailures++;
                  }
                });
              }
            }());
          }
        }
      }

      await Future.wait(scans);
      setState(() {
        _lastAction = 'Scan complete.';
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
                if (_totalAttempts > 0)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Permission & Connection Stats',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Permission Result:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                'Granted',
                                _permissionGrants,
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Denied',
                                _permissionDenials,
                                Colors.red,
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Network Result:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem(
                                'Connected',
                                _connectionSuccesses,
                                Colors.green,
                              ),
                              _buildStatItem(
                                'Timed Out',
                                _connectionFailures,
                                Colors.orange,
                              ),
                            ],
                          ),
                          if (_isScanning) ...[
                            const SizedBox(height: 16),
                            const LinearProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Detected Interfaces:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                const SizedBox(height: 10),
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
                      onPressed: _requestPermission,
                      child: const Text('Request Permission'),
                    ),
                    ElevatedButton(
                      onPressed: _testStandardSocket,
                      child: const Text('Test AndroidLocalAreaSocket.connect'),
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
                  const Text(
                    'Found Devices:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
