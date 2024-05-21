// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

@internal
@immutable
sealed class AsyncState<T> {
  const AsyncState();

  const factory AsyncState.loading() = AsyncStateLoading<T>;

  const factory AsyncState.data(T data) = AsyncStateData<T>;

  const factory AsyncState.error(Object error, StackTrace? stackTrace) =
      AsyncStateError<T>;

  AsyncState<T> whenData(
    T Function(T data) onData,
  ) {
    return switch (this) {
      AsyncStateData<T>(data: final T data) => AsyncState<T>.data(onData(data)),
      _ => this,
    };
  }

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
            stackTrace: final StackTrace? stackTrace
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
          stackTrace: final StackTrace? stackTrace
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
        stackTrace: final StackTrace? stackTrace
      ) =>
        'AsyncState.error($error, $stackTrace)',
    };
  }
}

@internal
class AsyncStateLoading<T> extends AsyncState<T> {
  const AsyncStateLoading();
}

@internal
class AsyncStateData<T> extends AsyncState<T> {
  const AsyncStateData(this.data);

  final T data;
}

@internal
class AsyncStateError<T> extends AsyncState<T> {
  const AsyncStateError(this.error, this.stackTrace);

  final Object error;
  final StackTrace? stackTrace;
}
