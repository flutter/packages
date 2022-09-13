// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../post.dart';

/// A [Card] that displays a single [Post], intended to be used in a list.
class PostCard extends StatelessWidget {
  /// Creates a tappable [PostCard] displaying [post].
  const PostCard({super.key, required this.post, this.onTap});

  /// The post being displayed.
  final Post post;

  /// Executed when this [PostCard] is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(post.author.handle),
                  const Spacer(),
                  Text('${post.time}'),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                post.text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
