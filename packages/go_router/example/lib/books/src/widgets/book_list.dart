// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../data.dart';

/// The book list view.
class BookList extends StatelessWidget {
  /// Creates an [BookList].
  const BookList({
    required this.books,
    this.onTap,
    Key? key,
  }) : super(key: key);

  /// The list of books to be displayed.
  final List<Book> books;

  /// Called when the user taps a book.
  final ValueChanged<Book>? onTap;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: books.length,
        itemBuilder: (BuildContext context, int index) => ListTile(
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
