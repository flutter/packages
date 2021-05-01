// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/objc_generator.dart';
import 'package:pigeon/pigeon.dart';

class SearchRequest {
  String? query;
}

class SearchReply {
  String? result;
}

@FlutterApi()
abstract class Api {
  SearchReply search(SearchRequest request);
}

void configurePigeon(PigeonOptions options) {
  options.objcOptions ??= ObjcOptions();
  options.objcOptions?.prefix = 'AC';
}
