// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'post.dart';
import 'user.dart';

/// A fake class meant to represent an API client.
class Api {
  /// Waits 2 seconds and returns [Post.fakePosts].
  Future<List<Post>> fetchPosts({User? user}) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return Post.fakePosts(user: user);
  }
}
