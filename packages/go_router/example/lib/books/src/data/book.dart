// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'author.dart';

class Book {
  Book({
    required this.id,
    required this.title,
    required this.isPopular,
    required this.isNew,
    required this.author,
  });

  final int id;
  final String title;
  final Author author;
  final bool isPopular;
  final bool isNew;
}
