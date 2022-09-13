import 'package:example/shared/user.dart';

import 'post.dart';

class Api {
  Future<List<Post>> fetchPosts({User? user}) async {
    await Future.delayed(const Duration(seconds: 2));
    return Post.fakePosts(user: user);
  }
}
