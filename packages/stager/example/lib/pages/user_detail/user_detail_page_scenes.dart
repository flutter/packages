// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:stager/stager.dart';

import '../../shared/api.dart';
import '../../shared/post.dart';
import '../../shared/user.dart';
import '../posts_list/posts_list_page_scenes.mocks.dart';
import 'user_detail_page.dart';

abstract class UserDetailPageScene extends Scene {
  late MockApi mockApi;
  User user = User.joeUser;

  @override
  Future<void> setUp() async {
    await super.setUp();
    mockApi = MockApi();
  }

  @override
  Widget build() {
    return Provider<Api>.value(
      value: mockApi,
      child: EnvironmentAwareApp(
        home: UserDetailPage(
          user: user,
        ),
      ),
    );
  }
}

class LoadingUserDetailPageScene extends UserDetailPageScene {
  @override
  String get title => 'Loading';

  @override
  Future<void> setUp() async {
    await super.setUp();
    when(mockApi.fetchPosts(user: user)).thenAnswer((_) {
      final Completer<List<Post>> completer = Completer<List<Post>>();
      return completer.future;
    });
  }
}

class ErrorUserDetailPageScene extends UserDetailPageScene {
  @override
  String get title => 'Error';

  @override
  Future<void> setUp() async {
    await super.setUp();
    when(mockApi.fetchPosts(user: user)).thenAnswer(
      (_) async => Future<List<Post>>.error(
        Exception('on no!'),
      ),
    );
  }
}

class EmptyUserDetailPageScene extends UserDetailPageScene {
  @override
  String get title => 'Empty';

  @override
  Future<void> setUp() async {
    await super.setUp();
    when(mockApi.fetchPosts(user: user)).thenAnswer((_) async => []);
  }
}

class WithPostsUserDetailPageScene extends UserDetailPageScene {
  @override
  String get title => 'With posts';

  @override
  Future<void> setUp() async {
    await super.setUp();
    when(mockApi.fetchPosts(user: user)).thenAnswer(
      (_) async => Post.fakePosts(user: user),
    );
  }
}

class ComplexUserDetailPageScene extends UserDetailPageScene {
  @override
  String get title => 'User with long name';

  @override
  Future<void> setUp() async {
    await super.setUp();
    user = User(
      id: 1234,
      handle: '@asdf',
      name: 'Super cool poster with great hot takes',
    );
    when(mockApi.fetchPosts(user: user)).thenAnswer(
      (_) async => Post.fakePosts(),
    );
  }
}
