// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

// #docregion callback-style
func echoAsync(_ value: String, completion: @escaping (Result<String, Error>) -> Void) {
  completion(.success(value))
}
// #enddocregion callback-style

// #docregion concurrency-style
func echoAsync(_ value: String) async throws -> String {
  return value
}
// #enddocregion concurrency-style
