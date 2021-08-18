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
    throw ArgumentError('Iterables aren\'t of equal length.');
  }
}

/// Standard implementation for a tuple.
class Tuple<T, U> {
  /// Constructor.
  Tuple(this.first, this.second);

  /// The first item supplied to the constructor.
  final T first;

  /// The second item supplied to the constructor.
  final U second;
}

/// Zips 2 iterables into one.  The [Iterable]s must be of equal length.
Iterable<Tuple<T, U>> zip<T, U>(Iterable<T> ts, Iterable<U> us) =>
    map2(ts, us, (T t, U u) => Tuple<T, U>(t, u));
