// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/api.dart';
import '../../shared/post.dart';
import '../../shared/posts_list/posts_list.dart';
import '../../shared/user.dart';

/// A page for a single [User].
class UserDetailPage extends StatefulWidget {
  /// Creates a [UserDetailPage] which displays information about [user].
  const UserDetailPage({super.key, required this.user});

  /// The [User] whose info is being displayed.
  final User user;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late Future<List<Post>> _userPostsFuture;

  @override
  void initState() {
    super.initState();

    _userPostsFuture = Provider.of<Api>(context, listen: false).fetchPosts(
      user: widget.user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.name,
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '${widget.user.name} (${widget.user.handle})',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          Expanded(
            child: PostsList.fromFuture(_userPostsFuture),
          ),
        ],
      ),
    );
  }
}
