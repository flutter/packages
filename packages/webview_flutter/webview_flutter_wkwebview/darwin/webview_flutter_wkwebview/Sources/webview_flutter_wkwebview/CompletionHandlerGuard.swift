// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Wraps a WebKit completion handler that is resolved by a reply from Dart and ensures it is
/// eventually called exactly once.
///
/// WebKit raises an `NSInternalInconsistencyException` if a completion handler is deallocated
/// without being called. A reply from Dart may never arrive, e.g. when the Flutter engine is
/// destroyed while a call is pending, which releases the reply closure that holds the handler. If
/// this object is deallocated before it is called, it calls the handler with `defaultValue`.
final class CompletionHandlerGuard<Value: Sendable> {
  private var handler: (@MainActor (Value) -> Void)?
  private let defaultValue: Value

  init(defaultValue: Value, handler: @escaping @MainActor (Value) -> Void) {
    self.defaultValue = defaultValue
    self.handler = handler
  }

  /// Calls the handler with `value` if it has not been called yet.
  @MainActor func callAsFunction(_ value: Value) {
    guard let handler else {
      return
    }
    self.handler = nil
    handler(value)
  }

  deinit {
    guard let handler else {
      return
    }
    let value = defaultValue
    DispatchQueue.main.async { @MainActor in
      handler(value)
    }
  }
}

extension CompletionHandlerGuard where Value == Void {
  convenience init(handler: @escaping @MainActor () -> Void) {
    self.init(defaultValue: ()) { _ in handler() }
  }

  /// Calls the handler if it has not been called yet.
  @MainActor func callAsFunction() {
    self(())
  }
}

extension CompletionHandlerGuard {
  convenience init<First: Sendable, Second: Sendable>(
    defaultValue: (First, Second), handler: @escaping @MainActor (First, Second) -> Void
  ) where Value == (First, Second) {
    self.init(defaultValue: defaultValue) { value in handler(value.0, value.1) }
  }

  /// Calls the handler with `first` and `second` if it has not been called yet.
  @MainActor func callAsFunction<First: Sendable, Second: Sendable>(
    _ first: First, _ second: Second
  )
  where Value == (First, Second) {
    self((first, second))
  }
}
