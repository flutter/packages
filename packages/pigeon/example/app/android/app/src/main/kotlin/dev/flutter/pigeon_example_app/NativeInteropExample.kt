// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeon_example_app

// #docregion concurrency-style
suspend fun echoAsync(value: String): String {
  return value
}
// #enddocregion concurrency-style
