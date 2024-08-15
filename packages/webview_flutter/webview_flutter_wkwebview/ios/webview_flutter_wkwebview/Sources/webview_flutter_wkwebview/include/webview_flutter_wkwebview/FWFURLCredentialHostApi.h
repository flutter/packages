// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import "FWFDataConverters.h"
#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/// Host API implementation for `NSURLCredential`.
///
/// This class may handle instantiating and adding native object instances that are attached to a
/// Dart instance or method calls on the associated native class or an instance of the class.
@interface FWFURLCredentialHostApiImpl : NSObject <FWFNSUrlCredentialHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
