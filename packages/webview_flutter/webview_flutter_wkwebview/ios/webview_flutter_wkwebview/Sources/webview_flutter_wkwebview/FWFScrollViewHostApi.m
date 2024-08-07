// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFScrollViewHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFScrollViewDelegateHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFWebViewHostApi.h"

@interface FWFScrollViewHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;

// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFScrollViewHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (UIScrollView *)scrollViewForIdentifier:(NSInteger)identifier {
  return (UIScrollView *)[self.instanceManager instanceForIdentifier:identifier];
}

- (void)createFromWebViewWithIdentifier:(NSInteger)identifier
                      webViewIdentifier:(NSInteger)webViewIdentifier
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  WKWebView *webView = (WKWebView *)[self.instanceManager instanceForIdentifier:webViewIdentifier];
  [self.instanceManager addDartCreatedInstance:webView.scrollView withIdentifier:identifier];
}

- (NSArray<NSNumber *> *)
    contentOffsetForScrollViewWithIdentifier:(NSInteger)identifier
                                       error:(FlutterError *_Nullable *_Nonnull)error {
  CGPoint point = [[self scrollViewForIdentifier:identifier] contentOffset];
  return @[ @(point.x), @(point.y) ];
}

- (void)scrollByForScrollViewWithIdentifier:(NSInteger)identifier
                                          x:(double)x
                                          y:(double)y
                                      error:(FlutterError *_Nullable *_Nonnull)error {
  UIScrollView *scrollView = [self scrollViewForIdentifier:identifier];
  CGPoint contentOffset = scrollView.contentOffset;
  [scrollView setContentOffset:CGPointMake(contentOffset.x + x, contentOffset.y + y)];
}

- (void)setContentOffsetForScrollViewWithIdentifier:(NSInteger)identifier
                                                toX:(double)x
                                                  y:(double)y
                                              error:(FlutterError *_Nullable *_Nonnull)error {
  [[self scrollViewForIdentifier:identifier] setContentOffset:CGPointMake(x, y)];
}

- (void)setDelegateForScrollViewWithIdentifier:(NSInteger)identifier
                uiScrollViewDelegateIdentifier:(nullable NSNumber *)uiScrollViewDelegateIdentifier
                                         error:(FlutterError *_Nullable *_Nonnull)error {
  [[self scrollViewForIdentifier:identifier]
      setDelegate:uiScrollViewDelegateIdentifier
                      ? (FWFScrollViewDelegate *)[self.instanceManager
                            instanceForIdentifier:uiScrollViewDelegateIdentifier.longValue]
                      : nil];
}
@end
