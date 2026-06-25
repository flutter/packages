// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print, public_member_api_docs
// ignore_for_file: omit_obvious_local_variable_types, specify_nonobvious_local_variable_types

import 'dart:convert';
import 'package:open_enum/open_enum.dart';

/// Define our open enum for User Roles.
extension type const UserRole(String name) implements OpenEnum<String> {
  static const UserRole admin = UserRole('admin');
  static const UserRole member = UserRole('member');
  static const UserRole guest = UserRole('guest');

  /// A fallback role used when we encounter a value we don't recognize yet.
  static const UserRole unknown = UserRole('unknown');

  static const List<UserRole> values = [admin, member, guest, unknown];
}

/// A simple User model.
class User {
  User({required this.username, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    final String roleStr = json['role'] as String;

    // Safely deserialize to the open enum, falling back to 'unknown' if the
    // server sent a value we don't recognize yet.
    final UserRole role = UserRole.values.byNameOrNull(roleStr) ?? UserRole.unknown;

    return User(username: json['username'] as String, role: role);
  }

  final String username;
  final UserRole role;

  @override
  String toString() => '$username ($role)';
}

void main() {
  print('--- Simulating API Client with Open Enums ---\n');

  // 1. Simulating a response payload representing users with currently known roles.
  const String currentPayload = '''
  [
    {"username": "alice", "role": "admin"},
    {"username": "bob", "role": "member"},
    {"username": "charlie", "role": "guest"}
  ]
  ''';

  print('1. Parsing current server payload...');
  final List<dynamic> currentJson = jsonDecode(currentPayload) as List<dynamic>;
  final List<User> currentUsers = currentJson
      .map((dynamic item) => User.fromJson(item as Map<String, dynamic>))
      .toList();

  for (final User user in currentUsers) {
    print('   Parsed user: $user');
    _processUserDashboard(user);
  }

  print('\n----------------------------------------\n');

  // 2. Simulating a FUTURE payload where the server has evolved and introduced
  // a brand new role: "moderator".
  //
  // Normally, a standard enum package would crash during deserialization or
  // break client compile-time switches. With open_enum, it is handled gracefully.
  const String futurePayload = '''
  [
    {"username": "diana", "role": "moderator"},
    {"username": "ethan", "role": "member"}
  ]
  ''';

  print('2. Parsing evolved server payload containing new "moderator" role...');
  final List<dynamic> futureJson = jsonDecode(futurePayload) as List<dynamic>;
  final List<User> futureUsers = futureJson
      .map((dynamic item) => User.fromJson(item as Map<String, dynamic>))
      .toList();

  for (final User user in futureUsers) {
    print('   Parsed user: $user');
    _processUserDashboard(user);
  }
}

/// Simulates a dashboard that processes users differently based on their role.
void _processUserDashboard(User user) {
  // We switch on the open enum. In a statement switch, we don't have to be
  // exhaustive, so newly added values safely fall through to the default action.
  switch (user.role) {
    case UserRole.admin:
      print('   [Dashboard] Granting Admin full panel access.');
    case UserRole.member:
      print('   [Dashboard] Displaying standard member dashboard.');
    case UserRole.guest:
      print('   [Dashboard] Showing guest landing page with signup prompt.');
    case UserRole.unknown:
    default:
      // This catches 'unknown' (which represents the new 'moderator' role we don't
      // know how to handle yet). The app continues running perfectly!
      print('   [Dashboard] Unrecognized/unsupported role. Defaulting to safe guest-view.');
  }
}
