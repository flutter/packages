// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A [map] function that calls the function with an enumeration as well as the
/// value.
Iterable<U> indexMap<T, U>(
    Iterable<T> iterable, U Function(int index, T value) func) sync* {
  int index = 0;
  for (final T value in iterable) {
    yield func(index, value);
    ++index;
  }
}

/// Performs like [forEach] but invokes [func] with an enumeration.
void enumerate<T>(Iterable<T> iterable, void Function(int, T) func) {
  int count = 0;
  for (final T value in iterable) {
    func(count, value);
    ++count;
  }
}

/// A [map] function that takes in 2 iterables.  The [Iterable]s must be of
/// equal length.
Iterable<V> map2<T, U, V>(
    Iterable<T> ts, Iterable<U> us, V Function(T t, U u) func) sync* {
  final Iterator<T> itt = ts.iterator;
  final Iterator<U> itu = us.iterator;
  while (itu.moveNext() && itt.moveNext()) {
    yield func(itt.current, itu.current);
  }
  if (itu.moveNext() || itt.moveNext()) {
    throw ArgumentError("Iterables aren't of equal length.");
  }
}

/// A [map] function that takes in 3 iterables.  The [Iterable]s must be of
/// equal length.
Iterable<V> map3<T, U, V, W>(Iterable<T> ts, Iterable<U> us, Iterable<W> ws,
    V Function(T t, U u, W w) func) sync* {
  final Iterator<T> itt = ts.iterator;
  final Iterator<U> itu = us.iterator;
  final Iterator<W> itw = ws.iterator;
  while (itu.moveNext() && itt.moveNext() && itw.moveNext()) {
    yield func(itt.current, itu.current, itw.current);
  }
  if (itu.moveNext() || itt.moveNext() || itw.moveNext()) {
    throw ArgumentError("Iterables aren't of equal length.");
  }
}

/// Adds [value] to the end of [ts].
Iterable<T> followedByOne<T>(Iterable<T> ts, T value) sync* {
  for (final T item in ts) {
    yield item;
  }
  yield value;
}

Iterable<int> _count() sync* {
  int x = 0;
  while (true) {
    yield x++;
  }
}

/// All integers starting at zero.
final Iterable<int> wholeNumbers = _count();

/// Repeats an [item] [n] times.
Iterable<T> repeat<T>(T item, int n) sync* {
  for (int i = 0; i < n; ++i) {
    yield item;
  }
}
