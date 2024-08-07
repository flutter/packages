// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Using directory structure to remove platform-specific files doesn't work
// well with umbrella headers and module maps, so just no-op the file for
// other platforms instead.
#if TARGET_OS_IOS

#import "./include/webview_flutter_wkwebview/FWFScrollViewDelegateHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFWebViewHostApi.h"

@interface FWFScrollViewDelegateFlutterApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFScrollViewDelegateFlutterApiImpl

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}
- (long)identifierForDelegate:(FWFScrollViewDelegate *)instance {
  return [self.instanceManager identifierWithStrongReferenceForInstance:instance];
}

- (void)scrollViewDidScrollForDelegate:(FWFScrollViewDelegate *)instance
                          uiScrollView:(UIScrollView *)scrollView
                            completion:(void (^)(FlutterError *_Nullable))completion {
  [self scrollViewDidScrollWithIdentifier:[self identifierForDelegate:instance]
                   UIScrollViewIdentifier:[self.instanceManager
                                              identifierWithStrongReferenceForInstance:scrollView]
                                        x:scrollView.contentOffset.x
                                        y:scrollView.contentOffset.y
                               completion:completion];
}
@end

@implementation FWFScrollViewDelegate

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _scrollViewDelegateAPI =
        [[FWFScrollViewDelegateFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                             instanceManager:instanceManager];
  }
  return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.scrollViewDelegateAPI scrollViewDidScrollForDelegate:self
                                                uiScrollView:scrollView
                                                  completion:^(FlutterError *error) {
                                                    NSAssert(!error, @"%@", error);
                                                  }];
}
@end

@interface FWFScrollViewDelegateHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFScrollViewDelegateHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (void)createWithIdentifier:(NSInteger)identifier error:(FlutterError *_Nullable *_Nonnull)error {
  FWFScrollViewDelegate *uiScrollViewDelegate =
      [[FWFScrollViewDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                             instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:uiScrollViewDelegate withIdentifier:identifier];
}
@end

#endif
