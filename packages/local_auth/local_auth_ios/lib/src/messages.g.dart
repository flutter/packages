// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v9.2.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

/// Possible outcomes of an authentication attempt.
enum AuthResult {
  /// The user authenticated successfully.
  success,

  /// The user failed to successfully authenticate.
  failure,

  /// The authentication system was not available.
  errorNotAvailable,

  /// No biometrics are enrolled.
  errorNotEnrolled,

  /// No passcode is set.
  errorPasscodeNotSet,
}

/// Pigeon equivalent of the subset of BiometricType used by iOS.
enum AuthBiometric {
  face,
  fingerprint,
}

/// Pigeon version of IOSAuthMessages, plus the authorization reason.
///
/// See auth_messages_ios.dart for details.
class AuthStrings {
  AuthStrings({
    required this.reason,
    required this.lockOut,
    required this.goToSettingsButton,
    required this.goToSettingsDescription,
    required this.cancelButton,
    this.localizedFallbackTitle,
  });

  String reason;

  String lockOut;

  String goToSettingsButton;

  String goToSettingsDescription;

  String cancelButton;

  String? localizedFallbackTitle;

  Object encode() {
    return <Object?>[
      reason,
      lockOut,
      goToSettingsButton,
      goToSettingsDescription,
      cancelButton,
      localizedFallbackTitle,
    ];
  }

  static AuthStrings decode(Object result) {
    result as List<Object?>;
    return AuthStrings(
      reason: result[0]! as String,
      lockOut: result[1]! as String,
      goToSettingsButton: result[2]! as String,
      goToSettingsDescription: result[3]! as String,
      cancelButton: result[4]! as String,
      localizedFallbackTitle: result[5] as String?,
    );
  }
}

class AuthOptions {
  AuthOptions({
    required this.biometricOnly,
    required this.sticky,
    required this.useErrorDialgs,
  });

  bool biometricOnly;

  bool sticky;

  bool useErrorDialgs;

  Object encode() {
    return <Object?>[
      biometricOnly,
      sticky,
      useErrorDialgs,
    ];
  }

  static AuthOptions decode(Object result) {
    result as List<Object?>;
    return AuthOptions(
      biometricOnly: result[0]! as bool,
      sticky: result[1]! as bool,
      useErrorDialgs: result[2]! as bool,
    );
  }
}

class AuthResultDetails {
  AuthResultDetails({
    required this.value,
    this.errorMessage,
    this.errorDetails,
  });

  /// The result of authenticating.
  AuthResult value;

  /// A system-provided error message, if any.
  String? errorMessage;

  /// System-provided error details, if any.
  String? errorDetails;

  Object encode() {
    return <Object?>[
      value.index,
      errorMessage,
      errorDetails,
    ];
  }

  static AuthResultDetails decode(Object result) {
    result as List<Object?>;
    return AuthResultDetails(
      value: AuthResult.values[result[0]! as int],
      errorMessage: result[1] as String?,
      errorDetails: result[2] as String?,
    );
  }
}

class AuthBiometricWrapper {
  AuthBiometricWrapper({
    required this.value,
  });

  AuthBiometric value;

  Object encode() {
    return <Object?>[
      value.index,
    ];
  }

  static AuthBiometricWrapper decode(Object result) {
    result as List<Object?>;
    return AuthBiometricWrapper(
      value: AuthBiometric.values[result[0]! as int],
    );
  }
}

class _LocalAuthApiCodec extends StandardMessageCodec {
  const _LocalAuthApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is AuthBiometricWrapper) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is AuthOptions) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else if (value is AuthResultDetails) {
      buffer.putUint8(130);
      writeValue(buffer, value.encode());
    } else if (value is AuthStrings) {
      buffer.putUint8(131);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return AuthBiometricWrapper.decode(readValue(buffer)!);
      case 129:
        return AuthOptions.decode(readValue(buffer)!);
      case 130:
        return AuthResultDetails.decode(readValue(buffer)!);
      case 131:
        return AuthStrings.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class LocalAuthApi {
  /// Constructor for [LocalAuthApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  LocalAuthApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _LocalAuthApiCodec();

  /// Returns true if this device supports authentication.
  Future<bool> isDeviceSupported() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.LocalAuthApi.isDeviceSupported', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as bool?)!;
    }
  }

  /// Returns true if this device can support biometric authentication, whether
  /// any biometrics are enrolled or not.
  Future<bool> deviceCanSupportBiometrics() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.LocalAuthApi.deviceCanSupportBiometrics', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as bool?)!;
    }
  }

  /// Returns the biometric types that are enrolled, and can thus be used
  /// without additional setup.
  Future<List<AuthBiometricWrapper?>> getEnrolledBiometrics() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.LocalAuthApi.getEnrolledBiometrics', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as List<Object?>?)!.cast<AuthBiometricWrapper?>();
    }
  }

  /// Attempts to authenticate the user with the provided [options], and using
  /// [strings] for any UI.
  Future<AuthResultDetails> authenticate(
      AuthOptions arg_options, AuthStrings arg_strings) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.LocalAuthApi.authenticate', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel
        .send(<Object?>[arg_options, arg_strings]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as AuthResultDetails?)!;
    }
  }
}
