// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/shared/user.dart';

import 'post.dart';

class Api {
  Future<List<Post>> fetchPosts({User? user}) async {
    await Future.delayed(const Duration(seconds: 2));
    return Post.fakePosts(user: user);
  }
}
