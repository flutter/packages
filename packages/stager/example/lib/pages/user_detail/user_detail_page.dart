import 'package:example/shared/api.dart';
import 'package:example/shared/post.dart';
import 'package:example/shared/posts_list/posts_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/user.dart';

/// A page for a single [User].
class UserDetailPage extends StatefulWidget {
  final User user;

  const UserDetailPage({super.key, required this.user});

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
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '${widget.user.name} (${widget.user.handle})',
              style: Theme.of(context).textTheme.headline3,
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
