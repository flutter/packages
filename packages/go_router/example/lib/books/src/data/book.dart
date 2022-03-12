// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'author.dart';

/// Book data class.
class Book {
  /// Creates a book data object.
  Book({
    required this.id,
    required this.title,
    required this.isPopular,
    required this.isNew,
    required this.author,
  });

  /// The id of the book.
  final int id;

  /// The title of the book.
  final String title;

  /// The author of the book.
  final Author author;

  /// Whether the book is popular.
  final bool isPopular;

  /// Whether the book is new.
  final bool isNew;
}
