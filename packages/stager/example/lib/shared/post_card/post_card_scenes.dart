// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:stager/stager.dart';

import '../post.dart';
import '../user.dart';
import 'post_card.dart';

/// A Scene showing a single [PostCard] widget with a fake [Post].
class PostCardScene extends Scene {
  @override
  String get title => 'Single Card';

  @override
  Widget build() {
    return PostCard(
      post: Post.fakePosts().first,
      onTap: () {},
    );
  }
}

/// A Scene showing a [PostsList] with fake [Post]s.
class PostsListScene extends Scene {
  /// The posts being shown in this scene.
  final List<Post> posts = <Post>[
    Post(
      id: 1,
      author: User.joeUser,
      text: 'Hello, this is a post',
      time: DateTime(2022, 7, 28, 10, 30),
    ),
    Post(
      id: 2,
      author: User.aliceUser,
      text: 'Hi, Joe! Nice to hear from you. This is a much longer reply '
          'intended to test text wrapping in the PostCard widget.',
      time: DateTime(2022, 7, 28, 11, 30),
    ),
    Post(
      id: 3,
      author: User.joeUser,
      text: 'Hi Alice! Thanks for testing that.',
      time: DateTime(2022, 7, 28, 11, 45),
    ),
  ];

  @override
  String get title => 'Card List';

  @override
  Widget build() {
    return EnvironmentAwareApp(
      home: Builder(
        builder: (BuildContext context) => Container(
          color: Theme.of(context).colorScheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) => PostCard(
              post: posts[index],
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }
}
