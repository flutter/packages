import 'package:example/shared/posts_list/posts_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/api.dart';
import '../../shared/post.dart';

/// Shows a timeline view of all [Post]s.
class PostsListPage extends StatefulWidget {
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
