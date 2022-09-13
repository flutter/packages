import 'package:example/shared/post_card/post_card.dart';
import 'package:example/shared/user.dart';
import 'package:flutter/material.dart';
import 'package:stager/stager.dart';

import '../post.dart';

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

class PostsListScene extends Scene {
  final posts = [
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
        builder: (context) => Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) => PostCard(
              post: posts[index],
              onTap: () {},
            ),
          ),
        ),
      ),
    );
  }
}
