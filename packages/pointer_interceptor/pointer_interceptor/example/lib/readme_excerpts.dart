// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Wraps a single button so that it can be clicked, even when it's on top of
/// a platform view.
Widget wrapButtonSnippet() {
  // #docregion WrapButton
  return PointerInterceptor(
    child: ElevatedButton(onPressed: () {}, child: const Text('Button')),
  );
  // #enddocregion WrapButton
}

/// Wraps a whole subtree (a [Drawer], in this case) so that it can be
/// clicked, even when it's on top of a platform view.
Widget wrapSubtreeSnippet() {
  // #docregion WrapSubtree
  return Scaffold(
    drawer: PointerInterceptor(
      child: Drawer(child: ListView(children: const <Widget>[Text('Drawer contents')])),
    ),
  );
  // #enddocregion WrapSubtree
}

/// The naive way of conditionally intercepting pointer events, which
/// `intercepting` is meant to replace.
Widget interceptingBeforeSnippet(bool someCondition) {
  // #docregion InterceptingBefore
  if (someCondition) {
    return PointerInterceptor(
      child: ElevatedButton(onPressed: () {}, child: const Text('Button')),
    );
  } else {
    return ElevatedButton(onPressed: () {}, child: const Text('Button'));
  }
  // #enddocregion InterceptingBefore
}

/// The equivalent of [interceptingBeforeSnippet], using `intercepting`.
Widget interceptingAfterSnippet(bool someCondition) {
  // #docregion InterceptingAfter
  return PointerInterceptor(
    intercepting: someCondition,
    child: ElevatedButton(onPressed: () {}, child: const Text('Button')),
  );
  // #enddocregion InterceptingAfter
}
