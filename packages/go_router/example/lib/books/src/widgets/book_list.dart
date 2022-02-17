// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../data.dart';

class BookList extends StatelessWidget {
  const BookList({
    required this.books,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final List<Book> books;
  final ValueChanged<Book>? onTap;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            books[index].title,
          ),
          subtitle: Text(
            books[index].author.name,
          ),
          onTap: onTap != null ? () => onTap!(books[index]) : null,
        ),
      );
}
