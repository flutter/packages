// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../shared/post.dart';
import '../user_detail/user_detail_page.dart';

/// A page for a single [Post].
class PostDetailPage extends StatelessWidget {
  /// Creates a [PostDetailPage].
  const PostDetailPage({super.key, required this.post});

  /// The [Post] being displayed.
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: <PopupMenuButton<int>>[
          PopupMenuButton<int>(
            onSelected: (_) {
              final NavigatorState navigatorstate = Navigator.of(context);
              navigatorstate.push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      UserDetailPage(user: post.author),
                ),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 0,
                child: Text('View User'),
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  child: Text(
                    post.author.name
                        .split(' ')
                        .map((String e) => e[0].toUpperCase())
                        .join(),
                  ),
                ),
                const SizedBox(width: 10),
                Text(post.time.toString()),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.text,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
