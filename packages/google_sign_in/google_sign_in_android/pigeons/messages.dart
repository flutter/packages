// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOut:
      'android/src/main/java/io/flutter/plugins/googlesignin/Messages.java',
  javaOptions: JavaOptions(package: 'io.flutter.plugins.googlesignin'),
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon version of SignInOption.
enum SignInType {
  /// Default configuration.
  standard,

  /// Recommended configuration for game sign in.
  games,
}

/// Pigeon version of SignInInitParams.
///
/// See SignInInitParams for details.
class InitParams {
  /// The parameters to use when initializing the sign in process.
  const InitParams({
    this.scopes = const <String>[],
    this.signInType = SignInType.standard,
    this.hostedDomain,
    this.clientId,
    this.serverClientId,
    this.forceCodeForRefreshToken = false,
  });

  final List<String> scopes;
  final SignInType signInType;
  final String? hostedDomain;
  final String? clientId;
  final String? serverClientId;
  final bool forceCodeForRefreshToken;
}

/// Pigeon version of GoogleSignInUserData.
///
/// See GoogleSignInUserData for details.
class UserData {
  UserData({
    required this.email,
    required this.id,
    this.displayName,
    this.photoUrl,
    this.idToken,
    this.serverAuthCode,
  });

  final String? displayName;
  final String email;
  final String id;
  final String? photoUrl;
  final String? idToken;
  final String? serverAuthCode;
}

@HostApi()
abstract class GoogleSignInApi {
  /// Initializes a sign in request with the given parameters.
  void init(InitParams params);

  /// Starts a silent sign in.
  @async
  UserData signInSilently();

  /// Starts a sign in with user interaction.
  @async
  UserData signIn();

  /// Requests the access token for the current sign in.
  @async
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  String getAccessToken(String email, bool shouldRecoverAuth);

  /// Signs out the current user.
  @async
  void signOut();

  /// Revokes scope grants to the application.
  @async
  void disconnect();

  /// Returns whether the user is currently signed in.
  bool isSignedIn();

  /// Clears the authentication caching for the given token, requiring a
  /// new sign in.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  void clearAuthCache(String token);

  /// Requests access to the given scopes.
  @async
  bool requestScopes(List<String> scopes);
}
