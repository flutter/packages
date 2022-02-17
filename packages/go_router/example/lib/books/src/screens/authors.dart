// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/library.dart';
import '../widgets/author_list.dart';

class AuthorsScreen extends StatelessWidget {
  const AuthorsScreen({Key? key}) : super(key: key);

  static const title = 'Authors';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: AuthorList(
          authors: libraryInstance.allAuthors,
          onTap: (author) {
            context.go('/author/${author.id}');
          },
        ),
      );
}
