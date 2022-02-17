// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'book.dart';

class Author {
  Author({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
  final List<Book> books = <Book>[];
}
