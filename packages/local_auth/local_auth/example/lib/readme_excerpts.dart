// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// ignore_for_file: public_member_api_docs, avoid_print

import 'package:flutter/material.dart';
// #docregion ErrorHandling
// #docregion CanCheck
import 'package:local_auth/local_auth.dart';
// #enddocregion CanCheck
// #enddocregion ErrorHandling

// #docregion CustomMessages
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
// #enddocregion CustomMessages

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // #docregion CanCheck
  // #docregion ErrorHandling
  final LocalAuthentication auth = LocalAuthentication();
  // #enddocregion CanCheck
  // #enddocregion ErrorHandling

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('README example app')),
        body: const Text('See example in main.dart'),
      ),
    );
  }

  Future<void> checkSupport() async {
    // #docregion CanCheck
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    // #enddocregion CanCheck

    print('Can authenticate: $canAuthenticate');
    print('Can authenticate with biometrics: $canAuthenticateWithBiometrics');
  }

  Future<void> getEnrolledBiometrics() async {
    // #docregion Enrolled
    final List<BiometricType> availableBiometrics = await auth
        .getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
    }

    if (availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.face)) {
      // Specific types of biometrics are available.
      // Use checks like this with caution!
    }
    // #enddocregion Enrolled
  }

  Future<void> authenticateWithBiometrics() async {
    // #docregion AuthBioOnly
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to show account balance',
      biometricOnly: true,
    );
    // #enddocregion AuthBioOnly
    print(didAuthenticate);
  }

  Future<void> authenticateWithErrorHandling() async {
    // #docregion ErrorHandling
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
      );
      // #enddocregion ErrorHandling
      print(didAuthenticate ? 'Success!' : 'Failure');
      // #docregion ErrorHandling
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.noBiometricHardware) {
        // Add handling of no hardware here.
      } else if (e.code == LocalAuthExceptionCode.temporaryLockout ||
          e.code == LocalAuthExceptionCode.biometricLockout) {
        // ...
      } else {
        // ...
      }
    }
    // #enddocregion ErrorHandling
  }

  Future<void> authenticateWithCustomDialogMessages() async {
    // #docregion CustomMessages
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to show account balance',
      authMessages: const <AuthMessages>[
        AndroidAuthMessages(
          signInTitle: 'Oops! Biometric authentication required!',
          cancelButton: 'No thanks',
        ),
        IOSAuthMessages(cancelButton: 'No thanks'),
      ],
    );
    // #enddocregion CustomMessages
    print(didAuthenticate ? 'Success!' : 'Failure');
  }
}
