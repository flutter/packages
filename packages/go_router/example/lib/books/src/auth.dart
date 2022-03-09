// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// A mock authentication service
class BookstoreAuth extends ChangeNotifier {
  bool _signedIn = false;

  /// Whether user has signed in.
  bool get signedIn => _signedIn;

  /// Signs out the current user.
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Sign out.
    _signedIn = false;
    notifyListeners();
  }

  /// Signs in a user.
  Future<bool> signIn(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn = true;
    notifyListeners();
    return _signedIn;
  }
}

/// An inherited notifier to host [BookstoreAuth] for the subtree.
class BookstoreAuthScope extends InheritedNotifier<BookstoreAuth> {
  /// Creates a [BookstoreAuthScope].
  const BookstoreAuthScope({
    required BookstoreAuth notifier,
    required Widget child,
    Key? key,
  }) : super(key: key, notifier: notifier, child: child);

  /// Gets the [BookstoreAuth] above the context.
  static BookstoreAuth of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<BookstoreAuthScope>()!
      .notifier!;
}
