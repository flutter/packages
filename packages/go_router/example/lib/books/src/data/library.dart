// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'author.dart';
import 'book.dart';

/// Library data mock.
final Library libraryInstance = Library()
  ..addBook(
      title: 'Left Hand of Darkness',
      authorName: 'Ursula K. Le Guin',
      isPopular: true,
      isNew: true)
  ..addBook(
      title: 'Too Like the Lightning',
      authorName: 'Ada Palmer',
      isPopular: false,
      isNew: true)
  ..addBook(
      title: 'Kindred',
      authorName: 'Octavia E. Butler',
      isPopular: true,
      isNew: false)
  ..addBook(
      title: 'The Lathe of Heaven',
      authorName: 'Ursula K. Le Guin',
      isPopular: false,
      isNew: false);

/// A library that contains books and authors.
class Library {
  /// The books in the library.
  final List<Book> allBooks = <Book>[];

  /// The authors in the library.
  final List<Author> allAuthors = <Author>[];

  /// Adds a book into the library.
  void addBook({
    required String title,
    required String authorName,
    required bool isPopular,
    required bool isNew,
  }) {
    final Author author = allAuthors.firstWhere(
      (Author author) => author.name == authorName,
      orElse: () {
        final Author value = Author(id: allAuthors.length, name: authorName);
        allAuthors.add(value);
        return value;
      },
    );

    final Book book = Book(
      id: allBooks.length,
      title: title,
      isPopular: isPopular,
      isNew: isNew,
      author: author,
    );

    author.books.add(book);
    allBooks.add(book);
  }

  /// The list of popular books in the library.
  List<Book> get popularBooks => <Book>[
        ...allBooks.where((Book book) => book.isPopular),
      ];

  /// The list of new books in the library.
  List<Book> get newBooks => <Book>[
        ...allBooks.where((Book book) => book.isNew),
      ];
}
