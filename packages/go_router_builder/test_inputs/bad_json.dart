// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $BadJson {}

@TypedGoRoute<BadJson>(path: '/')
class BadJson extends GoRouteData with $BadJson {
  const BadJson({required this.id});

  final JsonExample id;
}

class JsonExample {
  const JsonExample({required this.id});

  // json parameter is not a Map<String, dynamic>
  factory JsonExample.fromJson(/*Map<String, dynamic>*/ dynamic json) {
    return JsonExample(id: (json as Map<String, dynamic>)['a'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id};
  }

  final String id;
}
