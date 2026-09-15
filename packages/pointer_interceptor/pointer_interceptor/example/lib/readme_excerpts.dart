// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Wraps a single button so that it can be clicked, even when it's on top of
/// a platform view.
Widget wrapButtonSnippet() {
  return
  // #docregion WrapButton
  PointerInterceptor(
    child: ElevatedButton(
      // #enddocregion WrapButton
      onPressed: () {},
      child: const Text('Button'),
      // #docregion WrapButton
    ),
  )
  // #enddocregion WrapButton
  ;
}

/// Wraps a whole subtree (a [Drawer], in this case) so that it can be
/// clicked, even when it's on top of a platform view.
Widget wrapSubtreeSnippet() {
  return
  // #docregion WrapSubtree
  Scaffold(
    drawer: PointerInterceptor(
      child: Drawer(
        // #enddocregion WrapSubtree
        child: ListView(children: const <Widget>[Text('Drawer contents')]),
        // #docregion WrapSubtree
      ),
    ),
  )
  // #enddocregion WrapSubtree
  ;
}

/// The naive way of conditionally intercepting pointer events, which
/// `intercepting` is meant to replace.
Widget interceptingBeforeSnippet(bool someCondition) {
  // #docregion InterceptingBefore
  if (someCondition) {
    return PointerInterceptor(
      child: ElevatedButton(
        // #enddocregion InterceptingBefore
        onPressed: () {},
        child: const Text('Button'),
        // #docregion InterceptingBefore
      ),
    );
  } else {
    return ElevatedButton(
      // #enddocregion InterceptingBefore
      onPressed: () {},
      child: const Text('Button'),
      // #docregion InterceptingBefore
    );
  }
  // #enddocregion InterceptingBefore
}

/// The equivalent of [interceptingBeforeSnippet], using `intercepting`.
Widget interceptingAfterSnippet(bool someCondition) {
  return
  // #docregion InterceptingAfter
  PointerInterceptor(
    intercepting: someCondition,
    child: ElevatedButton(
      // #enddocregion InterceptingAfter
      onPressed: () {},
      child: const Text('Button'),
      // #docregion InterceptingAfter
    ),
  )
  // #enddocregion InterceptingAfter
  ;
}
