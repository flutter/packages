// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A person or entity that creates [Post]s.
class User {
  final int id;
  final String name;
  final String handle;

  User({
    required this.id,
    required this.name,
    required this.handle,
  });

  static User joeUser = User(
    id: 1,
    name: 'Joe User',
    handle: '@joe',
  );

  static User aliceUser = User(
    id: 2,
    name: 'Alice User',
    handle: '@alice',
  );

  static User fakeUser({required int id}) => User(
        id: id,
        name: 'User $id',
        handle: '@user$id',
      );
}
