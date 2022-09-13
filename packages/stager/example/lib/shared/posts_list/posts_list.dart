import 'package:flutter/material.dart';

import '../../pages/post_detail/post_detail_page.dart';
import '../post.dart';
import '../post_card/post_card.dart';

/// A [ListView] of [PostCard]s
class PostsList extends StatefulWidget {
  final Future<List<Post>> postsFuture;

  PostsList({Key? key, required List<Post> posts})
      : this.fromFuture(key: key, Future.value(posts));

  const PostsList.fromFuture(this.postsFuture, {super.key});

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error'),
          );
        }

        final posts = snapshot.data;
        if (posts == null || posts.isEmpty) {
          return const Center(
            child: Text('No posts'),
          );
        }

        return ListView.builder(
          itemBuilder: (context, index) => PostCard(
            post: posts[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(
                    post: posts[index],
                  ),
                ),
              );
            },
          ),
          itemCount: posts.length,
        );
      },
    );
  }
}
