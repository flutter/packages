// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/api.dart';
import '../../shared/post.dart';
import '../../shared/posts_list/posts_list.dart';

/// Shows a timeline view of all [Post]s.
class PostsListPage extends StatefulWidget {
  /// Creates a [PostsListPage].
  const PostsListPage({super.key});

  @override
  State<PostsListPage> createState() => _PostsListPageState();
}

class _PostsListPageState extends State<PostsListPage> {
  late Future<List<Post>> _fetchPostsFuture;

  @override
  void initState() {
    super.initState();
    _fetchPostsFuture = Provider.of<Api>(context, listen: false).fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: PostsList.fromFuture(_fetchPostsFuture),
    );
  }
}
