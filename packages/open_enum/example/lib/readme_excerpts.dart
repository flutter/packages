// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print, public_member_api_docs

import 'package:open_enum/open_enum.dart';

// #docregion Definition
extension type const UserRole._(String name) implements OpenEnum<String> {
  static const UserRole admin = UserRole._('admin');
  static const UserRole member = UserRole._('member');

  // We can add this in a minor update without breaking any consumer switches!
  static const UserRole guest = UserRole._('guest');

  // Provide a list of known values, just like standard enums.
  static const List<UserRole> values = [admin, member, guest];

  // #docregion IndexAndStringification
  /// Returns the index of this value in [values] list, matching standard enum `.index`.
  int get index => values.indexOf(this);

  /// Custom string representation (since extension types cannot override `toString()`).
  String get label => 'UserRole.$name';
  // #enddocregion IndexAndStringification
}
// #enddocregion Definition

// #docregion SwitchStatement
void handleRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      print('Access granted.');
    case UserRole.member:
      print('Standard access.');
    // Any unhandled values (like a newly added 'guest') will safely fall through!
  }
}

// #enddocregion SwitchStatement

// #docregion SwitchExpression
String getLabel(UserRole role) => switch (role) {
  UserRole.admin => 'Administrator',
  UserRole.member => 'Member',
  _ => 'Other', // Required by compiler, safe against future additions
};
// #enddocregion SwitchExpression

void usageExamples() {
  // #docregion ByValue
  final UserRole? role = UserRole.values.byValue('admin'); // Returns UserRole.admin
  final UserRole? invalid = UserRole.values.byValue('super-user'); // Returns null
  // #enddocregion ByValue

  // #docregion ByName
  // Throws ArgumentError if the name is not found, matching standard enum behavior
  final UserRole roleByName = UserRole.values.byName('admin');

  // Returns null if the name is not found (safer alternative)
  final UserRole? safeRole = UserRole.values.byNameOrNull('super-user');
  // #enddocregion ByName

  print('$role $invalid $roleByName $safeRole');
}

// #docregion DefinitionRecord
extension type const UserRoleRecord._(({int index, String name}) data) implements OpenEnumRecord {
  static const UserRoleRecord admin = UserRoleRecord._((index: 0, name: 'admin'));
  static const UserRoleRecord member = UserRoleRecord._((index: 1, name: 'member'));
  static const UserRoleRecord guest = UserRoleRecord._((index: 2, name: 'guest'));

  static const List<UserRoleRecord> values = [admin, member, guest];
}
// #enddocregion DefinitionRecord
