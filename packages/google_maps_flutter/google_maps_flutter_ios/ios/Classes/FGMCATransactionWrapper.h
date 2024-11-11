// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FGMCATransactionProtocol <NSObject>
- (void)begin;
- (void)commit;
- (void)setAnimationDuration:(CFTimeInterval)duration;
@end

@interface FGMCATransactionWrapper : NSObject <FGMCATransactionProtocol>
@end

NS_ASSUME_NONNULL_END
