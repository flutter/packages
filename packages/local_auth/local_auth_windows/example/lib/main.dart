// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  _SupportState _supportState = _SupportState.unknown;
  bool? _deviceSupportsBiometrics;
  List<BiometricType>? _enrolledBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    LocalAuthPlatform.instance.isDeviceSupported().then(
      (bool isSupported) => setState(
        () =>
            _supportState =
                isSupported
                    ? _SupportState.supported
                    : _SupportState.unsupported,
      ),
    );
  }

  Future<void> _checkBiometrics() async {
    late bool deviceSupportsBiometrics;
    try {
      deviceSupportsBiometrics =
          await LocalAuthPlatform.instance.deviceSupportsBiometrics();
    } on PlatformException catch (e) {
      deviceSupportsBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _deviceSupportsBiometrics = deviceSupportsBiometrics;
    });
  }

  Future<void> _getEnrolledBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics =
          await LocalAuthPlatform.instance.getEnrolledBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _enrolledBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await LocalAuthPlatform.instance.authenticate(
        localizedReason: 'Let OS determine authentication method',
        authMessages: <AuthMessages>[const WindowsAuthMessages()],
        options: const AuthenticationOptions(stickyAuth: true),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
      () => _authorized = authenticated ? 'Authorized' : 'Not Authorized',
    );
  }

  Future<void> _cancelAuthentication() async {
    await LocalAuthPlatform.instance.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: ListView(
          padding: const EdgeInsets.only(top: 30),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_supportState == _SupportState.unknown)
                  const CircularProgressIndicator()
                else if (_supportState == _SupportState.supported)
                  const Text('This device is supported')
                else
                  const Text('This device is not supported'),
                const Divider(height: 100),
                Text(
                  'Device supports biometrics: $_deviceSupportsBiometrics\n',
                ),
                ElevatedButton(
                  onPressed: _checkBiometrics,
                  child: const Text('Check biometrics'),
                ),
                const Divider(height: 100),
                Text('Enrolled biometrics: $_enrolledBiometrics\n'),
                ElevatedButton(
                  onPressed: _getEnrolledBiometrics,
                  child: const Text('Get enrolled biometrics'),
                ),
                const Divider(height: 100),
                Text('Current State: $_authorized\n'),
                if (_isAuthenticating)
                  ElevatedButton(
                    onPressed: _cancelAuthentication,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Cancel Authentication'),
                        Icon(Icons.cancel),
                      ],
                    ),
                  )
                else
                  Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _authenticate,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Authenticate'),
                            Icon(Icons.perm_device_information),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _SupportState { unknown, supported, unsupported }
