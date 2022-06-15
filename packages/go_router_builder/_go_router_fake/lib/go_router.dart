// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

export 'src/route_data.dart';

abstract class BuildContext {
  void go(String location, {Object? extra}) => throw UnimplementedError();
}
