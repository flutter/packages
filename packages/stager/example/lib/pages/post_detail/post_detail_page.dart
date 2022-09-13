import 'package:example/pages/user_detail/user_detail_page.dart';
import 'package:example/shared/post.dart';
import 'package:flutter/material.dart';

/// A page for a single [Post].
class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          PopupMenuButton(
            onSelected: (_) {
              final navigatorstate = Navigator.of(context);
              navigatorstate.push(
                MaterialPageRoute(
                  builder: (context) => UserDetailPage(user: post.author),
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
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    post.author.name
                        .split(' ')
                        .map((e) => e[0].toUpperCase())
                        .join(''),
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
