// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ProductRequestCompletion)(SKProductsResponse *_Nullable response,
                                         NSError *_Nullable errror);
/// A protocol that wraps SKRequest.
@protocol FLTRequestHandlerProtocol <NSObject>

/// Wrapper for SKRequest's start
/// https://developer.apple.com/documentation/storekit/skrequest/1385534-start
- (void)startProductRequestWithCompletionHandler:(ProductRequestCompletion)completion;
@end
NS_ASSUME_NONNULL_END
