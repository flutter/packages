// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../foundation/foundation.dart';
import '../web_kit/web_kit.dart';
import '../web_kit/web_kit_api_impls.dart';
import 'ui_kit_api_impls.dart';

/// A view that allows the scrolling and zooming of its contained views.
///
/// Wraps [UIScrollView](https://developer.apple.com/documentation/uikit/uiscrollview?language=objc).
@immutable
class UIScrollView extends UIViewBase {
  /// Constructs a [UIScrollView] that is owned by [webView].
  factory UIScrollView.fromWebView(
    WKWebView webView, {
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) {
    final UIScrollView scrollView = UIScrollView.detached(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
    scrollView._scrollViewApi.createFromWebViewForInstances(
      scrollView,
      webView,
    );
    return scrollView;
  }

  /// Constructs a [UIScrollView] without creating the associated
  /// Objective-C object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies.
  UIScrollView.detached({
    super.observeValue,
    super.binaryMessenger,
    super.instanceManager,
  })  : _scrollViewApi = UIScrollViewHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  final UIScrollViewHostApiImpl _scrollViewApi;

  /// Point at which the origin of the content view is offset from the origin of the scroll view.
  ///
  /// Represents [WKWebView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset?language=objc).
  Future<Point<double>> getContentOffset() {
    return _scrollViewApi.getContentOffsetForInstances(this);
  }

  /// Move the scrolled position of this view.
  ///
  /// This method is not a part of UIKit and is only a helper method to make
  /// scrollBy atomic.
  Future<void> scrollBy(Point<double> offset) {
    return _scrollViewApi.scrollByForInstances(this, offset);
  }

  /// Set point at which the origin of the content view is offset from the origin of the scroll view.
  ///
  /// The default value is `Point<double>(0.0, 0.0)`.
  ///
  /// Sets [WKWebView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset?language=objc).
  Future<void> setContentOffset(Point<double> offset) {
    return _scrollViewApi.setContentOffsetForInstances(this, offset);
  }

  /// Set the delegate to this scroll view.
  ///
  /// Represents [UIScrollView.delegate](https://developer.apple.com/documentation/uikit/uiscrollview/1619430-delegate?language=objc).
  Future<void> setDelegate(UIScrollViewDelegate? delegate) {
    return _scrollViewApi.setDelegateForInstances(this, delegate);
  }

  @override
  UIScrollView copy() {
    return UIScrollView.detached(
      observeValue: observeValue,
      binaryMessenger: _viewApi.binaryMessenger,
      instanceManager: _viewApi.instanceManager,
    );
  }
}

/// Methods that anything implementing a class that inherits from UIView on the
/// native side must implement.
///
/// Classes without a multiple inheritence problem should extend UIViewBase
/// instead of implementing this directly.
abstract class UIView implements NSObject {
  /// The view’s background color.
  ///
  /// The default value is null, which results in a transparent background color.
  ///
  /// Sets [UIView.backgroundColor](https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor?language=objc).
  Future<void> setBackgroundColor(Color? color);

  /// Determines whether the view is opaque.
  ///
  /// Sets [UIView.opaque](https://developer.apple.com/documentation/uikit/uiview?language=objc).
  Future<void> setOpaque(bool opaque);
}

/// Manages the content for a rectangular area on the screen.
///
/// Wraps [UIView](https://developer.apple.com/documentation/uikit/uiview?language=objc).
@immutable
class UIViewBase extends NSObject implements UIView {
  /// Constructs a [UIView] without creating the associated
  /// Objective-C object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies.
  UIViewBase.detached({
    super.observeValue,
    super.binaryMessenger,
    super.instanceManager,
  })  : _viewApi = UIViewHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  final UIViewHostApiImpl _viewApi;

  @override
  Future<void> setBackgroundColor(Color? color) {
    return _viewApi.setBackgroundColorForInstances(this, color);
  }

  @override
  Future<void> setOpaque(bool opaque) {
    return _viewApi.setOpaqueForInstances(this, opaque);
  }

  @override
  UIView copy() {
    return UIViewBase.detached(
      observeValue: observeValue,
      binaryMessenger: _viewApi.binaryMessenger,
      instanceManager: _viewApi.instanceManager,
    );
  }
}

/// Responding to scroll view interactions.
///
/// Represent [UIScrollViewDelegate](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate?language=objc).
@immutable
class UIScrollViewDelegate extends NSObject {
  /// Constructs a [UIScrollViewDelegate].
  UIScrollViewDelegate({
    this.scrollViewDidScroll,
    super.binaryMessenger,
    super.instanceManager,
  })  : _scrollViewDelegateApi = UIScrollViewDelegateHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached() {
    // Ensures FlutterApis for the WebKit library are set up.
    WebKitFlutterApis.instance.ensureSetUp();
    _scrollViewDelegateApi.createForInstance(this);
  }

  /// Constructs a [UIScrollViewDelegate] without creating the associated
  /// Objective-C object.
  ///
  /// This should only be used by subclasses created by this library or to
  /// create copies.
  UIScrollViewDelegate.detached({
    this.scrollViewDidScroll,
    super.binaryMessenger,
    super.instanceManager,
  })  : _scrollViewDelegateApi = UIScrollViewDelegateHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super.detached();

  final UIScrollViewDelegateHostApiImpl _scrollViewDelegateApi;

  /// Called when scroll view did scroll.
  ///
  /// {@macro webview_flutter_wkwebview.foundation.callbacks}
  final void Function(
    UIScrollView scrollView,
    double x,
    double y,
  )? scrollViewDidScroll;

  @override
  UIScrollViewDelegate copy() {
    return UIScrollViewDelegate.detached(
      scrollViewDidScroll: scrollViewDidScroll,
      binaryMessenger: _scrollViewDelegateApi.binaryMessenger,
      instanceManager: _scrollViewDelegateApi.instanceManager,
    );
  }
}
