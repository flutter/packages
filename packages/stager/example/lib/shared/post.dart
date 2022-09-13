// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'user.dart';

/// A single tweet-like entry.
class Post {
  /// Creates a [Post].
  Post({
    required this.id,
    required this.text,
    required this.author,
    required this.time,
  });

  /// The id of this post.
  final int id;

  /// The content of this post.
  final String text;

  /// The author of this post.
  final User author;

  /// When this post was created.
  final DateTime time;

  /// Generates a List of [Post]s. If [user] is specified, all posts will have
  /// that user as an author. If no [user] is specified, each [Post] will have a
  /// distinct fake [User] as its author.
  static List<Post> fakePosts({User? user}) => List<Post>.generate(
        20,
        (int index) => Post(
          id: index + 1,
          text: 'Post ${index + 1}',
          author: user ?? User.fakeUser(id: index + 1),
          time: DateTime.now(),
        ),
      );
}
