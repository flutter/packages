// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web/web.dart' as html;

/// An extension on [html.Storage] that adds a convenience [keys] getter.
extension KeysExtension on html.Storage {
  /// Gets all the [keys] set in this [html.Storage].
  List<String> get keys {
    return <String>[for (int i = 0; i < length; i++) key(i)!];
  }
}
