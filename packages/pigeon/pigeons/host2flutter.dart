// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  objcOptions: ObjcOptions(
    prefix: 'H2F',
  ),
))
class Host2FlutterSearchRequest {
  String? query;
}

class Host2FlutterSearchReply {
  String? result;
}

@FlutterApi()
abstract class H2FApi {
  Host2FlutterSearchReply search(Host2FlutterSearchRequest request);
}
