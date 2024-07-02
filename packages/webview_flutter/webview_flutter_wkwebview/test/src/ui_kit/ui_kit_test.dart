// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_wkwebview/src/common/instance_manager.dart';
import 'package:webview_flutter_wkwebview/src/common/web_kit.g.dart';
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit.dart';
import 'package:webview_flutter_wkwebview/src/ui_kit/ui_kit_api_impls.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';

import '../common/test_web_kit.g.dart';
import 'ui_kit_test.mocks.dart';

@GenerateMocks(<Type>[
  TestWKWebViewConfigurationHostApi,
  TestWKWebViewHostApi,
  TestUIScrollViewHostApi,
  TestUIScrollViewDelegateHostApi,
  TestUIViewHostApi,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UIKit', () {
    late InstanceManager instanceManager;

    setUp(() {
      instanceManager = InstanceManager(onWeakReferenceRemoved: (_) {});
    });

    group('UIScrollView', () {
      late MockTestUIScrollViewHostApi mockPlatformHostApi;

      late UIScrollView scrollView;
      late int scrollViewInstanceId;

      setUp(() {
        mockPlatformHostApi = MockTestUIScrollViewHostApi();
        TestUIScrollViewHostApi.setUp(mockPlatformHostApi);

        TestWKWebViewConfigurationHostApi.setUp(
          MockTestWKWebViewConfigurationHostApi(),
        );
        TestWKWebViewHostApi.setUp(MockTestWKWebViewHostApi());
        final WKWebView webView = WKWebViewIOS(
          WKWebViewConfiguration(instanceManager: instanceManager),
          instanceManager: instanceManager,
        );

        scrollView = UIScrollView.fromWebView(
          webView,
          instanceManager: instanceManager,
        );
        scrollViewInstanceId = instanceManager.getIdentifier(scrollView)!;
      });

      tearDown(() {
        TestUIScrollViewHostApi.setUp(null);
        TestWKWebViewConfigurationHostApi.setUp(null);
        TestWKWebViewHostApi.setUp(null);
      });

      test('getContentOffset', () async {
        when(mockPlatformHostApi.getContentOffset(scrollViewInstanceId))
            .thenReturn(<double>[4.0, 10.0]);
        expect(
          scrollView.getContentOffset(),
          completion(const Point<double>(4.0, 10.0)),
        );
      });

      test('scrollBy', () async {
        await scrollView.scrollBy(const Point<double>(4.0, 10.0));
        verify(mockPlatformHostApi.scrollBy(scrollViewInstanceId, 4.0, 10.0));
      });

      test('setContentOffset', () async {
        await scrollView.setContentOffset(const Point<double>(4.0, 10.0));
        verify(mockPlatformHostApi.setContentOffset(
          scrollViewInstanceId,
          4.0,
          10.0,
        ));
      });

      test('setDelegate', () async {
        final UIScrollViewDelegate delegate = UIScrollViewDelegate.detached(
          instanceManager: instanceManager,
        );
        const int delegateIdentifier = 10;
        instanceManager.addHostCreatedInstance(delegate, delegateIdentifier);
        await scrollView.setDelegate(delegate);
        verify(mockPlatformHostApi.setDelegate(
          scrollViewInstanceId,
          delegateIdentifier,
        ));
      });
    });

    group('UIScrollViewDelegate', () {
      // Ensure the test host api is removed after each test run.
      tearDown(() => TestUIScrollViewDelegateHostApi.setUp(null));

      test('Host API create', () {
        final MockTestUIScrollViewDelegateHostApi mockApi =
            MockTestUIScrollViewDelegateHostApi();
        TestUIScrollViewDelegateHostApi.setUp(mockApi);

        UIScrollViewDelegate(instanceManager: instanceManager);
        verify(mockApi.create(0));
      });

      test('scrollViewDidScroll', () {
        final UIScrollViewDelegateFlutterApi flutterApi =
            UIScrollViewDelegateFlutterApiImpl(
          instanceManager: instanceManager,
        );

        final UIScrollView scrollView = UIScrollView.detached(
          instanceManager: instanceManager,
        );
        instanceManager.addHostCreatedInstance(scrollView, 0);

        List<Object?>? args;
        final UIScrollViewDelegate scrollViewDelegate =
            UIScrollViewDelegate.detached(
          scrollViewDidScroll: (UIScrollView scrollView, double x, double y) {
            args = <Object?>[scrollView, x, y];
          },
          instanceManager: instanceManager,
        );
        instanceManager.addHostCreatedInstance(scrollViewDelegate, 1);

        flutterApi.scrollViewDidScroll(1, 0, 5, 6);
        expect(args, <Object?>[scrollView, 5, 6]);
      });
    });

    group('UIView', () {
      late MockTestUIViewHostApi mockPlatformHostApi;

      late UIView view;
      late int viewInstanceId;

      setUp(() {
        mockPlatformHostApi = MockTestUIViewHostApi();
        TestUIViewHostApi.setUp(mockPlatformHostApi);

        view = UIViewBase.detached(instanceManager: instanceManager);
        viewInstanceId = instanceManager.addDartCreatedInstance(view);
      });

      tearDown(() {
        TestUIViewHostApi.setUp(null);
      });

      test('setBackgroundColor', () async {
        await view.setBackgroundColor(Colors.red);
        verify(mockPlatformHostApi.setBackgroundColor(
          viewInstanceId,
          Colors.red.value,
        ));
      });

      test('setOpaque', () async {
        await view.setOpaque(false);
        verify(mockPlatformHostApi.setOpaque(viewInstanceId, false));
      });
    });
  });
}
