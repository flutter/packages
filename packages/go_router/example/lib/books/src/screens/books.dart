// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data.dart';
import '../widgets/book_list.dart';

/// A screen that displays a list of books.
class BooksScreen extends StatefulWidget {
  /// Creates a [BooksScreen].
  const BooksScreen(this.kind, {Key? key}) : super(key: key);

  /// Which tab to display.
  final String kind;

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didUpdateWidget(BooksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    switch (widget.kind) {
      case 'popular':
        _tabController.index = 0;
        break;

      case 'new':
        _tabController.index = 1;
        break;

      case 'all':
        _tabController.index = 2;
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Books'),
          bottom: TabBar(
            controller: _tabController,
            onTap: _handleTabTapped,
            tabs: const <Tab>[
              Tab(
                text: 'Popular',
                icon: Icon(Icons.people),
              ),
              Tab(
                text: 'New',
                icon: Icon(Icons.new_releases),
              ),
              Tab(
                text: 'All',
                icon: Icon(Icons.list),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            BookList(
              books: libraryInstance.popularBooks,
              onTap: (Book book) {
                _handleBookTapped(kind: widget.kind, book: book);
              },
            ),
            BookList(
              books: libraryInstance.newBooks,
              onTap: (Book book) {
                _handleBookTapped(kind: widget.kind, book: book);
              },
            ),
            BookList(
              books: libraryInstance.allBooks,
              onTap: (Book book) {
                _handleBookTapped(kind: widget.kind, book: book);
              },
            ),
          ],
        ),
      );

  void _handleBookTapped({
    required String kind,
    required Book book,
  }) {
    context.go(
      '/book/$kind/${book.id}',
    );
  }

  void _handleTabTapped(int index) {
    switch (index) {
      case 1:
        context.go('/books/new');
        break;
      case 2:
        context.go('/books/all');
        break;
      case 0:
      default:
        context.go('/books/popular');
        break;
    }
  }
}
