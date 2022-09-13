import 'package:flutter/material.dart';

import '../post.dart';

/// A [Card] that displays a single [Post], intended to be used in a list.
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(post.author.handle),
                  const Spacer(),
                  Text('${post.time}'),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                post.text,
                style: Theme.of(context).textTheme.headline6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
