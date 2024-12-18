// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

@immutable

/// A class that represents the state of an asynchronous operation.
///
/// It has three possible states:
///
/// 1. [AsyncState.loading] - The operation is in progress.
/// 2. [AsyncState.data] - The operation has completed successfully with data.
/// 3. [AsyncState.error] - The operation has completed with an error.
///
/// Since this is a sealed class we can check the state in a switch statement/expression.
/// Check the [Switch statements](https://dart.dev/language/branches#switch-statements) documentation.
sealed class AsyncState<T> {
  const AsyncState();

  const factory AsyncState.loading() = AsyncStateLoading<T>._;

  const factory AsyncState.data(T data) = AsyncStateData<T>._;

  const factory AsyncState.error(Object error, StackTrace? stackTrace) =
      AsyncStateError<T>._;

  /// Returns a [AsyncState] with the same type `T` but with the data transformed by the `onData` function.
  /// If the current state is not [AsyncStateData], it returns the current state.
  AsyncState<T> whenData(
    T Function(T data) onData,
  ) {
    return switch (this) {
      AsyncStateData<T>(data: final T data) => AsyncState<T>.data(onData(data)),
      _ => this,
    };
  }

  /// Returns a [AsyncState] with the value R transformed by the `onData`
  /// function.
  ///
  /// If the current state is [AsyncStateLoading] or [AsyncStateError], it
  /// returns the current state, but with the type mapped.
  /// If the current state is [AsyncStateData], it returns a new data state with
  /// the data transformed by the `onData` function.
  AsyncState<R> mapWhenData<R>(
    R Function(T data) onData,
  ) {
    return flatMapWhenData((T data) => AsyncState<R>.data(onData(data)));
  }

  /// Transforms the data within an [AsyncState] into another [AsyncState] of a
  /// different type using the `onData` function.
  ///
  /// If the current state is [AsyncStateLoading] or [AsyncStateError], it
  /// returns the current state, but with the type mapped.
  /// If the current state is [AsyncStateData], it returns the result of the
  /// `onData` function.
  AsyncState<R> flatMapWhenData<R>(
    AsyncState<R> Function(T data) onData,
  ) {
    return switch (this) {
      AsyncStateData<T>(data: final T data) => onData(data),
      AsyncStateError<T>(
        error: final Object error,
        stackTrace: final StackTrace? stackTrace,
      ) =>
        AsyncState<R>.error(error, stackTrace),
      AsyncState<T>() => AsyncState<R>.loading(),
    };
  }

  /// Returns the data `T` if the current state is [AsyncStateData], otherwise returns `null`.
  T? get dataOrNull {
    return switch (this) {
      AsyncStateData<T>(data: final T data) => data,
      _ => null,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        switch (this) {
          AsyncStateLoading<T>() => other is AsyncStateLoading<T>,
          AsyncStateData<T>(data: final T data) =>
            other is AsyncStateData<T> && other.data == data,
          AsyncStateError<T>(
            error: final Object error,
            stackTrace: final StackTrace? stackTrace,
          ) =>
            other is AsyncStateError<T> &&
                other.error == error &&
                other.stackTrace == stackTrace,
        };
  }

  @override
  int get hashCode => switch (this) {
        AsyncStateLoading<T>() => 0,
        AsyncStateData<T>(data: final T data) => data.hashCode,
        AsyncStateError<T>(
          error: final Object error,
          stackTrace: final StackTrace? stackTrace,
        ) =>
          error.hashCode ^ stackTrace.hashCode,
      };

  @override
  String toString() {
    return switch (this) {
      AsyncStateLoading<T>() => 'AsyncState.loading()',
      AsyncStateData<T>(data: final T data) => 'AsyncState.data($data)',
      AsyncStateError<T>(
        error: final Object error,
        stackTrace: final StackTrace? stackTrace,
      ) =>
        'AsyncState.error($error, $stackTrace)',
    };
  }
}

/// A class that represents the state of an asynchronous operation that is in progress.
class AsyncStateLoading<T> extends AsyncState<T> {
  const AsyncStateLoading._();
}

/// A class that represents the state of an asynchronous operation that has completed successfully with data.
class AsyncStateData<T> extends AsyncState<T> {
  const AsyncStateData._(this.data);

  /// The data of the operation.
  final T data;
}

/// A class that represents the state of an asynchronous operation that has completed with an error.
class AsyncStateError<T> extends AsyncState<T> {
  const AsyncStateError._(this.error, this.stackTrace);

  /// The error of the operation.
  final Object error;

  /// The stack trace of the error.
  final StackTrace? stackTrace;
}
