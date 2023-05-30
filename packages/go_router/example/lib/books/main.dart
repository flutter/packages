// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'src/auth.dart';
import 'src/data/author.dart';
import 'src/data/book.dart';
import 'src/data/library.dart';
import 'src/screens/author_details.dart';
import 'src/screens/authors.dart';
import 'src/screens/book_details.dart';
import 'src/screens/books.dart';
import 'src/screens/scaffold.dart';
import 'src/screens/settings.dart';
import 'src/screens/sign_in.dart';

void main() => runApp(Bookstore());

/// The book store view.
class Bookstore extends StatelessWidget {
  /// Creates a [Bookstore].
  Bookstore({super.key});

  final ValueKey<String> _scaffoldKey = const ValueKey<String>('App scaffold');

  @override
  Widget build(BuildContext context) => BookstoreAuthScope(
        notifier: _auth,
        child: MaterialApp.router(
          routerConfig: _router,
        ),
      );

  final BookstoreAuth _auth = BookstoreAuth();

  late final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        redirect: (_, __) => '/books',
      ),
      GoRoute(
        path: '/signin',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            FadeTransitionPage(
          key: state.pageKey,
          child: SignInScreen(
            onSignIn: (Credentials credentials) {
              BookstoreAuthScope.of(context)
                  .signIn(credentials.username, credentials.password);
            },
          ),
        ),
      ),
      GoRoute(
        path: '/books',
        redirect: (_, __) => '/books/popular',
      ),
      GoRoute(
        path: '/book/:bookId',
        redirect: (BuildContext context, GoRouterState state) =>
            '/books/all/${state.pathParameters['bookId']}',
      ),
      GoRoute(
        path: '/books/:kind(new|all|popular)',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            FadeTransitionPage(
          key: _scaffoldKey,
          child: BookstoreScaffold(
            selectedTab: ScaffoldTab.books,
            child: BooksScreen(state.pathParameters['kind']!),
          ),
        ),
        routes: <GoRoute>[
          GoRoute(
            path: ':bookId',
            builder: (BuildContext context, GoRouterState state) {
              final String bookId = state.pathParameters['bookId']!;
              final Book? selectedBook = libraryInstance.allBooks
                  .firstWhereOrNull((Book b) => b.id.toString() == bookId);

              return BookDetailsScreen(book: selectedBook);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/author/:authorId',
        redirect: (BuildContext context, GoRouterState state) =>
            '/authors/${state.pathParameters['authorId']}',
      ),
      GoRoute(
        path: '/authors',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            FadeTransitionPage(
          key: _scaffoldKey,
          child: const BookstoreScaffold(
            selectedTab: ScaffoldTab.authors,
            child: AuthorsScreen(),
          ),
        ),
        routes: <GoRoute>[
          GoRoute(
            path: ':authorId',
            builder: (BuildContext context, GoRouterState state) {
              final int authorId = int.parse(state.pathParameters['authorId']!);
              final Author? selectedAuthor = libraryInstance.allAuthors
                  .firstWhereOrNull((Author a) => a.id == authorId);

              return AuthorDetailsScreen(author: selectedAuthor);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            FadeTransitionPage(
          key: _scaffoldKey,
          child: const BookstoreScaffold(
            selectedTab: ScaffoldTab.settings,
            child: SettingsScreen(),
          ),
        ),
      ),
    ],
    redirect: _guard,
    refreshListenable: _auth,
    debugLogDiagnostics: true,
  );

  String? _guard(BuildContext context, GoRouterState state) {
    final bool signedIn = _auth.signedIn;
    final bool signingIn = state.matchedLocation == '/signin';

    // Go to /signin if the user is not signed in
    if (!signedIn && !signingIn) {
      return '/signin';
    }
    // Go to /books if the user is signed in and tries to go to /signin.
    else if (signedIn && signingIn) {
      return '/books';
    }

    // no redirect
    return null;
  }
}

/// A page that fades in an out.
class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [FadeTransitionPage].
  FadeTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                FadeTransition(
                  opacity: animation.drive(_curveTween),
                  child: child,
                ));

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}
