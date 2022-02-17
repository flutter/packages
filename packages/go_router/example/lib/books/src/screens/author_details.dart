// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data.dart';
import '../widgets/book_list.dart';

class AuthorDetailsScreen extends StatelessWidget {
  const AuthorDetailsScreen({
    required this.author,
    Key? key,
  }) : super(key: key);

  final Author? author;

  @override
  Widget build(BuildContext context) {
    if (author == null) {
      return const Scaffold(
        body: Center(
          child: Text('No author found.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(author!.name),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: BookList(
                books: author!.books,
                onTap: (book) => context.go('/book/${book.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
