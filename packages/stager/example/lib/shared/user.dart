// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A person or entity that creates [Post]s.
class User {
  /// Creates a [User].
  User({
    required this.id,
    required this.name,
    required this.handle,
  });

  /// This user's ID.
  final int id;

  /// This user's full name.
  final String name;

  /// This user's @ handle.
  final String handle;

  /// A fake user named "Joe User".
  static User joeUser = User(
    id: 1,
    name: 'Joe User',
    handle: '@joe',
  );

  /// A fake user named "Alice User".
  static User aliceUser = User(
    id: 2,
    name: 'Alice User',
    handle: '@alice',
  );

  /// Creates a [User] with the given id.
  static User fakeUser({required int id}) => User(
        id: id,
        name: 'User $id',
        handle: '@user$id',
      );
}
