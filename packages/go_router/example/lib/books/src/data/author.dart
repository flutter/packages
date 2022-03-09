// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'book.dart';

/// Author data class.
class Author {
  /// Creates an author data object.
  Author({
    required this.id,
    required this.name,
  });

  /// The id of the author.
  final int id;

  /// The name of the author.
  final String name;

  /// The books of the author.
  final List<Book> books = <Book>[];
}
