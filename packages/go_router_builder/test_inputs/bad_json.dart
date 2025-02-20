// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedGoRoute<BadJson>(path: '/')
class BadJson extends GoRouteData {
  const BadJson({required this.id});

  final JsonExample id;
}

class JsonExample {
  const JsonExample({required this.id});

  // mismach toJson
  factory JsonExample.toJson(dynamic json) {
    return const JsonExample(id: 'a');
  }
  // missing to Json

  final String id;
}
