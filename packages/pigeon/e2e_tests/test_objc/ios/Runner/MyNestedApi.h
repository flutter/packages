// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "dartle.h"

NS_ASSUME_NONNULL_BEGIN

/// Implementation of the Pigeon generated interface NestedApi.
@interface MyNestedApi : NSObject <ACNestedApi>
- (ACSearchReply *)search:(ACNested *)input error:(FlutterError *_Nullable *_Nonnull)error;
@end

NS_ASSUME_NONNULL_END
