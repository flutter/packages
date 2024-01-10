// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <LocalAuthentication/LocalAuthentication.h>

/**
 * Protocol for a source of LAContext instances. Used to allow context injection in unit tests.
 */
@protocol FLAAuthContextFactory <NSObject>
- (LAContext *)createAuthContext;
@end

@interface FLTLocalAuthPlugin ()
/**
 * Returns an instance that uses the given factory to create LAContexts.
 */
- (instancetype)initWithContextFactory:(NSObject<FLAAuthContextFactory> *)factory
    NS_DESIGNATED_INITIALIZER;
@end
