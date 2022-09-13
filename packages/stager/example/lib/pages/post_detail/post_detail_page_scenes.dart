// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:stager/stager.dart';

import '../../shared/post.dart';
import 'post_detail_page.dart';

/// A scene demonstrating a [PostDetailPage] with content.
class PostDetailPageScene extends Scene {
  @override
  String get title => 'Post Detail';

  @override
  Widget build() {
    return EnvironmentAwareApp(
      home: PostDetailPage(
        post: Post.fakePosts().first,
      ),
    );
  }
}
